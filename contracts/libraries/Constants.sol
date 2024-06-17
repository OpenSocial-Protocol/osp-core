// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title Constants
 * @author OpenSocial Protocol
 * @notice This library defines constants for the OpenSocial Protocol.
 */
library Constants {
    string internal constant FOLLOW_NFT_NAME_SUFFIX = "'s Follower";
    string internal constant FOLLOW_NFT_SYMBOL_SUFFIX = '-FOL';
    string internal constant JOIN_NFT_NAME_SUFFIX = "'s Member";
    string internal constant JOIN_NFT_SYMBOL_SUFFIX = '-MBR';
    uint8 internal constant MAX_HANDLE_LENGTH = 15;
    uint8 internal constant MIN_HANDLE_LENGTH = 4;
    uint8 internal constant MAX_COMMUNITY_NAME_LENGTH = 63;
    uint16 internal constant MAX_PROFILE_IMAGE_URI_LENGTH = 6000;
    address internal constant ERC6551_REGISTRY = 0x000000006551c19487814612e58FE06813775758;
    bytes32 internal constant COMMUNITY_TBA_SALT =
        0xd51dafa9227bb21dd4efbc739a5c611e802dd0ec1ef35b3dc8da5ad2dca64ae6;
    bytes32 internal constant APP_ADMIN = keccak256('APP_ADMIN');
    bytes32 internal constant GOVERNANCE = keccak256('GOVERNANCE');
    bytes32 internal constant OPERATION = keccak256('OPERATION');
    bytes32 internal constant STATE_ADMIN = keccak256('STATE_ADMIN');
    bytes32 internal constant SUPER_COMMUNITY_CREATOR = keccak256('SUPER_COMMUNITY_CREATOR');
    uint256 internal constant MAX_TAGS_NUMBER = 10;
    // community join nft roles
    uint256 internal constant COMMUNITY_MEMBER_ACCESS = 0x00000000;
    uint256 internal constant COMMUNITY_ADMIN_ACCESS = 0x55555555;
    uint256 internal constant COMMUNITY_MODERATOR_ACCESS = 0xaaaaaaaa;
}
