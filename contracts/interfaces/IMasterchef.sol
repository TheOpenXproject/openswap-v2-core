// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMASTERCHEF {
    function poolLength() external view returns (uint256);
    function extWithdraw(uint256 _pid, address _user) external;
}