pragma solidity ^0.5.10;

contract Adoption {
    constructor() public{

    } 
    address[16] public adopters;

    function adopt(uint petId) public returns(uint) {
        require(petId>=0 && petId <=15);
        adopters[petId] = msg.sender;
        return petId;
    }

    // function init(address[16] adopters) public return(address[16] memory) {
    //     for (var index = 0; index < array.length; index++) {
            
    //     }
    // }

    function getAdopters() public view returns (address[16] memory) {
        return adopters;
    }
}