// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFTmarketplace {
  address owner;

  constructor() {
    owner = msg.sender;
  }

  struct Listing{
    uint price;
    uint tokenId;
    address owner;
  }

  mapping(address => Listing) public listings;

  mapping(address => uint) public fundsSellersCanWithdraw;


  event addedToMarketplace(address tokenAddress, uint price, address owner);

  event removedFromMarketplace(address tokenAddress, address owner);

  event NftBought(address tokenAddress, uint price, address buyer);

  event nftPriceChanged(address tokenAdderss, uint newPrice, address owner);


  modifier notAdded(address tokenAddress) {
    require(listings[tokenAddress].price == 0, "Already added");
    _;
  }


  modifier added(address tokenAddress) {
    require(listings[tokenAddress].price > 0, "Not added");
    _;
  }


  modifier onlyOwner(address tokenAddr) {
    require(listings[tokenAddr].owner == msg.sender, "Not an owner");
    _;
  }


  modifier checkId(address tokenAddr, uint _tokenId) {
    require(listings[tokenAddr].tokenId == _tokenId, "Incorrect token id");
    _;
  }


  function addNFTToMarketplace(address tokenAddr, uint tokenId, uint price) external notAdded(tokenAddr) {
    ERC721 nft = ERC721(tokenAddr);
    require(price > 0, "Price can't be 0");
    require(nft.ownerOf(tokenId) == msg.sender, "Not an owner");
    Listing memory listing = Listing(price, tokenId, msg.sender);
    listings[tokenAddr] = listing;
    emit addedToMarketplace(tokenAddr, price, msg.sender);
  }


  function removeFromMarketplace(address tokenAddr, uint _tokenId) external 
    added(tokenAddr) 
    onlyOwner(tokenAddr)
    checkId(tokenAddr, _tokenId) 
  {
      delete listings[tokenAddr];
      emit removedFromMarketplace(tokenAddr, msg.sender);
  }


  function changeNFTPrice(address tokenAddr, uint _tokenId, uint newPrice) external 
    onlyOwner(tokenAddr) 
    checkId(tokenAddr, _tokenId)
  {
    listings[tokenAddr].price = newPrice;
    emit nftPriceChanged(tokenAddr, newPrice, msg.sender);
  }


  function buyToken(address tokenAddr, uint _tokenId) checkId(tokenAddr, _tokenId) external payable {
    require(msg.value == listings[tokenAddr].price, "Insufficient amount sent");
    
    address from = listings[tokenAddr].owner;
    address sender = msg.sender;

    ERC721 nft = ERC721(tokenAddr);
    nft.transferFrom(from, sender, _tokenId);
    uint amount = listings[tokenAddr].price;
    delete listings[tokenAddr];
    fundsSellersCanWithdraw[sender] = amount;
    emit NftBought(tokenAddr, msg.value, sender);
  }


  function withdraw() external {
    require(fundsSellersCanWithdraw[msg.sender] > 0, "Nothing to return");
    uint amount = fundsSellersCanWithdraw[msg.sender];
    payable(msg.sender).transfer(amount);
    fundsSellersCanWithdraw[msg.sender] = 0;
  }
}
