// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {BasedAngelVaultTest} from "../../BasedAngelVaultTest.t.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BasedAngelVault} from "../../../src/BasedAngelVault.sol";

contract BaseAngelVaultUpdateOperatorTest is Test, BasedAngelVaultTest {
    address newOperator = makeAddr("newOperator");

    function test_updateOperator_OwnerCanUpdateOperator() public {
        address oldOperator = basedAngelVault.s_operator();

        vm.prank(owner);
        basedAngelVault.updateOperator(newOperator);

        assert(oldOperator != basedAngelVault.s_operator());
        assertEq(newOperator, basedAngelVault.s_operator());
    }

    function test_updateOperator_EmitOperatorUpdatedEvent() public {
        address oldOperator = basedAngelVault.s_operator();

        vm.expectEmit(true, true, false, true);
        emit BasedAngelVault.OperatorUpdated(oldOperator, newOperator);

        vm.prank(owner);
        basedAngelVault.updateOperator(newOperator);
    }

    function test_updateOperator_RevertsIfCalledByNonOwner() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );

        vm.prank(randomUser);
        basedAngelVault.updateOperator(newOperator);
    }

    function test_updateOperator_RevertsIfCalledByOperator() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                operator
            )
        );

        vm.prank(operator);
        basedAngelVault.updateOperator(newOperator);
    }

    function test_updateOperator_RevertsIfNewOperatorIszeroAddress() public {
        vm.expectRevert(BasedAngelVault.ZeroAddress.selector);

        vm.prank(owner);
        basedAngelVault.updateOperator(address(0));
    }
}
