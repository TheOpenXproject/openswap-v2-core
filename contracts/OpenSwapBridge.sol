// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./OpenSwapToken.sol";
import "./Ownable.sol";


contract OpenSwapBridge is Ownable, ReentrancyGuard {
	IERC20 openswapV1;
	OpenSwapToken openswapV2;
	address burnAddress = 0xdEad000000000000000000000000000000000000;

	constructor(IERC20 _openswapV1, OpenSwapToken _openswapV2) public {
		openswapV1 = _openswapV1;
		openswapV2 = _openswapV2;
	}

	event Bridge(address indexed user, uint amount);

	function convert(uint256 _amount) public nonReentrant {
		require(msg.sender == tx.origin, "Must be called directly");

		bool success = false;

		success = openswapV1.transferFrom(msg.sender, burnAddress, _amount);

		require(success == true, 'transfer failed');

		openswapV2.bridgeMint(msg.sender, _amount);
		emit Bridge(msg.sender, _amount);
		
	}


}