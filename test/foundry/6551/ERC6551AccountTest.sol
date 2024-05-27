// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './ERC6551AccountTestSetUp.sol';

contract ERC6551AccountTest is ERC6551AccountTestSetUp {
    function test_Execute() public {
        uint256 balance = 100 ether;
        vm.deal(address(erc6551Account), balance);
        uint256 value = 40 ether;
        uint256 data = 928343;
        vm.expectEmit(address(mockContract));
        emit MockContractEvent.MockEvent(value, data);
        vm.prank(owner);
        erc6551Account.execute(
            ERC6551Account.Execution({
                target: address(mockContract),
                value: value,
                data: abi.encodeWithSelector(MockContract.mockFunction.selector, data)
            })
        );
        assertEq(address(erc6551Account).balance, balance - value, 'balance not eq');
        assertEq(address(mockContract).balance, value, 'balance not eq');
    }

    function testRevert_Execute_NotOwner() public {
        uint256 balance = 100 ether;
        vm.deal(address(erc6551Account), balance);
        uint256 value = 40 ether;
        uint256 data = 928343;
        vm.expectRevert(OspErrors.NotCommunityOwner.selector);
        vm.prank(makeAddr('other user'));
        erc6551Account.execute(
            ERC6551Account.Execution({
                target: address(mockContract),
                value: value,
                data: abi.encodeWithSelector(MockContract.mockFunction.selector, data)
            })
        );
    }
}
