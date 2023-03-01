//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721URIStorage{

  address payable owner;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _itemSold;

  uint listPrice = 0.01 ether;

  uint royalties = 10;

  constructor() ERC721("NFTMarketplact","NFTJ"){
    owner = payable(msg.sender);
  }

  struct ListedToken {
    uint tokenId;
    address  owner;
    address  seller;
    uint price;
    bool currentlyListed;
    address creator;
  }

  event TokenListedSuccess (
    uint indexed tokenId,
    address  owner,
    address  seller,
    uint price,
    bool currentlyListed
  );

  mapping (uint256 => ListedToken ) private idToListedToken;

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can transfer");
    _;  
  }

  function updateListPrice(uint _listPrice) public payable onlyOwner {
    listPrice = _listPrice;
  }

  function updateRoyaltiesPrice(uint _royalties) public payable onlyOwner {
    royalties = _royalties;
  }

  function getroyaltiesPirce() public view returns(uint){
    return royalties;
  }

  function getListPirce() public view returns(uint){
    return listPrice;
  }

  function getLatestIdToListenToken() public view returns(ListedToken memory){
    uint256 currentTokenId = _tokenIds.current();
    return idToListedToken[currentTokenId];
  }

  function getListedForTokenId(uint _tokenId) public view returns(ListedToken memory){
    return idToListedToken[_tokenId];
  }

  function getCurrentToken() public view returns(uint) {
    return _tokenIds.current();
  }

  function createToken(string memory tokenURI, uint price) public payable returns(uint) {
    require(msg.value >0, "make sure the price isn't negative");
    require(msg.value == listPrice, "send enough ether to list");
    _tokenIds.increment();
    uint currentTokendId = _tokenIds.current();
    _safeMint(msg.sender, currentTokendId);
    _setTokenURI(currentTokendId, tokenURI);
    createListedToken(currentTokendId, price);
    return currentTokendId;
  }

  function createListedToken(uint256 _tokenId, uint256 price) private {
    _transfer(msg.sender, address(this),_tokenId);
    idToListedToken[_tokenId] = ListedToken(
      _tokenId,
      address(this),
      msg.sender,
      price,
      true,
      msg.sender
    );
    emit TokenListedSuccess(_tokenId, address(this), msg.sender, price, true);
  }

  function getAllNFTs() public view returns(ListedToken[] memory) {
    uint nftCount = _tokenIds.current();
    ListedToken[] memory tokens = new ListedToken[](nftCount);
    uint currentIndex = 0;
    for (uint256 i = 0; i < nftCount; i++) {
      uint currentId = i +1;
      ListedToken storage currentItem = idToListedToken[currentId];
      tokens[currentIndex] = currentItem;
      currentIndex +=1;
    }
    return tokens;
  }

  function getMyNFTs() public view returns(ListedToken[] memory) {
    uint totalNFTCounts = _tokenIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;
    for(uint i = 0 ;i< totalNFTCounts; i++){
      if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
        itemCount +=1;
      }
    }

    ListedToken[] memory items = new ListedToken[](itemCount);
    for(uint i = 0 ;i< itemCount; i++){
      if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
        uint currentId = i +1;
        ListedToken storage currentItem = idToListedToken[currentId];
        items[currentIndex] = currentItem;
        currentIndex +=1;
      }
    }
    return items;
  }

  function executeSale(uint tokenId) public payable  {
    uint price = idToListedToken[tokenId].price;
    require(msg.value == price, "Pls submit the asking price for the NFT in order to purchase");
    address seller = idToListedToken[tokenId].seller;
    address creator = idToListedToken[tokenId].creator;
    idToListedToken[tokenId].currentlyListed = false;
    idToListedToken[tokenId].seller = msg.sender;
    _itemSold.increment();
    _transfer(address(this), msg.sender, tokenId);
    approve(address(this),tokenId);
    payable(owner).transfer(listPrice);

    payable(seller).transfer(msg.value - msg.value/royalties);
    payable(creator).transfer(msg.value/royalties);
  }

  function onShelveToken(uint256 _tokenId, uint256 price) public payable {
    require(msg.value >0, "make sure the price isn't negative");
    require(msg.value == listPrice, "send enough ether to list");
    _transfer(msg.sender, address(this),_tokenId);
    idToListedToken[_tokenId].currentlyListed = true;
    idToListedToken[_tokenId].seller = msg.sender;
  }
}