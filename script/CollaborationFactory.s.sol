// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/CollaborationFactory.sol";
import "../src/Collaboration.sol";
import "../src/SBT.sol";
import {console} from "forge-std/console.sol";

contract CollaborationFactoryScript is Script {
    CollaborationFactory public collaborationFactory;
    Collaboration public collaboration;
    SBT public sbt;

    function setUp() public {}

    function run() public {
        // vm.createSelectFork("https://data-seed-prebsc-2-s3.binance.org:8545");
        vm.startBroadcast();
        collaborationFactory = new CollaborationFactory(0x87555C010f5137141ca13b42855d90a108887005);
        collaboration = new Collaboration();
        collaborationFactory.setImplementation(collaboration);
        sbt = new SBT(collaborationFactory);
        collaborationFactory.setSBT(sbt);
        vm.stopBroadcast();

        console.log("collaborationFactory: %s", address(collaborationFactory));
        console.log("collaboration impl: %s", address(collaboration));
        console.log("sbt: %s", address(sbt));
    }
}
