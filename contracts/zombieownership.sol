pragma solidity ^0.5.10;

import "./zombieattack.sol";
import "./erc721.sol";

/// @title 一个简单的基础运算合约
/// @author cency
/// @dev 符合openZeppelin对ERC721标准草案的实现

contract ZombieOwnership is  ZombieBattle,ERC721 {//代币交易；可以继承多个合约

  mapping(uint => address) zombieApprovals; 

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerZombieCount[_owner];
  }//代币是僵尸

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return zombieToOwner[_tokenId];
  }//返回代币拥有者的地址

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }//方便transfer和takeOwnership调用

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId)  {
    _transfer(msg.sender, _to, _tokenId);
  }//first method:由代币的拥有者调用

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }//second method:代币拥有者先调用，该合约会存储谁被允许提取代币

  function takeOwnership(uint256 _tokenId) public {
    require(zombieApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }//second method:代币接收者调用，如果有拥有者的批准则将代币转移给他。
  

}
