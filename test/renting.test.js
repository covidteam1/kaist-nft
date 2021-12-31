const { expect } = require("chai");
const { ethers } = require("hardhat");


async function getAllRentingByTokenId(nftRenting, tokenId) {
  let rentings = await nftRenting.getAllRentingByTokenId(tokenId);
  for (renting in rentings) {
    console.log("Address of renter is: " + rentings[renting].renter);
    console.log("Address of lender is: " + rentings[renting].lender);
    console.log("Renter rented with duration: " + rentings[renting].duration);
    console.log("Renter rented at : " + rentings[renting].rentedAt);
  }
} 

async function getTokenLendingsByAddress(nftRenting, lender) {

  let lendings = await nftRenting.getTokenLendingsByAddress(lender.address);
  for (lending in lendings) {
    console.log("Lender lend with price is " + lendings[lending].price);
    console.log("Lender lend with max duration is" + lendings[lending].maxDuration)
  }
}

async function getTokenIdsLendingsByAddress(nftRenting, lender) {
  let tokenIds = await nftRenting.getTokenIdsLendingsByAddress(lender.address);
  console.log("Lender lent token id is: " + tokenIds)
}


describe("NFT Renting", function () {
  let transaction;


  it("Test full flow", async function () {

    const signers = await ethers.getSigners();
    const deployer = signers[0];
    const alice = signers[1];
    const bob = signers[2];
    const carol = signers[3];

    const NFTCollection = await ethers.getContractFactory('NFTCollection');
    const nftCollection = await NFTCollection.deploy("mBTC", "mBTC");
    await nftCollection.deployed();

    console.log("1. Deploy nft collection at address https://testnet.bscscan.com/address/" + nftCollection.address);

    const NFTRenting = await ethers.getContractFactory('NFTRenting');

    const nftRenting = await NFTRenting.deploy(nftCollection.address, deployer.address);
    await nftRenting.deployed();

    console.log("2. Deploy nft renting at address https://testnet.bscscan.com/address/" + nftRenting.address);

    transaction = await nftCollection.mint(alice.address, "", "");
    console.log("3. Mint nft token id = 0 for alice at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    transaction = await nftCollection.mint(alice.address, "", "");
    console.log("4. Mint nft token id = 1 for alice at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    transaction = await nftCollection.mint(bob.address, "", "");
    console.log("5. Mint nft token id = 2 for bob at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    transaction = await nftCollection.connect(alice).setApprovalForAll(nftRenting.address, true);
    console.log("6. Alice approve for contract nftRenting at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    transaction = await nftRenting.connect(alice).lendToken(0, ethers.utils.parseEther("2"), 36000)
    console.log("7. Alice lend token 0 with price = 2 BNB per hour and max duration = 10 hours at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    expect(await nftCollection.ownerOf(0)).to.equal(nftRenting.address)

    transaction = await nftRenting.connect(alice).lendToken(1, ethers.utils.parseEther("3"), 7200)
    console.log("8. Alice lend token 1 with price = 3 BNB per hour and max duration = 2 hours at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    expect(await nftCollection.ownerOf(1)).to.equal(nftRenting.address)

    transaction = await nftRenting.connect(bob).rentToken(0, "3600", { value: ethers.utils.parseEther("2") })
    console.log("9. Bob rent token 0 with price = 2 BNB for 1 hour at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    transaction = await nftRenting.connect(carol).rentToken(0, "3600", { value: ethers.utils.parseEther("2") })
    console.log("10. Carol rent token 0 with price = 2 BNB for 1 hour at tx https://testnet.bscscan.com/tx/" + transaction.hash);

    getAllRentingByTokenId(nftRenting, 0);

    getTokenLendingsByAddress(nftRenting, alice)

    getTokenIdsLendingsByAddress(nftRenting, alice);
    transaction = await nftRenting.connect(alice).cancelLendingToken(0);

    console.log("10. Alice cancel lending token 0 at tx https://testnet.bscscan.com/tx/" + transaction.hash);
    expect(await nftCollection.ownerOf(0)).to.equal(alice.address)

  }).timeout(40000000000);
});
