pragma solidity ^0.5.10;

import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {//创建随机数
    randNonce = randNonce.add(1);
    return uint(keccak256( abi.encode(now, msg.sender,randNonce))) % _modulus;
  }


  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {//攻击其他僵尸
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {//如果赢了
      myZombie.winCount = myZombie.winCount.add(1);
      myZombie.level = myZombie.level.add(1);
      enemyZombie.lossCount = enemyZombie.lossCount.add(1);
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    }  else {//如果输了
      myZombie.lossCount = myZombie.lossCount.add(1);
      enemyZombie.winCount = enemyZombie.winCount.add(1);
      _triggerCooldown(myZombie);
    } 
  }
  
}
