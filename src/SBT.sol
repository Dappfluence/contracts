// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721, IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {CollaborationFactory} from "./CollaborationFactory.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Common} from "./Common.sol";

contract SBT is Ownable, Common, ERC721Enumerable {
  CollaborationFactory public factory;
  uint256 private counter;

  constructor(CollaborationFactory _factory) ERC721("SBT", "SBT") {
    factory = _factory;
  } // TODO name and symbol

  modifier onlyFactory() {
    if (msg.sender != address(factory)) {
      revert OnlyFactory();
    }
    _;
  }

  function mint(address to) external onlyFactory {
    if (balanceOf(to) != 0) {
      revert YouHaveSBT();
    }
    _mint(to, counter);
    ++counter;
  }

  // restrict transfers
  function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256) internal override {
    super._beforeTokenTransfer(from, to, tokenId, 1);
    if (from != address(0)) {
      revert TransfersRestricted();
    }
  }

  // restrict approvals
  function _approve(address to, uint256 tokenId) internal override {
    super._approve(to, tokenId);
    revert ApprovalsRestricted();
  }
}