// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/proxy/clones.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Common} from "./Common.sol";
import {Collaboration} from "./Collaboration.sol";
import {SBT} from "./SBT.sol";

contract CollaborationFactory is Common, Ownable {
    Collaboration public implementation;
    Collaboration[] public collaborations;
    SBT public sbt;

    mapping(address => bool) public allowedToMintNFT;
    mapping(address => bool) private isCollaboration;

    constructor() { }

    modifier onlyCollaboration() {
        if (!isCollaboration[msg.sender]) {
            revert OnlyCollaboration();
        }
        _;
    }

    function setImplementation(Collaboration _implementation) external onlyOwner {
        implementation = _implementation;
    }

    function setSBT(SBT _sbt) external onlyOwner {
        sbt = _sbt;
    }

    function createCollaboration(uint256 deadline) external payable returns (Collaboration) {
        if (msg.value == 0) {
            revert NoValue();
        }
        if (deadline < block.timestamp) {
            revert DeadlinePassed();
        }
        Collaboration clone = Collaboration(Clones.clone(address(implementation)));

        // no constructor there, so we need to initialize
        clone.initialize{value: msg.value}(deadline, msg.sender);
        
        collaborations.push(clone);
        isCollaboration[address(clone)] = true;

        emit CollaborationCreated(address(clone));
        return clone;
    }

    function mintSBT() external {
        if (!allowedToMintNFT[msg.sender]) {
            revert CannotMintSBT();
        }
        sbt.mint(msg.sender);
    }

    function allowMint(address influencer) external onlyCollaboration {
        allowedToMintNFT[influencer] = true;
    }
}
