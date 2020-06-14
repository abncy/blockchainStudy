pragma solidity ^0.5.10;//版本申明

import "./ownable.sol";
import "./safemath.sol"; 
//合约
contract ZombieFactory is Ownable {

    //OpenZeppelin的SafeMath库，我们用来防溢出 
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    //建立事件方便前端监听这个事件
    event NewZombie(uint zombieId, string name, uint dna); 
    
    //僵尸dna位数为16位
    uint dnaDigits = 16;
    //方便模运算把一个数变成16位
    uint dnaModulus = 10 ** dnaDigits;
    //冷却时间设置为1天
    uint cooldownTime = 1 days;


    //僵尸结构
     struct Zombie {
        string name;
        uint dna;
        //级别
        uint32 level;
        //时间戳
        uint32 readyTime;
        //赢的次数
        uint16 winCount;
        //输的次数
        uint16 lossCount;
    }
    
    //僵尸结构的公共数组
     Zombie[] public zombies;
     
     //id到地址的映射，用来根据id存储和查找僵尸
     mapping (uint => address) public zombieToOwner;
     mapping (address => uint) ownerZombieCount;//
     
     //生产僵尸的的函数
     function _createZombie(string memory _name, uint _dna) internal {
        //添加僵尸数组新成员，返回数组长度-1到id表示数组序号
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        //更新映射，msg.sender代表当前调用者的地址
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        //触发事件
        emit NewZombie(id, _name, _dna);
    }
    
    //生成dna
     function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encode(_str)));
        return rand % dnaModulus;
    }

    //输入字符即可创造初始僵尸
      function createRandomZombie(string memory _name) public {
        //确认是第一次调用此函数
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }


}