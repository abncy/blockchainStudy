pragma solidity ^0.5.16;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/LightRailDisplay.sol';

contract TestAdoption {//测试合约
    Adoption adoption = Adoption(DeployedAddresses.Adoption());//拿到测试合约的地址
    function testUserCanAdoptPet() public {//测试返回的领养id是不是对的
        uint returnedId = adoption.adopt(8);
        uint expected =8;
        Assert.equal(returnedId,expected,"Adoption of pet Id 8 should be recorded.");
        
    }
    function testGetAdopterAddressByPetid() public {//测试领养之后领养的地址对不对
        address expected = address(this);
        address adopter = adoption.adopters(8);
        Assert.equal(adopter,expected,"Owner of pet ID 8 should be record.");
    }
    function testGetAdopterAdressByPetIdInArray() public {
        address expected = address(this);
        address[16] memory adopter = adoption.getAdopters();

        Assert.equal(adopter[8],expected,"Owner of pet ID 8 should be record.");
        
    }

    
}