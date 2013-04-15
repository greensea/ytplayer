/***********YTdonghuaPlayer************/
/*******	events.as		***********/
/**************************************/

import flash.events.FullScreenEvent;  

trace("正在加载所有按钮的事件");

/// 信息窗口按钮
btnStsLoading.addEventListener("click", function (evt) {
	mx.behaviors.DepthControl.bringToFront(stsLoading);
});

/// 弹幕窗口按钮
btnComment.addEventListener("click", function (evt) {
	mx.behaviors.DepthControl.bringToFront(_root.dgrComments)
});

/// 调试信息窗口
btnSts.addEventListener("click", function (evt) {
	_root.sts._visible = !_root.sts._visible;
	_root.sts._alpha = 0.60;
});

/// 全屏按钮
btnFullScreen.addEventListener("click", function (evt) {
	
	Stage.width = Stage.fullScreenWidth;
	Stage.height = Stage.fullScreenHeight;
	Stage.scaleMode = "noBorder";
	
	//tip_add("设置层0到 " + _level0._width + "x" + _level0._height);
	
	Stage.displayState = "fullScreen";
});

ytOnFullScreen = new Object();
ytOnFullScreen.onFullScreen = function( bFull:Boolean ) {
	tip_add("On Fullscreen");
	if (Stage.displayState == "fullScreen") {
		//ytVideo._height = Stage.fullScreenHeight;
		//ytVideo._width = Stage.width;
		g_playarea_height = Stage.height;
				
		//ytvideo_setshape(_level0._width, _level0._height);
		//ytvideo_setshape(Stage.fullScreenWidth, Stage.fullScreenHeight);
		//ytvideo_setshape(G_LEVEL_DEFAULT_WIDTH, G_LEVEL_DEFAULT_HEIGHT);
		
		ytvideo_setshape(Stage.width , Stage.height);
		
		bgDango._visible = false;
		
		dgrComments._visible = false;
		stsLoading._visible = false;
		commentWriter._visible = false;
		btnSts._visible = false;
		btnStsLoading._visible = false;
		btnComment._visible = false;
		btnFullScreen._visible = false;
		playerControl._visible = false;
		btnWriterFontColor._visible = false;
		
		tip_add("全屏大小: " + Stage.fullScreenWidth + "x" + Stage.fullScreenHeight);
	}
	else {
		//ytVideo._height = G_VIDEO_DEFAULT_HEIGHT;
		//ytVideo._width = G_VIDEO_DEFAULT_WIDTH;
		g_playarea_height = G_VIDEO_DEFAULT_HEIGHT;
		
		//_level0._height = G_LEVEL_DEFAULT_HEIGHT;
		//_level0._width = G_LEVEL_DEFAULT_WIDTH;
		
		//_level0._height = Stage.fullScreenHeight;
		//_level0._width = Stage.fullScreenWidth;
		
		ytvideo_setshape(G_VIDEO_DEFAULT_WIDTH, G_VIDEO_DEFAULT_HEIGHT);
		
		bgDango._visible = true;
		
		stsLoading._visible = true;
		dgrComments._visible = true
		commentWriter._visible = true;
		btnSts._visible = true;
		btnStsLoading._visible = true;
		btnComment._visible = true;
		btnFullScreen._visible = true;
		playerControl._visible = true;
		btnWriterFontColor._visible = true;
		
	}
	
	
	//video_setshape();

}
Stage.addListener( ytOnFullScreen );



///  显示/不显示弹幕
commentWriter.btnWriterDisplay.addEventListener("click", function (evt) {
	trace("comment_display");
	comment_display(this);
});

/// 发送弹幕按钮
commentWriter.btnWriterSubmit.addEventListener("click", function (evt) {
	writer_submit();
});

/// 弹幕字号选择
commentWriter.cmbWriterFontSize.addEventListener("load", function (evt) {
	this.addItem("字号", _level0.FLY_FONTSIZE_NORMAL);
	this.addItem("大", _level0.FLY_FONTSIZE_BIG);
	this.addItem("中", _level0.FLY_FONTSIZE_NORMAL);
	this.addItem("小", _level0.FLY_FONTSIZE_SMALL);
	this.selectedIndex = 2;
});

commentWriter.cmbWriterFontSize.addEventListener("change", function (evt) {
	writer_fontsize_set(this.value);
});

/// 弹幕方式按钮
commentWriter.btnCommentStyle.onPress = function (evt) {
	window_comment_style._visible = !window_comment_style._visible;
};

/// 弹幕方式
window_comment_style.btnFly.onRelease = function (evt) {
	writer_flytype_set("fly");
};
window_comment_style.btnTop.onRelease = function (evt) {
	writer_flytype_set("top");
};
window_comment_style.btnBottom.onRelease = function (evt) {
	writer_flytype_set("bottom");
};
window_comment_style.btnSubtitle.onRelease = function (evt) {
	writer_flytype_set("subtitle");
};


/// 弹幕输入文本框
commentWriter.txtWriterInput.addEventListener("enter", function (evt) {
	if(this.enabled) writer_submit();
});

commentWriter.txtWriterInput.addEventListener("keyUp", function (evt) {
	var pt = playerControl;
	if(Key.getCode() == 38){	//Key: ARROW_UP
		if(pt.plyCtlPlay._visible){
			pt.plyCtlPlay.onRelease();
		}
		else if(pt.plyCtlPause._visible){
			pt.plyCtlPause.onRelease();
		}
	}
});


trace("所有按钮的时间加载完成");
