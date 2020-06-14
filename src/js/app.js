App = {
  web3Provider: null,
  contracts: {},

  init: async function () {//=>initWeb3()

    return App.initWeb3();
  },

  //初始化web3
  initWeb3: async function () {//=>initContract()
    //如果有web3对象
    if (typeof web3 !== 'undefined') {
      //用当前的web3对象provider初始化一个对象provider（metamask会插入web3对象代码到这程序里面）
      App.web3Provider = web3.currentProvider;
    } else {
      window.alert("Need install MetaMask for transaction!");
      window.alert("Open MetaMask,then refresh page.");
      return false;
    }
    //创建web3对象
    web3 = new Web3(App.web3Provider);
    //同步执行initContract()函数
    return App.initContract();
  },

  //初始化合约
  initContract: function () {//=>displayStation()
    //得到合约Adoption数据，传入data
    $x.getJSON('PayVote.json', function (data) {
      var PayVoteArtifact = data;
      //初始化合约对象，TruffleContract能用那个数据拿到合约地址
      App.contracts.PayVote = TruffleContract(PayVoteArtifact);
      //设置合约web3Provider
      App.contracts.PayVote.setProvider(App.web3Provider);
      return App.displayStation();
    });
  },


  //获取站点信息并在网页上显示
  displayStation: function () {//=>Jugde()
    var payVoteInstance;
    App.contracts.PayVote.deployed().then(function (instance) {
      payVoteInstance = instance;
      if (payVoteInstance.getStaionNum.call() != 0) {
        console.log("Num:" + payVoteInstance.getStaionNum.call());
        return payVoteInstance.getStaionNum.call();
      }
      else {
        window.alert("站点数为0！");
      }
    }).then(function (Num) {
      web3.eth.getAccounts(function (error, accounts) {
        var account = accounts[0];
 
        //index.html的id:stationsRow
        var stationsRow = $x('#stationsRow');
        //index.html的id:stationTemplate
        var stationTemplate = $x('#stationTemplate');
        for (i = 0; i <= Num -1; i++) {
          payVoteInstance.getStaion(i, { from: account }).then(function (station) {
      
            //传入数据的每个站点资料
            stationTemplate.find('.panel-title').text(station[0]);
            stationTemplate.find('img').attr('src', "images/french-bulldog.jpeg");
            stationTemplate.find('.station-breed').text(station[1]);
            //  stationTemplate.find('.station-age').text(station.age);
            stationTemplate.find('.station-location').text(station[2]);
            stationTemplate.find('.station-id').text(station[3]);
            //stationsRow末尾添加整个id为stationTemplate的div
            stationsRow.append(stationTemplate.html());
          })

        }
      })
    }).then(function () {
      return App.Jugde();
    })

  },



  //判断是不是管理员
  Jugde: function () {//=>bindCreateEvents()
    var payVoteInstance;
    App.contracts.PayVote.deployed().then(function (instance) {
      //instance为把拿到的实例保存的实例
      payVoteInstance = instance;
      //判断是乘客还是管理员
      payVoteInstance.JudgeOwner.call().then(function(i) {
        if(i) {
        CreateStation.style.display = "block";
        return App.bindCreateEvents();
        
      } else {
        CreateStation.style.display = "none";
      }})
    })

  },

    //绑定事件
    bindCreateEvents: function () {//=>Create()
      //如果点击创建按钮就执行Create函数
      $x("#CreateStation").on('click', '.stationbtn', App.Create);
  
    },
  

  //创建站点
  Create: function (event) {
    //event.preventDefault()该方法将通知Web浏览器不要执行与事件关联的默认动作（如果存在这样的动作）
    event.preventDefault();
    //合约实例
    var payVoteInstance;
    //拿到账号
    web3.eth.getAccounts(function (error, accounts) {
      //拿到的第一个账号保存起来
      var account = accounts[0];
      console.log("accounts[0]:", account);
      App.contracts.PayVote.deployed().then(function (instance) {
        payVoteInstance = instance;
        //调用合约createStaion函数，from account确保是从account[0]账号发起的
        console.log("payVoteInstance:", payVoteInstance);
        var name = prompt("请输入站点名", "例如：四公里");
        console.log("create:", payVoteInstance.createStaion(name, { from: account }));
        return payVoteInstance.createStaion(name, 0, 0, { from: account });
      }).catch(function (err) {
        console.log(err.message);
      })
    })
  },


  //更新人群密度
  updatecrow: function(account) {
    var payVoteInstance;

    App.contracts.PayVote.deployed().then(function(instance) {
      //instance为把拿到的实例保存的实例
      payVoteInstance= instance;
      
      return payVoteInstance.cooldownTimeView.call();
    }).then(function(cooldownTime) {
      console.log("cooldownTime:",cooldownTime.toNumber());
      console.log("addbefore");
      setTimeout(function() {
        payVoteInstance.addCrowd();
        console.log("add");
        setTimeout(function() {
        payVoteInstance.subCrowd();
        console.log("sub");
      },60000);

      },cooldownTime.toNumber())
      console.log("添加成功");
    }).catch(function(err) {
      //如果有错，则显示错误信息
      console.log(err.message);
    })
  },


    bindBuyEvents: function() {
      $x("#buyticket").on('click', '.btn-adopt', App.BuyTicket);
    },


  //买票
  BuyTicket: function() {

    var mid_location = document.getElementById("mid").value;
    var stationNumber = document.getElementById("stationNumber").value;
    var start_to_mid = document.getElementById("start_to_mid").value;
    console.log("mid_location:",mid_location);
    //合约实例
    var payVoteInstance;

    //拿到账号
    web3.eth.getAccounts(function(error,accounts) {
      //拿到的第一个账号保存起来
      var account = accounts[0];
      console.log("accounts[0]:",account);
      App.contracts.PayVote.deployed().then(function(instance) {
      payVoteInstance = instance;

        var le = mid_location.length;
        var max_mid;
        for(i=0;i<le-1;i++) {
          if(payVoteInstance.levelview(i)>=payVoteInstance.levelview(i+1)){
            max_mid = mid_location[i];
          }
        }  

        // payVoteInstance.updateLevel(max_mid);
      return payVoteInstance.PriceBetween(stationNumber,max_mid,{from: account});
      }).then(function(price) {
        console.log("price:",price[0].toNumber());

        // var weiValue = web3.toWei(price[0].toNumber(), 'ether');
        return payVoteInstance.GetVote(price[0], price[1], start_to_mid,{from: account, value: price[0]});
      }).then(function() {
        return App.updatecrow(account);
       
      }).catch(function(err) {
        console.log(err.message);
      })

    })
  },

  

  bindclearEvents: function() {
    $x("#CreateStation").on('click', '.clearbtn', App.clearCrowd);
  },

  //清零人群密度
  clearCrowd:function() {
    var payVoteInstance;
    App.contracts.PayVote.deployed().then(function(instance) {
      payVoteInstance= instance;  
  
      return payVoteInstance.getStaionNum.call();
 
    }).then(function(length) {
      console.log("length:",length.toNumber());
      for(i=0;i<=length-1;i++){  
         console.log("i:",i);
        payVoteInstance.clearCrowDensity(i);
      }
    }).catch(function(err) {
      console.log(err.message);
    })

  },





};

var $x=jQuery.noConflict();

$x(function () {
  $x(window).load(function () {
    //初始化app
    App.init();
  });
});