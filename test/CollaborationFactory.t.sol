// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
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
  address public brand = 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3; // top usdt holder
  address public influencer1 = address(32323);
  address public influencer2 = address(32324);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function setUp() public {
    vm.createSelectFork("https://bsc-dataseed4.defibit.io");
    vm.startPrank(brand);
    collaborationFactory = new CollaborationFactory();
    implementation = new Collaboration(collaborationFactory);
    collaborationFactory.setImplementation(implementation);
    sbt = new SBT(collaborationFactory);
    collaborationFactory.setSBT(sbt);
    vm.deal(influencer1, 100 ether);
    vm.deal(influencer2, 100 ether);
  }

  function testCreateCollaboration() public {
    USDT.safeApprove(address(collaborationFactory), type(uint256).max);

    vm.expectRevert(NoValue.selector);
    collaborationFactory.createCollaboration(block.timestamp + 100, USDT, 0);

    vm.expectRevert(DeadlinePassed.selector);
    collaborationFactory.createCollaboration(block.timestamp - 100, USDT, 1 ether);

    vm.expectEmit(true, false, false, false);
    vm.expectEmit(true, true, false, false);
    vm.expectEmit(true, true, false, true);
    Collaboration collaboration = collaborationFactory.createCollaboration(block.timestamp + 100, USDT, 1 ether);
    // try reinitialize
    vm.expectRevert(Initialized.selector);
    collaboration.initialize(block.timestamp + 100, address(brand), USDT, 1 ether);
    console.log("collaborationAddress: %s", address(collaboration));
    assertTrue(address(collaboration) != address(0));
    emit Transfer(brand, address(collaboration), 1 ether);
    emit Approval(brand, address(collaborationFactory), 0); // third parameter is ignored
    emit CollaborationCreated(address(collaboration));

    // influencer cannot mint NFT
    changePrank(influencer1);
    vm.expectRevert(CannotMintSBT.selector);
    collaborationFactory.mintSBT();

    // influences create proposals
    collaboration.createProposal("proposal1");
    changePrank(influencer2);
    collaboration.createProposal("proposal2");

    // brand accepts one of proposals
    changePrank(brand);
    collaboration.acceptProposal(0); // proposal1

    // influencer2 cannot start work
    changePrank(influencer2);
    vm.expectRevert(OnlyApprovedUser.selector);
    collaboration.startCollaboration();
    
    // influencer1 starts work
    changePrank(influencer1);
    collaboration.startCollaboration();

    // influencer1 submits pow
    changePrank(influencer1);
    collaboration.submitProofOfWork("proof1");

    // brand approves work
    changePrank(brand);
    collaboration.approveWork();
    // TODO check token moved to influencer1

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
