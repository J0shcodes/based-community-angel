// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {BasedAngelVaultTest} from "../../BasedAngelVaultTest.t.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BasedAngelVault} from "../../../src/BasedAngelVault.sol";

contract BaseAngelVaultAddSupportedTokenTest is Test, BasedAngelVaultTest {

    function test_addSupportedToken_OwnerCanAddToken() public {
        // Assert token is not supported before
        assertFalse(basedAngelVault.getIsSupportedToken(mockToken));

        vm.prank(owner);
        basedAngelVault.addSupportedToken(mockToken);

        assertTrue(basedAngelVault.getIsSupportedToken(mockToken));
    }

    function test_addSupportedToken_EmitTokenAddedEvent() public {
        vm.expectEmit(true, false, false, true);
        emit BasedAngelVault.TokenAdded(mockToken, block.timestamp);

        vm.prank(owner);
        basedAngelVault.addSupportedToken(mockToken);
    }

    function test_addSupportedToken_RevertsIfCalledByNonOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, randomUser));

        vm.prank(randomUser);
        basedAngelVault.addSupportedToken(mockToken);
    }

    function test_addSupportedToken_RevertsIfCalledByOperator() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, operator));

        vm.prank(operator);
        basedAngelVault.addSupportedToken(mockToken);
    }

    function test_addSupportedToken_CanAddMultipleTokens() public {
        address mockToken2 = makeAddr("mockToken2");
        address mockToken3 = makeAddr("mockToken3");

        vm.startPrank(owner);
        basedAngelVault.addSupportedToken(mockToken);
        basedAngelVault.addSupportedToken(mockToken2);
        basedAngelVault.addSupportedToken(mockToken3);
        vm.stopPrank();

        assertTrue(basedAngelVault.getIsSupportedToken(mockToken));
        assertTrue(basedAngelVault.getIsSupportedToken(mockToken2));
        assertTrue(basedAngelVault.getIsSupportedToken(mockToken3));
    }

    function test_addSupportedToken_AddingExistingTokenIsIdempotent() public {
        vm.startPrank(owner);
        basedAngelVault.addSupportedToken(mockToken);
        basedAngelVault.addSupportedToken(mockToken);
        vm.stopPrank();

        assertTrue(basedAngelVault.getIsSupportedToken(mockToken));
    }
}