// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "../../contracts-common/contracts/upgrade/Initializable.sol";
import "../../contracts-common/contracts/access/Ownable.sol";

import "../interfaces/IBPGToken.sol";
import "./history/ERC20History.sol";

contract BPGToken is Initializable, Ownable, ERC20History, IBPGToken {
    function init() external initVer(1) {
        _init_Ownable(msg.sender);
    }
    
    function name() external pure returns(string memory) {
        return "Bitpost";
    }
    
    function symbol() external pure returns(string memory) {
        return "BPG";
    }
    
    function decimals() external pure returns(uint8) {
        return 6;
    }
    
    function mint(address account, uint256 value) external onlyOwner {
        _mint(account, value);
    }
    
    function burn(uint256 value) external onlyOwner {
        _burn(msg.sender, value);
    }
}
