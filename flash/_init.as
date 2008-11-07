/***********YTdonghuaPlayer************/
/*******	init.as			***********/
/**************************************/
flyTypeWindow._visible = false;
	
video_button_enable(false);
	
dgrComment.setStyle("fontFamily", "宋体");
	
tip_add("加载参数: b=" + _root.b);
	
//设置音量
function init_set_volume(){
	var volumeNum = get_cookie("volume");
	trace("volumeNum=" + volumeNum);

	if(volumeNum){
		volume_set(volumeNum);
	}
	else{
		volume_set(38);
	}
}
