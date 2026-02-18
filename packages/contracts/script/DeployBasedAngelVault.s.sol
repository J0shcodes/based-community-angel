// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.32;

import {Script} from "forge-std/Script.sol";
import {BasedAngelVault} from "../src/BasedAngelVault.sol";

contract DeployBasedAngelVault is Script {
    address public OWNER = makeAddr("owner");
    address public OPERATOR = makeAddr("operator");
    uint256 public MAX_PER_REQUEST = 0.002 ether;
    uint256 public DAILY_GLOBAL_CAP = 0.1 ether;
    uint256 public USER_COOLDOWN = 30 days;

    BasedAngelVault public basedAngelVault;

    function run() external returns (BasedAngelVault) {
        vm.startBroadcast();
        basedAngelVault = new BasedAngelVault(OWNER, OPERATOR, MAX_PER_REQUEST, DAILY_GLOBAL_CAP, USER_COOLDOWN);
        vm.stopBroadcast();
        return basedAngelVault;
    }
}
