// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Test} from "forge-std/Test.sol";
import {DeployBasedAngelVault} from "../script/DeployBasedAngelVault.s.sol";
import {BasedAngelVault} from "../src/BasedAngelVault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BasedAngelVaultTest is Test {
    DeployBasedAngelVault public deployer;
    BasedAngelVault public basedAngelVault;

    address public owner;
    address public operator;
    address public mockToken;
    address public randomUser;

    function setUp() public {
        deployer = new DeployBasedAngelVault();
        basedAngelVault = deployer.run();

        owner = deployer.OWNER();
        operator = deployer.OPERATOR();
        mockToken = makeAddr("mockToken");
        randomUser = makeAddr("randomUser");
    }
}
