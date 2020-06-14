var subwayCityName = '重庆';
    var list = BMapSub.SubwayCitiesList;
    var subwaycity = null;
    for (var i = 0; i < list.length; i++) {
        if (list[i].name === subwayCityName) {
            subwaycity = list[i];
            break;
        }
        
    }
    // 获取重庆地铁数据-初始化地铁图
    var subway = new BMapSub.Subway('map', subwaycity.citycode);
    
    var zoomControl = new BMapSub.ZoomControl({
        anchor: BMAPSUB_ANCHOR_BOTTOM_RIGHT,
        offset: new BMapSub.Size(10, 100)
    });
    
    
    
    
    function searchByStationName() {
        //清空原来的标注
        subway.clearOverlays();
    
        //规划路线
        var start_location = document.getElementById("start").value;
        var end_location = document.getElementById("end").value;
        var mid_location = document.getElementById("mid").value;
      
        var drct = new BMapSub.Direction(subway);
        drct.search(start_location,end_location);
    }
    
    
    //缩放控件
    subway.addControl(zoomControl);
    subway.setZoom(0.5);