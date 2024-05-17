// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/* solhint-disable no-empty-blocks */

import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {IERC721Receiver} from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import {IERC1155Receiver} from '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';
import {OspErrors} from '../../libraries/OspErrors.sol';
import {OspClient} from '../logics/interfaces/OspClient.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract ERC6551Account is IERC721Receiver, IERC1155Receiver {
    struct Execution {
        // The target contract for account to execute.
        address target;
        // The value for the execution.
        uint256 value;
        // The call data for the execution.
        bytes data;
    }

    address immutable OSP;

    uint256 public tokenId;

    constructor(address osp) {
        OSP = osp;
    }

    /**
     * @dev initialize communityId, only callable by OSP
     */
    function initialize(uint256 communityId) external {
        if (msg.sender != OSP) revert OspErrors.NotOSP();
        tokenId = communityId;
    }

    /**
     * @dev For previous TBA accounts，initialize communityId.
     */
    function serCommunityId(uint256 communityId) external {
        if (tokenId != 0) revert OspErrors.InitParamsInvalid();
        if (OspClient(OSP).getCommunityAccount(communityId) == address(this)) {
            tokenId = communityId;
        }
    }

    /// @notice Executes a transaction from the account
    /// @param execution The execution to perform
    /// @return result The result of the execution
    function execute(
        Execution calldata execution
    ) public payable virtual returns (bytes memory result) {
        _onlyOwner(msg.sender);
        result = _exec(execution.target, execution.value, execution.data);
    }

    /// @notice Executes a batch of transactions from the account
    /// @dev If any of the transactions revert, the entire batch reverts
    /// @param executions The executions to perform
    /// @return results The results of the executions
    function executeBatch(
        Execution[] calldata executions
    ) public payable virtual returns (bytes[] memory results) {
        _onlyOwner(msg.sender);
        uint256 executionsLength = executions.length;
        results = new bytes[](executionsLength);

        for (uint256 i = 0; i < executionsLength; ) {
            results[i] = _exec(executions[i].target, executions[i].value, executions[i].data);
            unchecked {
                ++i;
            }
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external view virtual override returns (bool) {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function _exec(
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (bytes memory result) {
        bool success;
        (success, result) = target.call{value: value}(data);

        if (!success) {
            // Directly bubble up revert messages
            assembly ('memory-safe') {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _onlyOwner(address account) internal view {
        if (account != IERC721(OspClient(OSP).getCommunityNFT()).ownerOf(tokenId))
            revert OspErrors.NotCommunityOwner();
    }
}
