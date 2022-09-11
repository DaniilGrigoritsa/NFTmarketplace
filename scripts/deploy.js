const hre = require("hardhat");

//deployed to gorli adderss: 0xfCa3aBc39ec5d8Fdd15bEc811aABdB586f7102E2 

async function main() {
  const NFTmarketplace = await hre.ethers.getContractFactory("NFTmarketplace");
  const marketplace = await NFTmarketplace.deploy();
  await marketplace.deployed();
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
