// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {OspTestSetUp} from '../OspTestSetUp.sol';
import {FixFeeCommunityCond} from '../../../contracts/core/conditions/community/FixFeeCommunityCond.sol';
import {PresaleSigCommunityCond} from '../../../contracts/core/conditions/community/PresaleSigCommunityCond.sol';
import {CondDataTypes} from '../../../contracts/core/conditions/libraries/CondDataTypes.sol';
import {OspDataTypes} from '../../../contracts/libraries/OspDataTypes.sol';
import {CondErrors} from '../../../contracts/core/conditions/libraries/CondErrors.sol';
import {console2} from 'forge-std/Test.sol';

contract FixFeeCondTest is OspTestSetUp {
    FixFeeCommunityCond fixFeeCommunityCond;

    PresaleSigCommunityCond presaleSigCommunityCond;

    uint256 createStartTime = 100;

    uint256 presaleStartTime = 98;

    function setUp() public virtual override {
        vm.warp(100);
        super.setUp();
        fixFeeCommunityCond = new FixFeeCommunityCond(address(ospClient));
        vm.startPrank(deployer);
        ospClient.whitelistApp(address(fixFeeCommunityCond), true);
        fixFeeCommunityCond.setStableFeeCondData(
            CondDataTypes.FixFeeCondData({
                price1Letter: 7 ether,
                price2Letter: 6 ether,
                price3Letter: 5 ether,
                price4Letter: 4 ether,
                price5Letter: 3 ether,
                price6Letter: 2 ether,
                price7ToMoreLetter: 1 ether,
                createStartTime: createStartTime,
                treasure: deployer
            })
        );
        presaleSigCommunityCond = new PresaleSigCommunityCond(
            address(ospClient),
            address(fixFeeCommunityCond),
            user2,
            presaleStartTime
        );
        ospClient.whitelistApp(address(presaleSigCommunityCond), true);
        vm.stopPrank();
        vm.startPrank(user1);
        ospClient.createProfile(
            OspDataTypes.CreateProfileData('handle_1', EMPTY_BYTES, 0, EMPTY_BYTES)
        );
        vm.stopPrank();
    }

    function testCreateCommunity_WithFixFeeCond() public {
        vm.deal(user1, 8 ether);
        vm.startPrank(user1);
        ospClient.createCommunity{value: 8 ether}(
            OspDataTypes.CreateCommunityData({
                handle: 'a',
                communityConditionAndData: abi.encodePacked(
                    address(fixFeeCommunityCond),
                    CORRECT_BYTES
                ),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        assertTrue(user1.balance == 1 ether);
        assertTrue(deployer.balance == 7 ether);
        vm.stopPrank();
    }

    function testCreateCommunity_WithPresaleCond() public {
        console2.log('user2:', user2);
        vm.deal(user1, 8 ether);
        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19Ethereum Signed Message:\n32',
                keccak256(abi.encodePacked(uint256(1), user1))
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user2PK, hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes memory data = abi.encode(uint256(1), user1, signature);
        vm.startPrank(user1);
        ospClient.createCommunity{value: 8 ether}(
            OspDataTypes.CreateCommunityData({
                handle: 'a',
                communityConditionAndData: abi.encodePacked(address(presaleSigCommunityCond), data),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        assertTrue(user1.balance == 1 ether);
        assertTrue(deployer.balance == 7 ether);
        vm.stopPrank();
    }

    function testCannotCreateCommunity_WithFixFeeCondLessThanStartTime() public {
        vm.warp(createStartTime - 100);
        vm.deal(user1, 8 ether);
        vm.startPrank(user1);
        vm.expectRevert(CondErrors.NotCreateTime.selector);
        ospClient.createCommunity{value: 8 ether}(
            OspDataTypes.CreateCommunityData({
                handle: 'a',
                communityConditionAndData: abi.encodePacked(
                    address(fixFeeCommunityCond),
                    CORRECT_BYTES
                ),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }

    function testCannotCreateCommunity_WithPresaleLessStartTime() public {
        vm.warp(presaleStartTime - 1);
        vm.deal(user1, 8 ether);
        vm.startPrank(user1);
        vm.expectRevert(CondErrors.NotPresaleTime.selector);
        ospClient.createCommunity{value: 8 ether}(
            OspDataTypes.CreateCommunityData({
                handle: 'a',
                communityConditionAndData: abi.encodePacked(
                    address(presaleSigCommunityCond),
                    CORRECT_BYTES
                ),
                joinConditionInitCode: EMPTY_BYTES,
                tags: EMPTY_STRINGS,
                ctx: EMPTY_BYTES
            })
        );
        vm.stopPrank();
    }
}
