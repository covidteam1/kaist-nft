
const {ethers} = require("hardhat");

async function main() {

  const deployer = await ethers.getSigner();
  console.log("Deploy contract with address: " + deployer.address)
  const NFTCollection = await ethers.getContractFactory("NFTCollection");
  const NFTRenting = await ethers.getContractFactory("NFTRenting");

  //config name and symbol
  const name = "mBTC";
  const symbol = "mBCT";
  const nftCollection = await NFTCollection.deploy(name,symbol);
  await nftCollection.deployed();
  
  //config beneficiary address
  const beneficiary = deployer.address;

  const nftRenting = await NFTRenting.deploy(nftCollection.address, beneficiary);
  await nftRenting.deployed();


  console.log("Address of nftCollection : " + nftCollection.address)

  console.log("Address of nft renting: " + nftRenting.address)

  // await run("verify:verify", {
  //   address: nftCollection.address,
  //   constructorArguments: [name, symbol]
  // })

  // await run("verify:verify", {
  //   address: nftRenting.address,
  //   constructorArguments: [nftCollection.address, deployer.address]
  // })

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
