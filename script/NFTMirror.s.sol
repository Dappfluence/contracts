// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTMirror.sol";

contract NFTMirrorScript is Script {
    function setUp() public {}

    function run() public {
        vm.createSelectFork("https://bsc-dataseed1.binance.org/");
        vm.startBroadcast();
        new NFTMirror(AbstractNFT(0x2723522702093601e6360CAe665518C4f63e9dA6));
        vm.stopBroadcast();
    }
}
