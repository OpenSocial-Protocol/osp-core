// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../libraries/OspDataTypes.sol';

/**
 * @title OspStorage
 * @author OpenSocial Protocol
 *
 * @dev This abstract contract defines storage for the Osp protocol.
 * Each condition' storage in a different slot.
 * The order within the condition storage structure cannot be changed.
 */
abstract contract OspStorage {
    /*///////////////////////////////////////////////////////////////
                            ProfileStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant PROFILE_STORAGE_POSITION = keccak256('osp.profile.storage');
    struct ProfileStorage {
        // Array with all token ids, used for enumeration
        uint256[] _allTokens;
        // Mapping from token id to position in the allTokens array
        mapping(uint256 => uint256) _allTokensIndex;
        mapping(bytes32 => uint256) _profileIdByHandleHash;
        mapping(uint256 => OspDataTypes.ProfileStruct) _profileById;
        mapping(address => uint256) _profileIdByAddress;
        uint256 _profileCounter;
        mapping(address => uint256) _sigNonces;
    }

    function _getProfileStorage() internal pure returns (ProfileStorage storage profileStorage) {
        bytes32 position = PROFILE_STORAGE_POSITION;
        assembly {
            profileStorage.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                            ContentStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant PUBLICATION_STORAGE_POSITION = keccak256('osp.content.storage');
    struct ContentStorage {
        mapping(uint256 => mapping(uint256 => OspDataTypes.ContentStruct)) _contentByIdByProfile;
        //tag 最多10个
        uint256 _megaphoneCount;
    }

    function _getContentStorage()
        internal
        pure
        returns (ContentStorage storage publicationStorage)
    {
        bytes32 position = PUBLICATION_STORAGE_POSITION;
        assembly {
            publicationStorage.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                            GovernanceStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant GOVERNANCE_STORAGE_POSITION = keccak256('osp.governance.storage');
    struct GovernanceStorage {
        string _name;
        string _symbol;
        address _followSBTImpl;
        address _joinNFTImpl;
        address _communityNFT;
        address _communityAccountProxy;
        address _erc6551AccountImpl;
        string _baseURI;
        mapping(address => bool) _appWhitelisted;
        mapping(bytes32 => bool) _reserveCommunityHandleHash;
        mapping(address => bool) _tokenWhitelisted;
        mapping(address => bool) DEPRECATED_superCommunityCreatorWhitelisted;
        address _treasure;
        OspDataTypes.RoyaltyInfo _joinNFTRoyaltyInfo;
    }

    function _getGovernanceStorage()
        internal
        pure
        returns (GovernanceStorage storage governanceStorage)
    {
        bytes32 position = GOVERNANCE_STORAGE_POSITION;
        assembly {
            governanceStorage.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                          CommunityStorage
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant COMMUNITY_STORAGE_POSITION = keccak256('osp.community.storage');
    struct CommunityStorage {
        mapping(uint256 => OspDataTypes.CommunityStruct) _communityById;
        mapping(bytes32 => uint256) _communityIdByHandleHash;
    }

    function _getCommunityStorage()
        internal
        pure
        returns (CommunityStorage storage communityStorage)
    {
        bytes32 position = COMMUNITY_STORAGE_POSITION;
        assembly {
            communityStorage.slot := position
        }
    }
}
