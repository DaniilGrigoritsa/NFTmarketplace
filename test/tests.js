const { expect } = require("chai");
const { ethers, network } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
//const { ContractFunctionVisibility } = require("hardhat/internal/hardhat-network/stack-traces/model");
//const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");


describe("Deploy NFT to hardhat local blockchain", async() => {
  async function deployFixture() {
    const [NFTowner, marketplaceOwner, buyer] = await ethers.getSigners();
    const NFT = await ethers.getContractFactory("MintableNFT", NFTowner);
    const token = await NFT.deploy();
    await token.deployed();

    const Marketplace = await ethers.getContractFactory("NFTmarketplace", marketplaceOwner);
    const marketplace = await Marketplace.deploy();
    await marketplace.deployed();

    await token.connect(NFTowner).mint();
    return {token, marketplace, NFTowner, marketplaceOwner, buyer};
  }
  /*
  it("Should publish token to marketplace", async() => {
    const { token, marketplace, NFTowner } = await loadFixture(deployFixture);
    let tokenId = 1; // hardcoded value for test 
    let price = new ethers.BigNumber.from(10).pow(18); // hardcoded value for test  (1 ether)
    await token.connect(NFTowner).approve(marketplace.address, tokenId);
    await marketplace.connect(NFTowner).addNFTToMarketplace(token.address, tokenId, price);
    let res = await marketplace.watchListing(String(token.address));
    expect(String(res[0]), String(res[1]), res[2]).to.equal(String(price), String(token.address), NFTowner);
  })
  
  it("Should remoove token from marketplace", async() => {
    const { token, marketplace, NFTowner } = await loadFixture(deployFixture);
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    let tokenId = 1; // hardcoded value for test 
    let price = new ethers.BigNumber.from(10).pow(18); // hardcoded value for test  (1 ether)
    await marketplace.connect(NFTowner).addNFTToMarketplace(token.address, tokenId, price);
    await marketplace.connect(NFTowner).removeFromMarketplace(token.address, tokenId);
    let res = await marketplace.watchListing(String(token.address));
    expect(String(res[0]), String(res[1]), res[2]).to.equal("0", "0", zeroAddress);
  })
  
  it("Should change NFT price", async() => {
    const { token, marketplace, NFTowner } = await loadFixture(deployFixture);
    let tokenId = 1; // hardcoded value for test 
    let price = new ethers.BigNumber.from(10).pow(18); // hardcoded value for test  (1 ether)
    let newPrice = new ethers.BigNumber.from(10).pow(18).mul(2); // (2 ethers)
    await marketplace.connect(NFTowner).addNFTToMarketplace(token.address, tokenId, price);
    await marketplace.connect(NFTowner).changeNFTPrice(token.address, tokenId, newPrice);
    let res = await marketplace.watchListing(String(token.address));
    console.log(String(res[0]));
    expect(String(res[0])).to.equal(String(newPrice));
  })
  */
  it("Should buy nft", async() => {
    const { token, marketplace, NFTowner, buyer} = await loadFixture(deployFixture);
    let tokenId = 1; // hardcoded value for test 
    let price = new ethers.BigNumber.from(10).pow(18); // hardcoded value for test  (1 ether)
    await marketplace.connect(NFTowner).addNFTToMarketplace(token.address, tokenId, price);
    await token.connect(NFTowner).approve(marketplace.address, tokenId);
    const options = {value: ethers.utils.parseEther("1.0")}
    await marketplace.connect(buyer).buyToken(token.address, tokenId, options);
    
    expect(await token.ownerOf(tokenId)).to.equal(buyer.address);
  })

});
