// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../storage/OspStorage.sol';
import '../../libraries/OspErrors.sol';
import '../base/OspMultiState.sol';
import '../base/EIP712Base.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';
import {IJoinCondition} from '../../interfaces/IJoinCondition.sol';
import {IOpenReaction} from '../../interfaces/IOpenReaction.sol';
import {IActivityExtension} from '../../interfaces/IActivityExtension.sol';
import {IReferenceCondition} from '../../interfaces/IReferenceCondition.sol';
import {ICommunityCondition} from '../../interfaces/ICommunityCondition.sol';
import {IFollowCondition} from '../../interfaces/IFollowCondition.sol';

/**
 * @title OspLogicBase
 * @author OpenSocial Protocol
 * @dev The OspLogicBase contract includes methods for modifying contract state and some common methods that all Logic contracts must inherit.
 */
contract OspLogicBase is OspMultiState, OspStorage, EIP712Base {
    /*///////////////////////////////////////////////////////////////
                        modifiers
    //////////////////////////////////////////////////////////////*/

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    function _checkFollowCondition(address followCondition) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[followCondition] ||
            !ERC165Checker.supportsInterface(followCondition, type(IFollowCondition).interfaceId)
        ) revert OspErrors.AppNotWhitelisted();
    }

    function _checkCommunityCondition(address communityCondition) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[communityCondition] ||
            !ERC165Checker.supportsInterface(
                communityCondition,
                type(ICommunityCondition).interfaceId
            )
        ) revert OspErrors.AppNotWhitelisted();
    }

    function _checkJoinCondition(address joinCondition) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[joinCondition] ||
            !ERC165Checker.supportsInterface(joinCondition, type(IJoinCondition).interfaceId)
        ) revert OspErrors.AppNotWhitelisted();
    }

    function _checkActivityExtension(address extension) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[extension] ||
            !ERC165Checker.supportsInterface(extension, type(IActivityExtension).interfaceId)
        ) revert OspErrors.AppNotWhitelisted();
    }

    function _checkOpenReaction(address openReaction) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[openReaction] ||
            !ERC165Checker.supportsInterface(openReaction, type(IOpenReaction).interfaceId)
        ) revert OspErrors.AppNotWhitelisted();
    }

    function _checkReferenceCondition(address referenceCondition) internal view {
        if (
            !_getGovernanceStorage()._appWhitelisted[referenceCondition] ||
            !ERC165Checker.supportsInterface(
                referenceCondition,
                type(IReferenceCondition).interfaceId
            )
        ) revert OspErrors.AppNotWhitelisted();
    }

    /**
     *  @dev This function reverts if the caller is not the owner of the profile.
     */
    function _validateIsProfileOwner(address addr, uint256 profileId) internal view {
        if (addr != _ownerOf(profileId)) revert OspErrors.NotProfileOwner();
    }

    /**
     *  @dev This function reverts if the address is not has profile.
     */
    function _validateHasProfile(address addr) internal view returns (uint256) {
        uint256 profileId = _getProfileStorage()._profileIdByAddress[addr];
        if (profileId == 0) revert OspErrors.NotHasProfile();
        return profileId;
    }

    /**
     * @dev Returns the owner of the profile.
     */
    function _ownerOf(uint256 profileId) internal view returns (address) {
        return _getProfileStorage()._profileById[profileId].owner;
    }

    function _calculateDomainSeparator() internal view virtual override returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                    keccak256(bytes(_getGovernanceStorage()._name)),
                    EIP712_REVISION_HASH,
                    block.chainid,
                    address(this)
                )
            );
    }
}
