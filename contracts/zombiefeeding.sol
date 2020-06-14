pragma solidity ^0.5.10;

import "./zombiefactory.sol";//导入这个文件

contract KittyInterface {//声明接口，方便调用区块链上其他应用合约的函数 
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {//表示ZombieFeeding是ZombieFactory的子类

//address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;发布到链上不能更改合约，所以不要用硬编码
   KittyInterface kittyContract;//声明接口
   
    modifier onlyOwnerOf(uint _zombieId) {//确保只能操控自己的僵尸，不能操控其他的
    require(msg.sender == zombieToOwner[_zombieId]);//确保对自己僵尸的所有权
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {//修饰符onlyOwner限制只许我修改
    kittyContract = KittyInterface(_address);
  }//初始化接口
  
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);//下一个僵尸产生的最低允许时间
  }
  
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);//判断是否过了冷却时间
  }
    
   function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {//僵尸繁殖的函数
    Zombie storage myZombie = zombies[_zombieId];//myZombie是一个storage类型的指针
    require(_isReady(myZombie));
     _targetDna = _targetDna % dnaModulus;//保证目标猎物dna16位
    uint newDna = (myZombie.dna + _targetDna) / 2;
       if (keccak256(abi.encode(_species)) == keccak256("kitty")) {//如果字符是kitty,就把dna末尾换成99
      newDna = newDna - newDna % 100 + 99;
       }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }
  
   function feedOnKitty(uint _zombieId, uint _kittyId) public {//从kitty合约中获取它的dna
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);//通过kittyid查出对应的dna
    // 并修改函数调用
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }


}