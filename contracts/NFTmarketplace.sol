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


  event addedToMarketplace(address tokenAddress, uint tokenId, uint price, address owner);

  event removedFromMarketplace(address tokenAddress, uint tokenId, address owner);

  event NftBought(address tokenAddress, uint tokenId, uint price, address buyer);

  event nftPriceChanged(address tokenAdderss, uint tokenId, uint newPrice, address owner);


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
    emit addedToMarketplace(tokenAddr, tokenId, price, msg.sender);
  }


  function removeFromMarketplace(address tokenAddr, uint _tokenId) external 
    added(tokenAddr) 
    onlyOwner(tokenAddr)
    checkId(tokenAddr, _tokenId) 
  {
    delete listings[tokenAddr];
    emit removedFromMarketplace(tokenAddr, _tokenId, msg.sender);
  }


  function changeNFTPrice(address tokenAddr, uint _tokenId, uint newPrice) external 
    onlyOwner(tokenAddr) 
    checkId(tokenAddr, _tokenId)
  {
    uint oldPrice = listings[tokenAddr].price;
    require(oldPrice != newPrice, "Can't change price to equal value");
    listings[tokenAddr].price = newPrice;
    emit nftPriceChanged(tokenAddr, _tokenId, newPrice, msg.sender);
  }


  function buyToken(address tokenAddr, uint _tokenId) checkId(tokenAddr, _tokenId) external payable {
    require(msg.value == listings[tokenAddr].price, "Insufficient amount sent");
    address to = msg.sender;
    _buyToken(to, tokenAddr, _tokenId);
  }


  function _buyToken(address _to, address tokenAddr, uint _tokenId) internal {
    ERC721 nft = ERC721(tokenAddr);
    address _owner = listings[tokenAddr].owner;
    uint amount = listings[tokenAddr].price;
    delete listings[tokenAddr];
    fundsSellersCanWithdraw[_owner] = amount;
    nft.transferFrom(_owner, _to, _tokenId);
    emit NftBought(tokenAddr, _tokenId, msg.value, _to);
  }


  function watchListing(address tokenAddr) external view returns(uint, uint, address) {
    Listing memory _listing = listings[tokenAddr];
    return(_listing.price, _listing.tokenId, _listing.owner);
  }


  function watchFundsSellersCanWithdraw(address addr) external view returns(uint) {
    uint amount = fundsSellersCanWithdraw[addr];
    return amount ;
  }


  function withdraw() external {
    require(fundsSellersCanWithdraw[msg.sender] > 0, "Nothing to return");
    uint amount = fundsSellersCanWithdraw[msg.sender];
    payable(msg.sender).transfer(amount);
    fundsSellersCanWithdraw[msg.sender] = 0;
  }
}
