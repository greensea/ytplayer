/***********YTdonghuaPlayer************/
/*******	writer.as		***********/
/*****	用以控制评论提交和输入	******/
/**************************************/
var WRITER_SUBMIT_TIMEOUT = 10000;	//提交弹幕超时时间

var _writer_var_fontsize = FLY_FONTSIZE_NORMAL;
var _writer_var_fontcolor = FLY_FONTCOLOR_DEFAULT;
var _writer_var_commentmode = FLY_TYPE_FLY;
var _writer_var_issubtitle = false;
var _writer_submit_timeout_waiter = 0;
var _writer_xml:XML = new XML();

function writer_submit(){
	var t = _level0.commentWriter.txtWriterInput;
	if(t.length == 0) return false;
	
	var playTime = _video_get_time() - 0.1;	//把评论时间提前0.1s
	if(playTime <= 0) playTime = 0.1;			//另外0.1s之前不允许评论
	if(playTime > video_var_timeTotal || playTime == undefined) playTime = video_var_timeTotal;
	trace("弹幕时间追踪【0】：" + playTime + ", (playTime == undefined)=" + (playTime == undefined));
	
	trace(ns.time);
	
	_writer_var_fontcolor = parseInt(btnWriterFontColor.show_txt.text.substr(1, 6), 16);
	if(isNaN(_writer_var_fontcolor)) _writer_var_fontcolor = FLY_FONTCOLOR_DEFAULT;
	trace(parseInt(btnWriterFontColor.show_txt.text.substr(1, 6), 16));
	
	//添加新的评论到屏幕上
	var newCmt = Array(t.text, {fontSize:_writer_var_fontsize, 
								 fontColor:_writer_var_fontcolor,
								 flyType:_writer_var_commentmode, 
								 sTime:playTime,
								 flySpeed:FLY_SPEED_NORMAL / 1000,
								 isSubtitle:_writer_var_issubtitle,
								 commentTime:(new Date())
						});
	if(_writer_var_issubtitle) newCmt[1].flyType = FLY_TYPE_SUBTITLE;
	comment_add_comment(newCmt[0], newCmt[1])
	
	//提交评论到服务器
	writer_send(newCmt[0], newCmt[1]);
}

function writer_send(con, attr){
	var url = URL_PREFIX + "savecomment.php?content=" + escape(con) + 
				"&fontsize=" + attr.fontSize + 
				"&color=" + attr.fontColor + 
				"&mode=" + attr.flyType +
				"&playtime=" + (attr.sTime * 1000) + 
				"&id=" + video_var_flvid;
				trace("弹幕显示时间追踪：" + attr.sTime);
	_writer_submit_timeout_waiter = setTimeout(_writer_submit_timeout, WRITER_SUBMIT_TIMEOUT);
	_level0.commentWriter.txtWriterInput.enabled = false;
	_level0.commentWriter.txtWriterInput.editable = false;
	_level0.commentWriter.btnWriterSubmit.enabled = false;
	_level0.commentWriter.btnWriterSubmit.label = "提交中...";
	_writer_xml.load(url);
	trace(url);
}

_writer_xml.onLoad = function(){
	clearTimeout(_writer_submit_timeout_waiter);
	tip_add(this);
	_level0.commentWriter.txtWriterInput.text = "";
	_level0.commentWriter.txtWriterInput.enabled = true;
	_level0.commentWriter.txtWriterInput.editable = true;
	_level0.commentWriter.btnWriterSubmit.enabled = true;
	_level0.commentWriter.btnWriterSubmit.label = "提交";
}

function _writer_submit_timeout(){
	_level0.commentWriter.txtWriterInput.enabled = true;
	_level0.commentWriter.txtWriterInput.editable = true;
	_level0.commentWriter.btnWriterSubmit.enabled = true;
	_level0.commentWriter.btnWriterSubmit.label = "失败";
}

//评论样式窗口显示关闭
function writer_flytype_window_hide(){
	_level0.flyTypeWindow._visible = false;
}
function writer_flytype_window_show(){
	_level0.flyTypeWindow._visible = true;
}

//=====v====v======v======评论样式设置部分========
function writer_flytype_set(t){
	switch(t){
		case "top":
			_writer_var_commentmode = FLY_TYPE_TOP;
			break;
		case "bottom":
			_writer_var_commentmode = FLY_TYPE_BOTTOM;
			break;
		case "subtitle":
			_writer_var_commentmode = FLY_TYPE_SUBTITLE;
			break;
		default:
			_writer_var_commentmode = FLY_TYPE_FLY;
			break;
	}
	
	if(t == "subtitle"){
		_writer_subtitle_enable(true);
	}
	else{
		_writer_subtitle_enable(false);
	}
	
	writer_flytype_window_hide();
}

function writer_fontsize_set(s){
	var found = false;
	trace(s);
	//查询此s值在列表中的位置
	var l:List = commentWriter.cmbWriterFontSize;
	for(var i = 0; i < l.length; i++){
		if(l.getItemAt(i).data == s){
			l.selectedIndex = i;
			_writer_var_fontsize = s;
			found = true;
			i = l.length;
		}
	}
	if(!found){
		_writer_var_fontsize = FLY_FONTSIZE_NORMAL;
	}
	if(isNaN(_writer_var_fontsize)) _writer_var_fontsize = FLY_FONTSIZE_DEFAULT;
	trace("_wirter_fontsize=" + _writer_var_fontsize);
}
	
	
function _writer_subtitle_enable(flag){
	_writer_var_issubtitle = flag;
	if(flag){
		writer_fontsize_set(FLY_FONTSIZE_SUBTITLE);
	}
	commentWriter.cmbWriterFontSize.enabled = !flag;
	trace("setto=" + commentWriter.cmbWriterFontSize.enabled);
}
//==^=====^====^======评论样式设置部分========