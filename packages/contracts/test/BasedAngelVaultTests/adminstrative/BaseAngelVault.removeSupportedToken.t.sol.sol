// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {BasedAngelVaultTest} from "../../BasedAngelVaultTest.t.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BasedAngelVault} from "../../../src/BasedAngelVault.sol";

contract BaseAngelVaultRemoveSupportedTokenTest is Test, BasedAngelVaultTest {

    function test_removeSupportedToken_OwnerCanRemoveToken() public {
        vm.startPrank(owner);
        basedAngelVault.addSupportedToken(mockToken);

        // Assert token is supported before
        assertTrue(basedAngelVault.getIsSupportedToken(mockToken));

        basedAngelVault.removeSupportedToken(mockToken);
        vm.stopPrank();

        assertFalse(basedAngelVault.getIsSupportedToken(mockToken));
    }

    function test_removeSupportedToken_EmitTokenRemovedEvent() public {
        vm.expectEmit(true, false, false, true);
        emit BasedAngelVault.TokenRemoved(mockToken, block.timestamp);

        vm.prank(owner);
        basedAngelVault.removeSupportedToken(mockToken);
    }

    function test_removeSupportedToken_RevertsIfCalledByNonOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, randomUser));

        vm.prank(randomUser);
        basedAngelVault.removeSupportedToken(mockToken);
    }

    function test_removeSupportedToken_RevertsIfCalledByOperator() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, operator));

        vm.prank(operator);
        basedAngelVault.removeSupportedToken(mockToken);
    }

    function test_removeSupportedToken_CanRemoveMultipleTokens() public {
        address mockToken2 = makeAddr("mockToken2");
        address mockToken3 = makeAddr("mockToken3");

        vm.startPrank(owner);
        basedAngelVault.removeSupportedToken(mockToken);
        basedAngelVault.removeSupportedToken(mockToken2);
        basedAngelVault.removeSupportedToken(mockToken3);
        vm.stopPrank();

        assertFalse(basedAngelVault.getIsSupportedToken(mockToken));
        assertFalse(basedAngelVault.getIsSupportedToken(mockToken2));
        assertFalse(basedAngelVault.getIsSupportedToken(mockToken3));
    }

    function test_removeSupportedToken_AddingExistingTokenIsIdempotent() public {
        vm.startPrank(owner);
        basedAngelVault.removeSupportedToken(mockToken);
        basedAngelVault.removeSupportedToken(mockToken);
        vm.stopPrank();

        assertFalse(basedAngelVault.getIsSupportedToken(mockToken));
    }
}