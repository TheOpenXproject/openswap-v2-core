// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Ownable.sol";
import "./OpenSwapToken.sol";



// MasterChef is the master of Sushi. He can make Sushi and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once OpenSwap is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of SUSHIs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accOpenSwapPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accOpenSwapPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHIs distribution occurs.
        uint256 accOpenSwapPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
    }
    // The OpenSwap TOKEN!
    OpenSwapToken public OpenSwap;
    // Dev address.
    address public devaddr;
    // Reward collector address for blocktime change
    address public rewardCollector;
    // LP Depositor address for blocktime change
    address public lpDepositor;
    // Block number when bonus OpenSwap period ends.
    uint256 public bonusEndBlock;
    // OpenSwap tokens created per block.
    uint256 public OpenSwapPerBlock;
    //Amount of sushis per Second
    uint256 public OpenSwapPerSecond;
    // Bonus muliplier for early OpenSwap makers.
    uint256 public constant BONUS_MULTIPLIER = 13;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Mapping to know if the User has been added to the registry
    mapping(address => bool) public isUserRegisty;
    //Mapping to check if farm exists
    mapping(IERC20 => bool) public poolExistence;
    // User Database to Execute Blocktime Change
    address[] public userRegistry;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when OpenSwap mining starts.
    uint256 public startBlock;
    // Last Blocktime in Milliseconds
    uint256 public lastBlocktime;
    // Current Blocktime in Milliseconds
    uint256 public currentBlocktime;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardChange(uint256 OpenSwapPerBlock, uint256 Blocktime);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    modifier onlyCollector {
      require(msg.sender == rewardCollector);
      _;
   }

   modifier onlyDepositor {
      require(msg.sender == lpDepositor);
      _;
   }

   modifier validPID(uint256 _pid){
    uint256 length = poolInfo.length;
    require(_pid < length, "INVALID POOL ID");
    _;
   }

    modifier nonDuplicateAndValid(IERC20 _lpToken) {       
        bool isToken = false; 
        try _lpToken.balanceOf(address(this)){
            isToken = true;
        } catch {
            isToken = false;
        }
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        require(isToken == true, "Can't call balanceOf. Revert.");

        _;
    }

    constructor(
        OpenSwapToken _sushi,
        address _devaddr,
        uint256 _sushiPerBlock,
        uint256 _sushiPerSecond,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _currentBlocktime,
        uint256 _lastBlocktime
    ) public {
        OpenSwap = _sushi;
        devaddr = _devaddr;
        rewardCollector = _devaddr;
        OpenSwapPerBlock = _sushiPerBlock;
        OpenSwapPerSecond = _sushiPerSecond;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        currentBlocktime = _currentBlocktime;
        lastBlocktime = _lastBlocktime;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    //Changes rewards per block in Case an eventual Change in Harmony BlockTime
    function updateBlockIssuanceWithBlocktime()
        public onlyOwner {
        require(lastBlocktime != currentBlocktime , "OpenSwap : Blocktime hasn't changed");
        OpenSwapPerBlock = currentBlocktime.mul(OpenSwapPerSecond).div(1000);
        lastBlocktime = currentBlocktime;
        emit RewardChange(OpenSwapPerBlock, currentBlocktime);
    }

    //Changes the Blocktime Parameter and updates the Rewards per Block
    function changeBlocktime(uint _currentBlocktime)
        public onlyOwner {
        require(lastBlocktime != _currentBlocktime , "OpenSwap : Blocktime hasn't changed");
        
        massUpdatePools();

        currentBlocktime = _currentBlocktime;
        updateBlockIssuanceWithBlocktime();
        
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner nonDuplicateAndValid(_lpToken) {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accOpenSwapPerShare: 1
            })
        );
    }

    // Update the given pool's OpenSwap allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner validPID(_pid){
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }


    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _to.sub(bonusEndBlock)
                );
        }
    }

    // View function to see pending SUSHIs on frontend.
    function pendingOpenSwap(uint256 _pid, address _user)
        external
        view
        validPID(_pid)
        returns (uint256)
        {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accOpenSwapPerShare = pool.accOpenSwapPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 OpenSwapReward =
                multiplier.mul(OpenSwapPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accOpenSwapPerShare = accOpenSwapPerShare.add(
                OpenSwapReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accOpenSwapPerShare).div(1e12).sub(user.rewardDebt);
    }
    function amountStaked(uint256 _pid, address _user)
        external
        view
        validPID(_pid)
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;

    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validPID(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 OpenSwapReward =
            multiplier.mul(OpenSwapPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        OpenSwap.mint(devaddr, OpenSwapReward.div(10));
        OpenSwap.mint(address(this), OpenSwapReward);
        pool.accOpenSwapPerShare = pool.accOpenSwapPerShare.add(
            OpenSwapReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for OpenSwap allocation.
    function deposit(uint256 _pid, uint256 _amount) public validPID(_pid) nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accOpenSwapPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeTokenTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 finalAmount = pool.lpToken.balanceOf(address(this)).sub(balanceBefore);
            user.amount = user.amount.add(finalAmount);
        }
        
        user.rewardDebt = user.amount.mul(pool.accOpenSwapPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // ext deposit is to be called by a contract that must have the lp tokens. it will credit the account passed in as _user
    // allows 1 click deposit and stake of LP.
    // it also collects and send the user's farm rewards to his wallet.
    // does NOT transfer _user LP tokens.
    function extDeposit(uint256 _pid, uint256 _amount, address _user) public onlyDepositor validPID(_pid) nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];//gets the user info passed in as parameter
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accOpenSwapPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeTokenTransfer(_user, pending); //Send rewards to _user not msg.sender
            }
        }

        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount); //does not take user but message sender to take the LP tokens
            uint256 finalAmount = pool.lpToken.balanceOf(address(this)).sub(balanceBefore);
            user.amount = user.amount.add(finalAmount);
        }
        
        user.rewardDebt = user.amount.mul(pool.accOpenSwapPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public validPID(_pid) nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accOpenSwapPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accOpenSwapPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    //Withdraw users Openswap token by Collector address. Allows some flexibility to the dev.
    //Does not withdraw LPs
    function extWithdraw(uint256 _pid, address _user)
    public onlyCollector validPID(_pid) nonReentrant{
        uint256 _amount = 0; //HardCoded 0 Amount: Withdraw only Openswap tokens and not LP tokens
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accOpenSwapPerShare).div(1e12).sub(
                user.rewardDebt
            );

        if (pending > 0) {
            safeTokenTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);           
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accOpenSwapPerShare).div(1e12);
       
        emit Withdraw(_user, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public validPID(_pid) nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe OpenSwap transfer function, just in case if rounding error causes pool to not have enough SUSHIs.
        function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = OpenSwap.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > tokenBal) {
            transferSuccess = OpenSwap.transfer(_to, tokenBal);
        } else {
            transferSuccess = OpenSwap.transfer(_to, _amount);
        }
        require(transferSuccess, "safeTokenTransfer: transfer failed");
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "the dev says: Access unGranted");
        devaddr = _devaddr;
    }

       function collector(address _collectoraddr) public {
        require(msg.sender == rewardCollector || msg.sender == devaddr, "the dev says: Access unGranted ");
        rewardCollector = _collectoraddr;
    }
}
