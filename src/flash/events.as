/***********YTdonghuaPlayer************/
/*******	events.as		***********/
/**************************************/

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
	Stage.displayState = "fullScreen";
});

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
	trace("ttttrigger");
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
