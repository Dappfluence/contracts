// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/proxy/clones.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Common} from "./Common.sol";
import {Collaboration} from "./Collaboration.sol";
import {SBT} from "./SBT.sol";

contract CollaborationFactory is Common, Ownable {
    using SafeERC20 for IERC20;

    Collaboration public implementation;
    SBT public sbt;

    mapping(address => bool) public allowedToMintNFT;
    mapping(address => bool) private isCollaboration;

    struct Collab {
        address _contract;
        address brand;
        uint256 deadline;
        IERC20 token;
        uint256 amount;
    }
    Collab[] public collaborations;

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

    function createCollaboration(uint256 deadline, IERC20 token, uint256 amount) external returns (Collaboration) {
        if (amount == 0) {
            revert NoValue();
        }
        if (deadline < block.timestamp) {
            revert DeadlinePassed();
        }
        Collaboration clone = Collaboration(Clones.clone(address(implementation)));
        

        // no constructor there, so we need to initialize
        clone.initialize(deadline, msg.sender, token, amount);
        token.safeTransferFrom(msg.sender, address(clone), amount);

        Collab memory collab = Collab(address(clone), msg.sender, deadline, token, amount);
        
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
