// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './IGovernanceLogic.sol';
import './IProfileLogic.sol';
import './IContentLogic.sol';
import './IRelationLogic.sol';
import './ICommunityLogic.sol';
import '../../../libraries/OspErrors.sol';
import '../../../libraries/OspEvents.sol';

/**
 * @title OspClient
 * @author OpenSocial Protocol
 * @dev This is the interface for the OspClient contract,
 * @dev This contract is used to generate the OpenSocial abi file.
 */
interface OspClient is
    IGovernanceLogic,
    IProfileLogic,
    IContentLogic,
    IRelationLogic,
    ICommunityLogic
{

}
