// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {BasedAngelVaultTest} from "../../BasedAngelVaultTest.t.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BasedAngelVault} from "../../../src/BasedAngelVault.sol";

contract BaseAngelVaultUpdateMaxPerRequestTest is Test, BasedAngelVaultTest {
    uint256 newCap = 0.003 ether;

    function test_updateMaxPerRequest_OwnerCanUpdateMaxPerRequest() public {
        uint256 oldCap = basedAngelVault.s_maxPerRequest();

        vm.prank(owner);
        basedAngelVault.updatePerRequestCap(newCap);

        assert(oldCap != basedAngelVault.s_maxPerRequest());
        assertEq(newCap, basedAngelVault.s_maxPerRequest());
    }

    function test_updateMaxPerRequest_EmitCapUpdatedEvent() public {
        uint256 oldCap = basedAngelVault.s_maxPerRequest();

        vm.expectEmit(true, false, false, true);
        emit BasedAngelVault.CapUpdated("Per Request Cap", oldCap, newCap);

        vm.prank(owner);
        basedAngelVault.updatePerRequestCap(newCap);
    }

    function test_updateMaxPerRequest_RevertsIfCalledByNonOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );

        vm.prank(randomUser);
        basedAngelVault.updatePerRequestCap(newCap);
    }

    function test_updateMaxPerRequest_RevertsIfCalledByOperator() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                operator
            )
        );

        vm.prank(operator);
        basedAngelVault.updatePerRequestCap(newCap);
    }

    function test_updateMaxPerRequest_RevertsIfNewCapIsZero() public {
        vm.expectRevert(BasedAngelVault.InvalidAmount.selector);

        vm.prank(owner);
        basedAngelVault.updatePerRequestCap(0);
    }

    function test_updateMaxPerRequest_RevertsIfNewCapExceedsDailyCap() public {
        uint256 largeCap = basedAngelVault.s_dailyGlobalCap() + 1 ether;

        vm.expectRevert(BasedAngelVault.ExceedsPerRequestCap.selector);

        vm.prank(owner);
        basedAngelVault.updatePerRequestCap(largeCap);
    }
}
