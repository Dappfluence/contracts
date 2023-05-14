// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {CollaborationFactory} from "../src/CollaborationFactory.sol";
import {Collaboration} from "../src/Collaboration.sol";
import {SBT} from "../src/SBT.sol";
import {Common} from "../src/Common.sol";


contract CollaborationFactoryTest is Test, Common {
  CollaborationFactory public collaborationFactory;
  Collaboration public implementation;
  SBT public sbt;
  address public brand = address(9898934);
  address public influencer1 = address(32323);
  address public influencer2 = address(32324);
  address public beneficiar = address(32325);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function setUp() public {
    vm.createSelectFork("https://bsc-dataseed4.defibit.io");
    vm.startPrank(brand);
    collaborationFactory = new CollaborationFactory(beneficiar);
    implementation = new Collaboration();
    collaborationFactory.setImplementation(implementation);
    sbt = new SBT(collaborationFactory);
    collaborationFactory.setSBT(sbt);
    vm.deal(brand, 100 ether);
    vm.deal(influencer1, 100 ether);
    vm.deal(influencer2, 100 ether);
  }

  function testCreateCollaboration() public {
    vm.expectRevert(NoValue.selector);
    collaborationFactory.createCollaboration(block.timestamp + 100);

    vm.expectRevert(DeadlinePassed.selector);
    collaborationFactory.createCollaboration{value: 1 ether}(block.timestamp - 100);

    vm.expectEmit(true, false, false, false);
    Collaboration collaboration = collaborationFactory.createCollaboration{value: 1 ether}(block.timestamp + 10000);
    console.log("COLLAB BALANCE", address(collaboration).balance);

    // console.log("collaborationAddress: %s", address(collaboration));
    assertTrue(address(collaboration) != address(0));
    emit CollaborationCreated(address(collaboration));
    
    // try reinitialize
    vm.expectRevert(Initialized.selector);
    collaboration.initialize{value: 1 ether}(block.timestamp + 100, address(brand));

    // influencer cannot mint NFT
    changePrank(influencer1);
    vm.expectRevert(CannotMintSBT.selector);
    collaborationFactory.mintSBT();

    // influences create proposals
    collaboration.createProposal("proposal1");
    changePrank(influencer2);
    collaboration.createProposal("proposal2");

    // get all proposals
    Collaboration.Proposal[] memory proposals = collaboration.getProposals();
    assertEq(proposals.length, 2);
    assertEq(proposals[0].info, "proposal1");
    assertEq(proposals[1].info, "proposal2");
    assertEq(proposals[0].influencer, influencer1);
    assertEq(proposals[1].influencer, influencer2);

    // brand accepts one of proposals
    changePrank(brand);
    collaboration.acceptProposal(0); // proposal1

    // influencer1 submits pow
    changePrank(influencer1);
    collaboration.submitProofOfWork("proof1");

    // brand approves work
    changePrank(brand);
    collaboration.approveWork();
    // TODO check token moved to influencer1
    console.log("INFL BALANCE AFTER FINISH WORK", address(influencer1).balance - 100 ether);

    // influencer1 now mints sbt
    changePrank(influencer1);
    collaborationFactory.mintSBT();
    assertEq(sbt.ownerOf(1), influencer1);
    vm.expectRevert(YouHaveSBT.selector);
    collaborationFactory.mintSBT();
  }

  function mintAllowance() external {
    changePrank(influencer1);

    // changePrank(address(collaboration));
  }

  function testSBT() external {
    // mint - onlyFactory
    changePrank(influencer1);
    vm.expectRevert(OnlyFactory.selector);
    sbt.mint(influencer1);

    changePrank(address(collaborationFactory));
    sbt.mint(influencer1);

    // cannot approve
    changePrank(influencer1);
    vm.expectRevert(ApprovalsRestricted.selector);
    sbt.approve(influencer2, 1);

    // cannot transfer
    changePrank(influencer1);
    vm.expectRevert(TransfersRestricted.selector);
    sbt.transferFrom(influencer1, influencer2, 1);
  }
}
