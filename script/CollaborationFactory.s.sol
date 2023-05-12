// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/CollaborationFactory.sol";
import "../src/Collaboration.sol";

contract CollaborationFactoryScript is Script {
    CollaborationFactory public collaborationFactory;
    Collaboration public collaboration;

    function setUp() public {}

    function run() public {
        // vm.createSelectFork("https://data-seed-prebsc-2-s3.binance.org:8545");
        vm.startBroadcast();
        collaborationFactory = new CollaborationFactory();
        collaboration = new Collaboration(collaborationFactory);
        collaborationFactory.setImplementation(collaboration);
        vm.stopBroadcast();
    }
}
