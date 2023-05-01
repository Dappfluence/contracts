// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CollaborationFactory} from "../src/CollaborationFactory.sol";
import {Collaboration} from "../src/Collaboration.sol";
import {SBT} from "../src/SBT.sol";
import {Common} from "../src/Common.sol";


contract CollaborationFactoryTest is Test, Common {
  CollaborationFactory public collaborationFactory;
  Collaboration public implementation;
  SBT public sbt;

  function setUp() public {
    collaborationFactory = new CollaborationFactory();
    implementation = new Collaboration(collaborationFactory);
    collaborationFactory.setImplementation(implementation);
    sbt = new SBT(collaborationFactory);
    collaborationFactory.setSBT(sbt);
  }

  function testCreateCollaboration() public {
    vm.expectRevert(NoValue.selector);
    collaborationFactory.createCollaboration(block.timestamp + 100);

    vm.expectEmit(true, false, false, false);
    Collaboration collaboration = collaborationFactory.createCollaboration{value: 1 ether}(block.timestamp + 100);
    console.log("collaborationAddress: %s", address(collaboration));
    assertTrue(address(collaboration) != address(0));
    emit CollaborationCreated(address(collaboration));
  }
}
