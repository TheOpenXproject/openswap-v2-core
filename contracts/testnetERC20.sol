pragma solidity 0.6.12;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Ownable.sol";


contract test0netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test1netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test2netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test3netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test4netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test5netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test6netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test7netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}
contract test8netERC20 is ERC20,Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(uint256 _amount, address _to) public onlyOwner{
        _mint(_to, _amount);
    }
}