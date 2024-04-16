// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../../libraries/OspDataTypes.sol';
import '../../../interfaces/IERC721Burnable.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';
import {IERC721Enumerable} from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';

/**
 * @title IProfileLogic
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the ProfileLogic contract.
 */
interface IProfileLogic is IERC721Burnable, IERC721Metadata, IERC721Enumerable {
    /**
     * @dev Create a Profile for the message sender,each address can only be created once。
     *
     * @param vars A CreateProfileData struct containing the following params:
     *      handle: The handle to set for the profile, must be unique and non-empty,can only consist of lowercase letters, numbers and underscores
     *      followCondition: The follow condition to use, can be the zero address.
     *      followConditionInitData: The follow condition initialization data, if any.
     *
     * @return uint256 The token ID of the created profile.
     */
    function createProfile(OspDataTypes.CreateProfileData calldata vars) external returns (uint256);

    /**
     * @dev Sets a profile's follow condition, must be called by the profile owner.
     *
     * @param profileId The token ID of the profile to set the follow condition for.
     * @param followConditionInitCode The data to be passed to the follow condition for initialization.
     */
    function setFollowCondition(uint256 profileId, bytes calldata followConditionInitCode) external;

    /// ************************
    /// *****VIEW FUNCTIONS*****
    /// ************************

    /**
     * @dev Returns the FollowSBT of the profile.
     *
     * @param profileId The profile id to query.
     *
     * @return address Profile's FollowSBT address.
     */
    function getFollowSBT(uint256 profileId) external view returns (address);

    /**
     * @dev Returns the follow condition of the profile.
     *
     * @param profileId The profile id to query.
     *
     * @return address Profile's follow condition address.
     */
    function getFollowCondition(uint256 profileId) external view returns (address);

    /**
     * @dev Returns the handle of the profile.
     *
     * @param profileId The profile id to query.
     *
     * @return string  Profile's handle.
     */
    function getHandle(uint256 profileId) external view returns (string memory);

    /**
     * @dev Returns the profile ID according to a given handle.
     *
     * @param handle The handle to query.
     *
     * @return uint256 Profile ID the passed handle points to.
     */
    function getProfileIdByHandle(string calldata handle) external view returns (uint256);

    /**
     * @dev Returns the profile struct of the given profile ID.
     *
     * @param profileId The profile ID to query.
     *
     * @return ProfileStruct The profile struct of the given profile ID.
     */
    function getProfile(
        uint256 profileId
    ) external view returns (OspDataTypes.ProfileStruct memory);

    /**
     * @dev Returns the profile id according to a given address.
     *
     * @param addr The address to query.
     *
     * @return uint256 Profile ID associated with the address
     */
    function getProfileIdByAddress(address addr) external view returns (uint256);

    function nonces(address singer) external view returns (uint256);
}
