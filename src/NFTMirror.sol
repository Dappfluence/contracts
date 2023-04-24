// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./AbstractNFT.sol";

contract NFTMirror is AbstractNFT, ERC165, Ownable {
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    AbstractNFT private _nftContract;

    constructor(AbstractNFT nftContractAddress) {
        _nftContract = nftContractAddress;
    }

    function setNftContract(AbstractNFT nftContractAddress) external onlyOwner {
        _nftContract = nftContractAddress;
    }

    function name() external view override returns (string memory) {
        return AbstractNFT(address(_nftContract)).name();
    }

    function symbol() external view override returns (string memory) {
        return AbstractNFT(address(_nftContract)).symbol();
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {
        return _nftContract.ownerOf(tokenId);
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _nftContract.balanceOf(owner);
    }

    function totalSupply() external view override returns (uint256) {
        return AbstractNFT(address(_nftContract)).totalSupply();
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        return AbstractNFT(address(_nftContract)).tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165) returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC721 ||
            interfaceId == _INTERFACE_ID_ERC721_METADATA ||
            super.supportsInterface(interfaceId);
    }
}
