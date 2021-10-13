// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import "./interfaces/IMasterchef.sol";

contract collector{
	IMASTERCHEF public masterchef;

	constructor(IMASTERCHEF _masterchefAddress) public{
		masterchef = _masterchefAddress;
	}
	function collectAll() public{

		uint256 pools;
		pools = masterchef.poolLength();

		for (uint256 i = 0; i < pools-1 ; i++) {
			if(i==8){
				i++;
			}
          masterchef.extWithdraw(i, msg.sender);
        }

	}
}