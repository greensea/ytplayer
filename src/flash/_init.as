﻿/***********YTdonghuaPlayer************/
/*******	init.as			***********/
/**************************************/
var ctxMenu:ContextMenu = new ContextMenu();
ctxMenu.hideBuiltInItems();
ctxMenu.customItems.push(new ContextMenuItem("取消平滑", video_smooth));
ctxMenu.customItems.push(new ContextMenuItem("关于 ytplayer..↗", menu_about));
ytVideo.menu = ctxMenu;

_level0.playerControl.plyCtlBar.enabled = false;	//先设置控制条不可用


flyTypeWindow._visible = false;
	
video_button_enable(false);
	
dgrComment.setStyle("fontFamily", "_sans");
	
tip_add("加载参数: b=" + _root.b);

// 设置层可见性
_root.sts._visible = false;
_root.window_comment_style._visible = false;
	
// 设置层排列顺序
mx.behaviors.DepthControl.bringToFront(_root.stsLoading)

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
