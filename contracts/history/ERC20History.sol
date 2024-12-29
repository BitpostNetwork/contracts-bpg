// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "../../interfaces/history/IERC20History.sol";
import "../erc20/ERC20.sol";

abstract contract ERC20History is ERC20, IERC20History {
    struct Checkpoint {
        uint256 blockNumber;
        uint256 value;
    }
    
    /// @custom:storage-location erc7201:bitpost.bpg.ERC20History
    struct Storage_ERC20History {
        mapping(address => Checkpoint[]) balanceCheckpoints;
        Checkpoint[] totalSupplyCheckpoints;
    }

    // keccak256(abi.encode(uint256(keccak256("bitpost.bpg.ERC20History")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_LOCATION_ERC20HISTORY = 0xfcefface2da381a8744d5670ea5451aa1e4c0f3577d2d8c35c85f1cd24665400;

    function totalSupplyAt(uint256 blockNumber) external view returns(uint256) {
        Storage_ERC20History storage $ = _getStorage_ERC20History();
        return _getCheckpoint($.totalSupplyCheckpoints, blockNumber, totalSupply());
    }

    function balanceOfAt(address account, uint256 blockNumber) external view returns(uint256) {
        Storage_ERC20History storage $ = _getStorage_ERC20History();
        return _getCheckpoint($.balanceCheckpoints[account], blockNumber, balanceOf(account));
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        Storage_ERC20History storage $ = _getStorage_ERC20History();

        if(from != address(0)) {
            _maybeCreateCheckpoint($.balanceCheckpoints[from], balanceOf(from));
        }
        if(to != address(0)) {
            _maybeCreateCheckpoint($.balanceCheckpoints[to], balanceOf(to));
        }

        _maybeCreateCheckpoint($.totalSupplyCheckpoints, totalSupply());
        
        super._update(from, to, value);
    }

    function _maybeCreateCheckpoint(Checkpoint[] storage checkpoints, uint256 value) private {
        uint256 length = checkpoints.length;
        if(length == 0 || checkpoints[length - 1].blockNumber < block.number) {
            checkpoints.push(Checkpoint({
                blockNumber: block.number,
                value: value
            }));
        }
    }

    function _getCheckpoint(Checkpoint[] storage checkpoints, uint256 blockNumber, uint256 currentValue) private view returns(uint256) {
        require(blockNumber < block.number, ERC20HistoryInvalidBlockNumber(blockNumber));
        
        uint256 high = checkpoints.length;
        if(high == 0) {
            return 0;
        }
        if(checkpoints[high - 1].blockNumber <= blockNumber) {
            return currentValue;
        }

        uint256 low = 0;
        while(low < high) {
            uint256 mid = low + (high - low) / 2;
            if(checkpoints[mid].blockNumber > blockNumber) {
                high = mid;
            } else {
                unchecked {
                    low = mid + 1;
                }
            }
        }
        return checkpoints[low].value;
    }

    function _getStorage_ERC20History() private pure returns(Storage_ERC20History storage $) {
        assembly {
            $.slot := STORAGE_LOCATION_ERC20HISTORY
        }
    }
}
