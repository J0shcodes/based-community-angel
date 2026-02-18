// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {BasedAngelVaultTest} from "../../BasedAngelVaultTest.t.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BasedAngelVault} from "../../../src/BasedAngelVault.sol";

contract BaseAngelVaultUpdateDailyCapTest is Test, BasedAngelVaultTest {

    uint256 newCap = 0.2 ether;
    
    function test_updateDailyCap_OwnerCanUpdateDailyCap() public {
        uint256 oldCap = basedAngelVault.s_dailyGlobalCap();

        vm.prank(owner);
        basedAngelVault.updateDailyCap(newCap);

        assert(oldCap != basedAngelVault.s_dailyGlobalCap());
        assertEq(newCap, basedAngelVault.s_dailyGlobalCap());
    }

    function test_updateDailyCap_EmitCapUpdatedEvent() public {
        uint256 oldCap = basedAngelVault.s_dailyGlobalCap();

        vm.expectEmit(true, false, false, true);
        emit BasedAngelVault.CapUpdated("Daily Global Cap", oldCap, newCap);

        vm.prank(owner);
        basedAngelVault.updateDailyCap(newCap);
    }

    function test_updateDailyCap_RevertsIfCalledByNonOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, randomUser));

        vm.prank(randomUser);
        basedAngelVault.updateDailyCap(newCap);
    }

    function test_updateDailyCap_RevertsIfCalledByOperator() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, operator));

        vm.prank(operator);
        basedAngelVault.updateDailyCap(newCap);
    }
    
}