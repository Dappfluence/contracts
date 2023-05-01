// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * This contract is an implementation for minimal proxy pattern
 */

import {Common} from "./Common.sol";
import {CollaborationFactory} from "./CollaborationFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Collaboration is Common {
  using SafeERC20 for IERC20;

  CollaborationFactory public immutable factory;
  uint256 private initialized;
  address public brand;
  bool public proposalAccepted;
  bool public workInProgress;
  uint256 currentProposal;
  bool public powProvided;
  string private proofOfWork;
  bool public finished;

  IERC20 token;
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

  constructor(CollaborationFactory _factory) {
    factory = _factory;
  }

  function initialize(uint256 deadline, address _brand, IERC20 _token, uint256 _amount) external onlyFactory {
    if (initialized != 0) {
      revert Initialized();
    }
    if (deadline < block.timestamp) {
      revert DeadlinePassed(); // one more time
    }
    initialized = block.timestamp;
    brand = _brand;
    token = _token;
    amount = _amount;
  }

  function createProposal(string memory info) external notFinished {
    if (proposed[msg.sender]) {
      revert AlreadyProposed();
    }
    if (proposalAccepted) {
      revert AcceptedProposalExists();
    }
    if (workInProgress) {
      revert WorkInProgress();
    }
    proposals.push(Proposal(info, msg.sender));
    proposed[msg.sender] = true;
    emit ProposalCreated(msg.sender, info);
  }

  function acceptProposal(uint256 index) external onlyBrand notFinished {
    if (workInProgress) {
      revert WorkInProgress();
    }
    if (proposalAccepted) {
      revert AcceptedProposalExists();
    }
    currentProposal = index;
    emit ProposalAccepted(proposals[index].influencer, index);
  }

  function startCollaboration() external notFinished {
    if (workInProgress) {
      revert WorkInProgress();
    }
    if (!proposalAccepted) {
      revert NoProposalAccepted();
    }
    if (msg.sender != proposals[currentProposal].influencer) {
      revert OnlyApprovedUser();
    }
    workInProgress = true;
  }

  function submitPOW(string memory _proofOfWork) external notFinished {
    if (!workInProgress) {
      revert NoWorkInProgress();
    }
    if (msg.sender != proposals[currentProposal].influencer) {
      revert OnlyApprovedUser();
    }
    proofOfWork = _proofOfWork;
    powProvided = true;
  }

  function approveWork() external onlyBrand {
    if (!workInProgress) {
      revert NoWorkInProgress();
    }
    if (!powProvided) {
      revert NoPowProvided();
    }
    address influencer = proposals[currentProposal].influencer;
    payable(influencer).transfer(address(this).balance);
    token.safeTransfer(influencer, amount);
    finished = true;
    factory.allowMint(influencer);
  }
}
