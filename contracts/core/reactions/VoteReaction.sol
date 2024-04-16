// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {OpenReactionBase} from '../base/OpenReactionBase.sol';
import {OspErrors} from '../../libraries/OspErrors.sol';

contract VoteReaction is OpenReactionBase {
    constructor(address osp) OpenReactionBase(osp) {}

    enum Vote {
        Cancel,
        Up,
        Down
    }

    function _processReaction(
        uint256 /*profileId*/,
        uint256 /*referencedProfileId*/,
        uint256 /*referencedContentId*/,
        bytes calldata data
    ) internal view override {
        abi.decode(data, (Vote));
    }
}
