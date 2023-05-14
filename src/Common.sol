// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Common {
  error DeadlinePassed();
  error OnlyFactory();
  error OnlyCollaboration();
  error OnlyBrand();
  error Initialized();
  error TransfersRestricted();
  error ApprovalsRestricted();
  error CannotMintSBT();
  error YouHaveSBT();
  error NoValue();
  error AlreadyProposed();
  error WorkInProgress();
  error NoAcceptedProposal();
  error OnlyApprovedUser();
  error AcceptedProposalExists();
  error NoProposalAccepted();
  error NoPowProvided();
  error Finished();
  error Reentrancy();

  event CollaborationCreated(address indexed collaboration);
  event ProposalCreated(address indexed influencer, string info);
  event ProposalAccepted(address indexed influencer, uint256 indexed proposalId);
}