// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import '../../libraries/OspDataTypes.sol';
import '../../libraries/OspErrors.sol';
import '@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol';

/**
 * @title EIP712Base
 * @author OpenSocial Protocol
 * @dev This contract is EIP712 implementation.
 * See https://eips.ethereum.org/EIPS/eip-712
 */
abstract contract EIP712Base {
    using SignatureChecker for address;
    bytes32 internal constant EIP712_REVISION_HASH = keccak256('1');

    /**
     * @dev Wrapper for ecrecover to reduce code size, used in meta-tx specific functions.
     */
    function _validateRecoveredAddress(
        bytes32 digest,
        OspDataTypes.EIP712Signature calldata sig
    ) internal view {
        if (sig.deadline < block.timestamp) revert OspErrors.SignatureExpired();
        if (!sig.signer.isValidSignatureNow(digest, sig.signature)) {
            revert OspErrors.SignatureInvalid();
        }
    }

    /**
     * @dev Calculates EIP712 DOMAIN_SEPARATOR based on the current contract and chain ID.
     */
    function _calculateDomainSeparator() internal view virtual returns (bytes32);

    /**
     * @dev Calculates EIP712 digest based on the current DOMAIN_SEPARATOR.
     *
     * @param hashedMessage The message hash from which the digest should be calculated.
     *
     * @return bytes32 A 32-byte output representing the EIP712 digest.
     */
    function _calculateDigest(bytes32 hashedMessage) internal view returns (bytes32) {
        bytes32 digest;
        unchecked {
            digest = keccak256(
                abi.encodePacked('\x19\x01', _calculateDomainSeparator(), hashedMessage)
            );
        }
        return digest;
    }
}
