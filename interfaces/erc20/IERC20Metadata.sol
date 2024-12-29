// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external pure returns(string memory);
    function symbol() external pure returns(string memory);
    function decimals() external pure returns(uint8);
}