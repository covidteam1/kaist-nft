pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTCollection is ERC721, Ownable {

  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdTracker;

  mapping(address => bool) public isMinter; 
  mapping(uint256 => string) public tokenIdToUUID;


  constructor(string memory name, string memory symbol) ERC721(name, symbol) public {
      isMinter[msg.sender] = true;
  }

  
  modifier onlyMinter() {
    require(isMinter[msg.sender], "not minter");
    _;
  }

  function setMinter(address _newMinter) public onlyOwner {
      isMinter[_newMinter] = true;
  }

  function removeMinter(address _oldMinter) public onlyOwner {
    isMinter[_oldMinter] = false;
  }

  function transfer(address from, address to, uint256 tokenId) public {
    _transfer(from, to, tokenId);
  }

  function mint(address to, string memory _tokenURI, string memory _uuid) public onlyMinter {
    uint256 tokenId = _tokenIdTracker.current();
    _mint(to, tokenId);
    _setTokenURI(tokenId, _tokenURI);
    tokenIdToUUID[tokenId] = _uuid;
    _tokenIdTracker.increment();
  }

  

}