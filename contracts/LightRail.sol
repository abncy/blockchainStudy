pragma solidity ^0.5.10;

import "./ownable.sol";
import "./safemath.sol";


contract LightRail is Ownable {
    //OpenZeppelin的SafeMath库，我们用来防溢出
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath8 for uint8;

    //构造函数用于初始化
    constructor() public {}

    struct Station {
        //站点结构
        string name;
        uint8 level; //级别
        uint32 CrowdDensity; //人群密度
    }

    Station[] public stations; //站点结构的公共数组


    mapping(address => uint256) public cooldownTime; //预计用户到站的时间，等待结束后计入人群密度

    mapping(address => uint8) public Choose;

    function JudgeOwner() public view onlyOwner returns (bool) {
        return true;
    }

    //添加新站点
    function createStaion(string memory _name, uint8 level, uint32 CrowdDensity) public onlyOwner returns (string memory, uint8, uint32){
        //添加站点数组新成员，返回数组长度-1，id表示数组序号
        uint256 id = stations.push(Station(_name, level, CrowdDensity)).sub(1);
        //idToStation[id] = stations[id];

        return (
            stations[id].name,
            stations[id].level,
            stations[id].CrowdDensity
        );
    }

    //站点个数
    function getStaionNum() public view returns (uint256) {
        uint256 Num = stations.length;
        return (Num);
    }

    //获得指定站点信息
    function getStaion(uint256 id)
        public
        view
        returns (
            string memory,
            uint8,
            uint32,
            uint256
        )
    {
        return (
            stations[id].name,
            stations[id].level,
            stations[id].CrowdDensity,
            id
        );
    }

    //站点的level和crowdDensity清零
    function clearCrowDensity(uint256 id) public onlyOwner {
        for (uint8 index = 0; index <= id; index++) {
            stations[index].CrowdDensity = 0;
        }
    }

    //预计到站时间的计算
    function coolTimeCount(uint256 StartToMidNum) public returns (uint256) {
        //假设每个站5分钟来一趟车，其中停靠1分钟
        cooldownTime[msg.sender] = StartToMidNum * 5 *60000;
        return cooldownTime[msg.sender];
    }

    function cooldownTimeView() public view returns (uint256) {
        return cooldownTime[msg.sender];
    }



    //人群密度的计算

    function addCrowd() public returns (uint32) {
        //增加人群密度
        uint8 id = Choose[msg.sender];
        stations[id].CrowdDensity = stations[id].CrowdDensity.add(1);
        return stations[id].CrowdDensity;
    }

    function subCrowd() public returns (uint32) {
        uint8 id = Choose[msg.sender];
        stations[id].CrowdDensity = stations[id].CrowdDensity.sub(1);
        return stations[id].CrowdDensity;
    }

    //查看level=>PriceBetween()
    function levelview(uint256 id) public view returns (uint8) {
        return stations[id].level;
    }


    //更新level信息,考虑gas问题，之后还是把这个判断转到前端
    function updateLevel(uint256 id) public returns (uint8) {
        if (stations[id].CrowdDensity <= 80) {
            stations[id].level = 0;
        } else if (
            stations[id].CrowdDensity > 80 && stations[id].CrowdDensity <= 200
        ) {
            stations[id].level = 1;
        } else if (stations[id].CrowdDensity > 200) {
            stations[id].level = 2;
        }
        return stations[id].level;
    }

    //票价计算=>GetVote()
    function PriceBetween(uint8 stationNumber, uint8 id) public view returns (uint, uint8) {
        uint price = 0;
        uint stationNumberPrice = 0;
        uint levelPrice = 0;
        if (0 <= stationNumber && stationNumber <= 5) {
            stationNumberPrice = 0.001 ether;//差不多1块几毛钱
        } else if (stationNumber > 5 && stationNumber <= 16) {
            stationNumberPrice = 0.004 ether;
        } else if (stationNumber > 16) {
            stationNumber -= 16;
            stationNumberPrice = (4 + ((stationNumber % 10) * 1))*0.001 ether;
        }

        if (stations[id].level == 0) {
            //空旷
            levelPrice =  0.001 ether ;
        } else if (stations[id].level == 1) {
            //畅通
            levelPrice = 2* 0.001 ether;
        } else if (stations[id].level == 2) {
            //拥挤
            levelPrice = 4* 0.001 ether;
        }
        price = levelPrice + stationNumberPrice;
        return (price, id);
    }
}
