// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library Payment {
    using SafeERC20 for IERC20;

    function payNative(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}('');
        require(success, 'Transfer failed');
    }

    function payERC20(address token, address from, address to, uint256 amount) internal {
        IERC20 payToken = IERC20(token);
        payToken.safeTransferFrom(from, to, amount);
    }

    function payERC20(address token, address to, uint256 amount) internal {
        IERC20 payToken = IERC20(token);
        payToken.safeTransfer(to, amount);
    }
}
