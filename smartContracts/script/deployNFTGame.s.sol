// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {NFTGame} from "../src/NFTGame.sol";

//TODO: Implement the deploy with Devops.
contract DeployNFTGame is Script {
    function run() external {
        vm.startBroadcast();
        
        vm.stopBroadcast();
    }
}
