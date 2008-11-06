/***********YTdonghuaPlayer************/
/*******	commentgrid.as	***********/
/**************************************/

//var dgrComments:DataGrid;
dgrCmtsLsn = new Object();
dgrCmtsLsn.lastClickTime = -100;	//上次双击时间
dgrCmtsLsn.lastSelectedIndex = -1;

dgrCmtsLsn.change = function(eventObject){
	var obj = eventObject.target;
	
	//判断是否双击，500ms内选择同一项目则认为是双击
	tip_add(getTimer() + "-" + this.lastClickTime);
	if((getTimer() - this.lastClickTime) < 500 && this.lastSelectedIndex == obj.selectedIndex){
		var gototimearr = obj.getItemAt(obj.selectedIndex)["片时"].split(":");
		var gototime = parseInt(gototimearr[0]) * 60 + parseInt(gototimearr[1]);
		
		gototime -= 0.2;
		if(gototime > video_var_timeTotal) gototime = video_var_timeTotal;
		if(gototime < 0) gototime = 0;
		tip_add(gototimearr);
		video_seek(gototime);
		tip_add(gototime);
	}
	
	
	//设置双击事件的标记
	this.lastClickTime = getTimer();
	this.lastSelectedIndex = obj.selectedIndex;
}


dgrComments.addEventListener("change", dgrCmtsLsn);

