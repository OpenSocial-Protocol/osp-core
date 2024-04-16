// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import './OspTestSetUp.sol';

abstract contract MetaTxNegatives is OspTestSetUp {
    uint256 private constant NO_DEADLINE = type(uint256).max;
    uint256 private _defaultMetaTxSignerPk;
    address private _defaultMetaTxSignerAddress;
    address private _defaultMetaTxSigner;
    uint256 private _defaultMetaTxSignerNonce;

    bytes32 domainSeparator;

    function setUp() public virtual override {
        domainSeparator = _getValidDomainSeparator();
        _defaultMetaTxSignerPk = _getDefaultMetaTxSignerPk();
        _defaultMetaTxSignerAddress = vm.addr(_defaultMetaTxSignerPk);
        _defaultMetaTxSigner = vm.addr(_defaultMetaTxSignerPk);
        _defaultMetaTxSignerNonce = _getMetaTxNonce(_defaultMetaTxSigner);
    }

    // Functions to mandatorily override.

    function _executeMetaTx(uint256 signerPk, uint256 nonce, uint256 deadline) internal virtual;

    function _getDefaultMetaTxSignerPk() internal virtual returns (uint256);

    function _getMetaTxNonce(address signer) internal virtual returns (uint256) {
        return ospClient.nonces(signer);
    }

    function _getDomainName() internal virtual returns (bytes memory) {
        return bytes(OSP_NAME);
    }

    function _getRevisionNumber() internal virtual returns (bytes memory) {
        return bytes('1');
    }

    function _getVerifyingContract() internal virtual returns (address) {
        return address(ospClient);
    }

    // Functions for MetaTx Negative test cases.

    function testCannotExecuteMetaTx_WhenSignature_HasExpired() public {
        domainSeparator = _getValidDomainSeparator();
        uint256 expiredTimestamp = block.timestamp;
        uint256 mockTimestamp = expiredTimestamp + 69;
        vm.warp(mockTimestamp);
        vm.expectRevert(OspErrors.SignatureExpired.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce,
            deadline: expiredTimestamp
        });
    }

    function testCannotExecuteMetaTx_WhenSignature_NonceIsInvalid() public {
        domainSeparator = _getValidDomainSeparator();
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce + 69,
            deadline: NO_DEADLINE
        });
    }

    function testCannotExecuteMetaTx_WhenSignature_SignerIsInvalid() public {
        domainSeparator = _getValidDomainSeparator();
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: 1234569696969,
            nonce: _defaultMetaTxSignerNonce,
            deadline: NO_DEADLINE
        });
    }

    function testCannotExecuteMetaTx_WhenSignatureDomain_WasGeneratedWithWrong_RevisionNumber()
        public
    {
        domainSeparator = keccak256(
            abi.encode(
                OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                keccak256(_getDomainName()),
                keccak256('69696969696969696969696969969696'),
                block.chainid,
                _getVerifyingContract()
            )
        );
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce,
            deadline: NO_DEADLINE
        });
    }

    function testCannotExecuteMetaTx_WhenSignatureDomain_WasGeneratedWithWrong_ChainId() public {
        domainSeparator = keccak256(
            abi.encode(
                OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                keccak256(_getDomainName()),
                keccak256(_getRevisionNumber()),
                type(uint256).max,
                _getVerifyingContract()
            )
        );
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce,
            deadline: NO_DEADLINE
        });
    }

    function testCannotExecuteMetaTx_WhenSignatureDomain_WasGeneratedWithWrong_VerifyingContract()
        public
    {
        domainSeparator = keccak256(
            abi.encode(
                OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                keccak256(_getDomainName()),
                keccak256(_getRevisionNumber()),
                block.chainid,
                address(0x691234569696969)
            )
        );
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce,
            deadline: NO_DEADLINE
        });
    }

    function testCannotExecuteMetaTx_WhenSignatureDomain_WasGeneratedWithWrong_Name() public {
        domainSeparator = keccak256(
            abi.encode(
                OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                keccak256('This should be an invalid name :)'),
                keccak256(_getRevisionNumber()),
                block.chainid,
                _getVerifyingContract()
            )
        );
        vm.expectRevert(OspErrors.SignatureInvalid.selector);
        _executeMetaTx({
            signerPk: _defaultMetaTxSignerPk,
            nonce: _defaultMetaTxSignerNonce,
            deadline: NO_DEADLINE
        });
    }

    function _getValidDomainSeparator() internal virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    OspDataTypes.EIP712_DOMAIN_TYPEHASH,
                    keccak256(_getDomainName()),
                    keccak256(_getRevisionNumber()),
                    block.chainid,
                    _getVerifyingContract()
                )
            );
    }

    function _calculateDigest(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash));
    }

    function _getSigStruct(
        uint256 pKey,
        bytes32 digest,
        uint256 deadline
    ) internal view returns (OspDataTypes.EIP712Signature memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pKey, digest);
        return
            OspDataTypes.EIP712Signature(
                _defaultMetaTxSignerAddress,
                abi.encodePacked(r, s, v),
                deadline
            );
    }

    /**
     *  typedata hash
     */

    function _getCreateActivityTypedDataHash(
        OspDataTypes.CreateActivityData memory vars,
        uint256 deadline,
        uint256 nonce
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                OspDataTypes.CREATE_ACTIVITY_WITH_SIG_TYPEHASH,
                vars.profileId,
                vars.communityId,
                keccak256(bytes(vars.contentURI)),
                keccak256(vars.extensionInitCode),
                keccak256(vars.referenceConditionInitCode),
                keccak256(vars.ctx),
                nonce,
                deadline
            )
        );
        return _calculateDigest(structHash);
    }

    function _getCreateOpenReactionTypedDataHash(
        OspDataTypes.CreateOpenReactionData memory vars,
        uint256 deadline,
        uint256 nonce
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                OspDataTypes.CREATE_OPEN_REACTION_WITH_SIG_TYPEHASH,
                vars.profileId,
                vars.communityId,
                vars.referencedProfileId,
                vars.referencedContentId,
                keccak256(vars.reactionAndData),
                keccak256(vars.referenceConditionData),
                keccak256(vars.ctx),
                nonce,
                deadline
            )
        );
        return _calculateDigest(structHash);
    }

    function _getCreateCommentTypedDataHash(
        OspDataTypes.CreateCommentData memory vars,
        uint256 deadline,
        uint256 nonce
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                OspDataTypes.CREATE_COMMENT_WITH_SIG_TYPEHASH,
                vars.profileId,
                vars.communityId,
                keccak256(bytes(vars.contentURI)),
                vars.referencedProfileId,
                vars.referencedContentId,
                keccak256(vars.referenceConditionInitCode),
                keccak256(vars.referenceConditionData),
                keccak256(vars.ctx),
                nonce,
                deadline
            )
        );
        return _calculateDigest(structHash);
    }
}
