// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./ERC20SNT/ERC20SNT.sol";
import "./Ownable.sol";


//OpenVote Token Can not be Transfered by users. only the owner //masterchef
//can send them to you. once sent they are unmovable.
//Dev Doesnt get this token. It is meant to be used as means of communication
//of user opinions.
//Will probably not be used in a governance contract that executes actual modifications to masterchef.

//ERC20SNT is a semi-nontransferable token
// only tranfermaster is allowed to transfer tokens.
// if transfermaster not set within constructer(pass zero address instead)
// you can set him internally once with _setTranferMaster(address)
// transfermaster is only settable once. no matter which way you go.



contract OpenVote is ERC20SNT("Openions", "OPNION", address(0)), Ownable {

    function mint(address _to, uint256 _amount) public onlyOwner{
        _mint(_to, _amount);
    }

    function setTransferMaster(address _transferMaster) public onlyOwner {
        _setTransferMaster(_transferMaster);
    }
}
