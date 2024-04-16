// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './OspDataTypes.sol';
import './OspErrors.sol';

/**
 * @title OspHelpers
 * @author OpenSocial Protocol
 *
 * @dev This is a library that only contains a single function that is used in the osp contract as well as in
 * both the publishing logic and interaction logic libraries.
 */
library OspHelpers {
    /**
     * @dev This helper function just returns the pointed content if the passed content is a mirror,
     * otherwise it returns the passed publication.
     *
     * @param profileId The token ID of the profile that published the given publication.
     * @param contentId The content ID of the given publication.
     * @param _contentByIdByProfile A pointer to the storage mapping of publications by contentId by profile ID.
     *
     * @return tuple First, the pointed publication's publishing profile ID, second, the pointed publication's ID, and third, the
     * pointed publication's collect . If the passed content is not a mirror, this returns the given publication.
     */
    function getPointedIfWithContentRoot(
        uint256 profileId,
        uint256 contentId,
        mapping(uint256 => mapping(uint256 => OspDataTypes.ContentStruct))
            storage _contentByIdByProfile
    ) internal view returns (uint256, uint256) {
        string memory contentURI = _contentByIdByProfile[profileId][contentId].contentURI;

        if (bytes(contentURI).length == 0) {
            uint256 pointedTokenId = _contentByIdByProfile[profileId][contentId]
                .referencedProfileId;

            if (pointedTokenId == 0) revert OspErrors.ContentDoesNotExist();

            uint256 pointedcontentId = _contentByIdByProfile[profileId][contentId]
                .referencedContentId;

            return (pointedTokenId, pointedcontentId);
        } else {
            return (profileId, contentId);
        }
    }
}
