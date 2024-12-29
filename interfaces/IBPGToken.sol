// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "../../contracts-common/interfaces/upgrade/IInitializable.sol";
import "../../contracts-common/interfaces/access/IOwnable.sol";

import "./erc20/IERC20.sol";
import "./erc20/IERC20Errors.sol";
import "./erc20/IERC20Metadata.sol";
import "./history/IERC20History.sol";

interface IBPGToken is IInitializable, IOwnable, IERC20, IERC20Errors, IERC20Metadata, IERC20History {
    function init() external;
    function mint(address account, uint256 value) external;
    function burn(uint256 value) external;
}
