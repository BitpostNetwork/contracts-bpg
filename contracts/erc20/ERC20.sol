// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "../../interfaces/erc20/IERC20.sol";
import "../../interfaces/erc20/IERC20Errors.sol";

abstract contract ERC20 is IERC20, IERC20Errors {
    /// @custom:storage-location erc7201:bitpost.bpg.ERC20
    struct Storage_ERC20 {
        uint256 totalSupply;
        mapping(address account => uint256) balances;
        mapping(address account => mapping(address spender => uint256)) allowances;
    }
    
    // keccak256(abi.encode(uint256(keccak256("bitpost.bpg.ERC20")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_LOCATION_ERC20 = 0xee0c2d5357d88d54dd6bbaa1b1a8910354885f2b74606115c4d95c4c54785400;
    
    function totalSupply() public view returns(uint256) {
        Storage_ERC20 storage $ = _getStorage_ERC20();
        return $.totalSupply;
    }
    
    function balanceOf(address account) public view returns(uint256) {
        Storage_ERC20 storage $ = _getStorage_ERC20();
        return $.balances[account];
    }
    
    function transfer(address to, uint256 value) external returns(bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns(uint256) {
        Storage_ERC20 storage $ = _getStorage_ERC20();
        return $.allowances[owner][spender];
    }
    
    function approve(address spender, uint256 value) external returns(bool) {
        _approve(msg.sender, spender, value, true);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) external returns(bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }
    
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), ERC20InvalidSender(address(0)));
        require(to != address(0), ERC20InvalidReceiver(address(0)));
        _update(from, to, value);
    }
    
    function _update(address from, address to, uint256 value) internal virtual {
        Storage_ERC20 storage $ = _getStorage_ERC20();
        
        if(from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            $.totalSupply += value;
        } else {
            uint256 fromBalance = $.balances[from];
            require(fromBalance >= value, ERC20InsufficientBalance(from, fromBalance, value));
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                $.balances[from] = fromBalance - value;
            }
        }

        if(to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                $.totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                $.balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
    
    function _mint(address account, uint256 value) internal {
        require(account != address(0), ERC20InvalidReceiver(address(0)));
        _update(address(0), account, value);
    }
    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), ERC20InvalidSender(address(0)));
        _update(account, address(0), value);
    }
    
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal {
        require(owner != address(0), ERC20InvalidApprover(address(0)));
        require(spender != address(0), ERC20InvalidSpender(address(0)));
        
        Storage_ERC20 storage $ = _getStorage_ERC20();
        $.allowances[owner][spender] = value;
        
        if(emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    
    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance < type(uint256).max) {
            require(currentAllowance >= value, ERC20InsufficientAllowance(spender, currentAllowance, value));
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
    
    function _getStorage_ERC20() private pure returns(Storage_ERC20 storage $) {
        assembly {
            $.slot := STORAGE_LOCATION_ERC20
        }
    }
}
