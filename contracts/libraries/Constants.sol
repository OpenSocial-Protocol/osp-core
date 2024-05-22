// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/**
 * @title Constants
 * @author OpenSocial Protocol
 * @notice This library defines constants for the OpenSocial Protocol.
 */
library Constants {
    string internal constant FOLLOW_NFT_NAME_SUFFIX = ' Follower';
    string internal constant FOLLOW_NFT_SYMBOL_SUFFIX = '_Fl';
    string internal constant JOIN_NFT_NAME_INFIX = ' Member';
    string internal constant JOIN_NFT_SYMBOL_INFIX = '_Mb';
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
    uint256 internal constant MAX_TAGS_NUMBER = 10;
}
