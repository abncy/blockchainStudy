pragma solidity ^0.5.10;

import "./LightRail.sol";


contract PayVote is LightRail {
    mapping(address => uint16) public VoteNum;
   


    function GetVote(uint price,uint8 id,uint256 StartToMidNum) public payable returns (uint, uint8) {
        require(msg.value == price);
        require(VoteNum[msg.sender] == 0);
        VoteNum[msg.sender] = VoteNum[msg.sender] + 1;
        Choose[msg.sender] = id; //记录站点序号,一人一票
        coolTimeCount(StartToMidNum);
        return(cooldownTime[msg.sender], id);
    } //买票

    function getVoteN() public view returns (uint16) {
        return VoteNum[msg.sender];
    }

    function ChooseStation() public view returns (uint8) {
        return Choose[msg.sender];
    } //溯源
}
