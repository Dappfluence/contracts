// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract AbstractNFT {    
    function totalSupply() external view virtual returns (uint256);
    function tokenURI(uint256 tokenId) external view virtual returns (string memory);
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
    function ownerOf(uint256 tokenId) external view virtual returns (address);
    function balanceOf(address owner) external view virtual returns (uint256);

    /*  */
    function approve(address, uint256) external {
        revert("NFTMirror: Function not supported");
    }

    function getApproved(uint256) external returns (address) {
        revert("NFTMirror: Function not supported");
    }

    function setApprovalForAll(address, bool) external {
        revert("NFTMirror: Function not supported");
    }

    function isApprovedForAll(address, address) external returns (bool) {
        revert("NFTMirror: Function not supported");
    }

    function transferFrom(address, address, uint256) external {
        revert("NFTMirror: Function not supported");
    }

    function safeTransferFrom(address, address, uint256) external {
        revert("NFTMirror: Function not supported");
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external {
        revert("NFTMirror: Function not supported");
    }
}
