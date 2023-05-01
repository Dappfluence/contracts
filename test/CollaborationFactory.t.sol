// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {CollaborationFactory} from "../src/CollaborationFactory.sol";
import {Collaboration} from "../src/Collaboration.sol";
import {SBT} from "../src/SBT.sol";
import {Common} from "../src/Common.sol";


contract CollaborationFactoryTest is Test, Common {
  using SafeERC20 for IERC20;

  CollaborationFactory public collaborationFactory;
  Collaboration public implementation;
  SBT public sbt;
  IERC20 public constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955); // 18 decimals
  address public pranker = 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3; // top usdt holder

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function setUp() public {
    vm.createSelectFork("https://bsc-dataseed4.defibit.io");
    vm.startPrank(pranker);
    collaborationFactory = new CollaborationFactory();
    implementation = new Collaboration(collaborationFactory);
    collaborationFactory.setImplementation(implementation);
    sbt = new SBT(collaborationFactory);
    collaborationFactory.setSBT(sbt);
  }

  function testCreateCollaboration() public {
    USDT.safeApprove(address(collaborationFactory), type(uint256).max);

    // vm.expectRevert(NoValue.selector);
    // collaborationFactory.createCollaboration(block.timestamp + 100, USDT, 0);

    vm.expectEmit(true, false, false, false);
    vm.expectEmit(true, true, false, false);
    vm.expectEmit(true, true, false, true);
    Collaboration collaboration = collaborationFactory.createCollaboration(block.timestamp + 100, USDT, 1 ether);
    console.log("collaborationAddress: %s", address(collaboration));
    assertTrue(address(collaboration) != address(0));
    emit Transfer(pranker, address(collaboration), 1 ether);
    emit Approval(pranker, address(collaborationFactory), 0); // third parameter is ignored
    emit CollaborationCreated(address(collaboration));
  }
}
