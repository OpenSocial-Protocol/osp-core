// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../../libraries/OspDataTypes.sol';

/**
 * @title IContentLogic
 * @author OpenSocial Protocol
 *
 * @dev This is the interface for the ContentLogic contract.
 */
interface IContentLogic {
    /**
     * @dev Create an activity.
     *
     * @param vars A CreateActivityData struct.
     *
     * @return contentId  Activity's content ID.
     */
    function createActivity(
        OspDataTypes.CreateActivityData calldata vars
    ) external payable returns (uint256 contentId);

    /**
     * @dev Create an activity with a signature.
     *
     * @param vars A CreateActivityData struct.
     * @param sig A EIP712Signature struct.
     *
     * @return contentId Activity's content ID.
     */
    function createActivityWithSig(
        OspDataTypes.CreateActivityData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external returns (uint256 contentId);

    /**
     * @dev Create a comment.
     *
     * @param vars A CreateCommentData struct.
     *
     * @return contentId Comment's content ID.
     */
    function createComment(
        OspDataTypes.CreateCommentData calldata vars
    ) external payable returns (uint256 contentId);

    /**
     * @dev Create a comment with a signature.
     *
     * @param vars A CreateCommentData struct.
     * @param sig A EIP712Signature struct.
     *
     * @return contentId  Comment's content ID.
     */
    function createCommentWithSig(
        OspDataTypes.CreateCommentData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external returns (uint256 contentId);

    /**
     * @dev Create an open reaction.
     *
     * @param vars A CreateOpenReactionData struct.
     */
    function createOpenReaction(OspDataTypes.CreateOpenReactionData calldata vars) external payable;

    /**
     * @dev Create an open reaction with a signature.
     *
     * @param vars A CreateOpenReactionData struct.
     * @param sig A EIP712Signature struct.
     */
    function createOpenReactionWithSig(
        OspDataTypes.CreateOpenReactionData calldata vars,
        OspDataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @dev Create a megaphone.
     *
     * @param vars A CreateMegaphoneData struct.
     *
     * @return megaphoneId Megaphone's ID.
     */
    function createMegaphone(
        OspDataTypes.CreateMegaphoneData calldata vars
    ) external returns (uint256 megaphoneId);

    /// ************************
    /// *****VIEW FUNCTIONS*****
    /// ************************

    /**
     * @dev Returns the content count for a given profile.
     *
     * @param profileId The profile ID to query.
     *
     * @return uint256 Content count for the given profile.
     */
    function getContentCount(uint256 profileId) external view returns (uint256);

    /**
     * @dev Returns the content struct for a given content.
     *
     * @param profileId The profile ID that published the content to query.
     * @param contentId The content ID of the content to query.
     *
     * @return ContentStruct The content struct associated with the queried content.
     */
    function getContent(
        uint256 profileId,
        uint256 contentId
    ) external view returns (OspDataTypes.ContentStruct memory);

    /**
     * @dev Returns the community's ID by content.
     *
     * @param profileId The profile ID that published the content to query.
     * @param contentId The content ID of the content to query.
     *
     * @return uint256 community's ID.
     */
    function getCommunityIdByContent(
        uint256 profileId,
        uint256 contentId
    ) external view returns (uint256);
}
