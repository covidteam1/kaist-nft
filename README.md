## Project Renting


## Deployment 

1. Configure scripts/deploy.js
- Configure name and symbol of contract nft collection
```javascript
//name of nft collection
const name = 
//symbol of collection
const symbol = 
```
- Configure beneficiary 
```javascript
//address of beneficiary (which receipt fee if set fee)
const beneficiary = 
```

2. Deploy on bsc testnet

```javascript
npx hardhat run scripts/deploy.js --network testnet
```

3. Deploy on bsc mainnet 
```javascript
npx hardhat run scripts/deploy.js --network mainnet
```

## Query 

run test for example
see folder query

## Test 

```javascript
npx hardhat test 
```