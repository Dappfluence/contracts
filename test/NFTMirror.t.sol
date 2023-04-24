// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../src/AbstractNFT.sol";
import "forge-std/Test.sol";
import "../src/NFTMirror.sol";
import {console} from "forge-std/console.sol";

contract NFTMirrorTest is Test {
    NFTMirror public nftMirror;
    AbstractNFT constant nftContractAddress = AbstractNFT(0x2723522702093601e6360CAe665518C4f63e9dA6); // link3 profile

    function setUp() public {
        vm.createSelectFork("https://bsc-dataseed1.binance.org/");
        nftMirror = new NFTMirror(nftContractAddress);
    }

    function testTotalSupplyEquality() public {
        uint256 totalSupplyBase = nftContractAddress.totalSupply();
        uint256 totalSupplyMirror = nftMirror.totalSupply();
        assertEq(totalSupplyBase, totalSupplyMirror);
        assertGt(totalSupplyBase, 0);
    }

    /** not sure we need translating equal name and symbol */
    function testNameAndSymbolEquality() public {
        string memory nameBase = nftContractAddress.name();
        string memory nameMirror = nftMirror.name();
        assertEq(nameBase, nameMirror);

        string memory symbolBase = nftContractAddress.symbol();
        string memory symbolMirror = nftMirror.symbol();
        assertEq(symbolBase, symbolMirror);
    }

    function testBalanceOf() public {
        uint256 balanceBase = nftContractAddress.balanceOf(address(this));
        uint256 balanceMirror = nftMirror.balanceOf(address(this));
        assertEq(balanceBase, balanceMirror);
    }

    function testOwnerOf() public {
        uint256 tokenId = 1;
        address ownerBase = nftContractAddress.ownerOf(tokenId);
        address ownerMirror = nftMirror.ownerOf(tokenId);
        assertEq(ownerBase, ownerMirror);
    }
}
