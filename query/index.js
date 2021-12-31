const { ethers } = require("ethers");
const ABI = require("./ABI.json")
// configure address of contract renting
const addressNFTRenting = "";

async function main(addressNFTRenting, ABI) {

  //configure provider 
  //mainnet = "https://bsc-dataseed.binance.org/"
  //testnet = https://data-seed-prebsc-1-s1.binance.org:8545/
  const provider = new ethers.providers.JsonRpcProvider(
    "https://bsc-dataseed.binance.org/"
  );
  const CONTRACT_NFTRenting = new ethers.Contract(
    addressNFTRenting,
    ABI,
    provider
  );

}

//log all infomation of users which renting 1 token id
async function getAllRentingByTokenId(nftRenting, tokenId) {
  let rentings = await nftRenting.getAllRentingByTokenId(tokenId);
  for (renting in rentings) {
    console.log("Address of renter is: " + rentings[renting].renter);
    console.log("Address of lender is: " + rentings[renting].lender);
    console.log("Renter rented with duration: " + rentings[renting].duration);
    console.log("Renter rented at : " + rentings[renting].rentedAt);
  }
} 

//log all infomation(lending) of 1 lender 
async function getTokenLendingsByAddress(nftRenting, lender) {

  let lendings = await nftRenting.getTokenLendingsByAddress(lender.address);
  for (lending in lendings) {
    console.log("Lender lend with price is " + lendings[lending].price);
    console.log("Lender lend with max duration is" + lendings[lending].maxDuration)
  }
}

//log how many token id 1 address lending
async function getTokenIdsLendingsByAddress(nftRenting, lender) {
  let tokenIds = await nftRenting.getTokenIdsLendingsByAddress(lender.address);
  console.log("Lender lent token id is: " + tokenIds)
}


main(addressNFTRenting, ABI);
