// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/CollaborationFactory.sol";
import "../src/Collaboration.sol";

contract NFTMirrorScript is Script {
    CollaborationFactory public collaborationFactory;
    Collaboration public collaboration;

    function setUp() public {}

    function run() public {
        vm.createSelectFork("https://bsc-dataseed1.binance.org/");
        vm.startBroadcast();
        collaborationFactory = new CollaborationFactory();
        collaboration = new Collaboration(collaborationFactory);
        collaborationFactory.setImplementation(collaboration);
        vm.stopBroadcast();
    }
}
