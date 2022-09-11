// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract MintableNFT is ERC721Enumerable {
  uint _tokenId;

  constructor() ERC721("ERC721", "NFT"){}

  function mint() external {
    _tokenId++;
    _safeMint(msg.sender, _tokenId);
  }
}