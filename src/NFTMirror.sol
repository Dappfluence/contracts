// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./INFTMirror.sol";

contract NFTMirror is INFTMirror, ERC165 {
    IERC721 private _nftContract;

    constructor(IERC721 nftContractAddress) {
        _nftContract = nftContractAddress;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _nftContract.ownerOf(tokenId);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _nftContract.balanceOf(owner);
    }

    function totalSupply() public view override returns (uint256) {
        return INFTMirror(address(_nftContract)).totalSupply();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return IERC721Metadata(address(_nftContract)).tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(INFTMirror).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
