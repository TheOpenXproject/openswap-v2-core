# OpenSwap v2 contracts


## OpenSwap token:

Differences:
-bridge included
-owner ov vote token
-distributes vote token 1:1 including tokens bridged.
-removed original sushi governance logic.
-no pre mint
-can be burnt (only own tokens)

## Bridge
Can be closed by dev (to ensure full seperation from V1)
address has to be set in openswap token,


## VoteToken:
ERC20SNT - semi-non transferable token
Cant be sent except by Masterchef.



#MasterChef:

added EXTDEPOSIT -- owned function that can add liquidity for user. caller must be in possesion of LP tokens.
added balance checks before and after for fee on transfer tokens
added valid token check: calls balanceOf when adding a farm to see if its a token or not
added checks for non duplicate pools.
added checks that PID entered is valid
added reentrancy guard on deposit, withdraw, extWithdraw, extDeposit, EmergencyWithdraw


## SushiMaker

no bar. burns tokens instead.


## uniswap contracts

no noticable change from v1 just naming convention went from / to -








 

Currently undeployed on testnet and mainnet

