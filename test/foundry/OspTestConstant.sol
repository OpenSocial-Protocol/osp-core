// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {console2, Test} from 'forge-std/Test.sol';

contract OspTestConstant is Test {
    address constant ZERO_ADDRESS = address(0);
    bytes constant EMPTY_BYTES = new bytes(0);
    string[] EMPTY_STRINGS = new string[](0);
    address[] EMPTY_ADDRESS_ARRAY = new address[](0);
    bytes[] EMPTY_BYTES_ARRAY = new bytes[](0);
    bytes constant CORRECT_BYTES = abi.encode(1);
    bytes constant WRONG_BYTES = abi.encode(2);

    address immutable deployer = makeAddr('deployer');
    string constant OSP_NAME = 'osp-name';
    string constant OSP_SYMBOL = 'osp-symbl';
    string constant MOCK_URL = 'ipfs://osposposposposposposposp';
    string constant BASE_URL = 'https://opensocial.xyz/token/';

    address immutable user1;
    uint256 immutable user1PK;

    address immutable user2;
    uint256 immutable user2PK;

    modifier forUser1() {
        vm.startPrank(user1);
        _;
        vm.stopPrank();
    }

    modifier forUser2() {
        vm.startPrank(user2);
        _;
        vm.stopPrank();
    }

    constructor() {
        (user1, user1PK) = makeAddrAndKey('user1');
        (user2, user2PK) = makeAddrAndKey('user2');
    }
}
