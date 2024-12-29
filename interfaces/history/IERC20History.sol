// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "../erc20/IERC20.sol";

interface IERC20History is IERC20 {
    error ERC20HistoryInvalidBlockNumber(uint256 blockNumber);
    
    function totalSupplyAt(uint256 blockNumber) external view returns(uint256);
    function balanceOfAt(address account, uint256 blockNumber) external view returns(uint256);
}
