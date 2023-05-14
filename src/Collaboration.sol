// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * This contract is an implementation for minimal proxy pattern
 */

import {Common} from "./Common.sol";
import {CollaborationFactory} from "./CollaborationFactory.sol";
import {console} from "forge-std/console.sol";

contract Collaboration is Common {
  CollaborationFactory public factory;
  uint256 private initialized;
  address public brand;
  bool public proposalAccepted;
  bool public workInProgress;
  uint256 currentProposal;
  bool public powProvided;
  string private proofOfWork;
  bool public finished;

  uint256 locked;
  uint256 constant LOCKED = 1;
  uint256 constant NOT_LOCKED = 2;

  uint256 amount;

  struct Proposal {
    string info;
    address influencer;
  }

  Proposal[] public proposals;
  mapping(address => bool) public proposed;

  modifier onlyFactory() {
    if (msg.sender != address(factory)) {
      revert OnlyFactory();
    }
    _;
  }

  modifier onlyBrand() {
    if (msg.sender != brand) {
      revert OnlyBrand();
    }
    _;
  }

  modifier notFinished() {
    if (finished) {
      revert Finished();
    }
    _;
  }

  constructor() {
    // not applicable for minimal proxy
  }

  function initialize(uint256 deadline, address _brand) external payable {
    if (initialized != 0) {
      revert Initialized();
    }
    if (deadline < block.timestamp) {
      revert DeadlinePassed(); // one more time
    }
    initialized = block.timestamp;
    brand = _brand;
    amount = msg.value;
    factory = CollaborationFactory(msg.sender);
    locked = NOT_LOCKED;
  }

  function createProposal(string memory info) external notFinished {
    if (proposed[msg.sender]) {
      revert AlreadyProposed();
    }
    if (proposalAccepted) {
      revert AcceptedProposalExists();
    }
    proposals.push(Proposal(info, msg.sender));
    proposed[msg.sender] = true;
    emit ProposalCreated(msg.sender, info);
  }

  function acceptProposal(uint256 index) external onlyBrand notFinished {
    if (proposalAccepted) {
      revert AcceptedProposalExists();
    }
    proposalAccepted = true;
    currentProposal = index;
    emit ProposalAccepted(proposals[index].influencer, index);
  }

  function submitProofOfWork(string memory _proofOfWork) external notFinished {
    if (!proposalAccepted) {
      revert NoAcceptedProposal();
    }
    if (msg.sender != proposals[currentProposal].influencer) {
      revert OnlyApprovedUser();
    }
    proofOfWork = _proofOfWork;
    powProvided = true;
  }

  function approveWork() external onlyBrand {
    if (locked == LOCKED) {
      revert Reentrancy();
    }
    locked = LOCKED;
    if (!proposalAccepted) {
      revert NoAcceptedProposal();
    }
    if (!powProvided) {
      revert NoPowProvided();
    }
    address influencer = proposals[currentProposal].influencer;
    finished = true;
    factory.allowMint(influencer);
    uint256 fee = amount * factory.collaborationFee() / 100_00;
    payable(influencer).transfer(address(this).balance - fee);
    payable(factory.beneficiar()).transfer(fee);
    locked = NOT_LOCKED;
  }
}
