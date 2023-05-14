// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/proxy/clones.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Common} from "./Common.sol";
import {Collaboration} from "./Collaboration.sol";
import {SBT} from "./SBT.sol";

contract CollaborationFactory is Common, Ownable {
    Collaboration public implementation;
    SBT public sbt;
    address public beneficiar;

    uint256 public collaborationFee = 5_00; // 5%

    mapping(address => bool) public allowedToMintNFT;
    mapping(address => bool) private isCollaboration;

    struct Collab {
        address _contract;
        address brand;
        uint256 deadline;
        uint256 amount;
    }
    Collab[] public collaborations;

    constructor(address _beneficiar) {
        beneficiar = _beneficiar;
    }

    modifier onlyCollaboration() {
        if (!isCollaboration[msg.sender]) {
            revert OnlyCollaboration();
        }
        _;
    }

    function setImplementation(Collaboration _implementation) external onlyOwner {
        implementation = _implementation;
    }

    function setCollaborationFee(uint256 _collaborationFee) external onlyOwner {
        collaborationFee = _collaborationFee;
    }

    function setBeneficiar(address _beneficiar) external onlyOwner {
        beneficiar = _beneficiar;
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
        clone.initialize{ value: msg.value }(deadline, msg.sender);

        Collab memory collab = Collab(address(clone), msg.sender, deadline, msg.value);
        
        collaborations.push(collab);
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
