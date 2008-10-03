/***********YTdonghuaPlayer************/
/*******	net.as			***********/
/*****	用以控制网络通信			******/
/**************************************/

var video_querystring_p = null;
var video_querystring_p = 1;
var video_var_flvid = 0;
var video_var_relocated:Boolean = false;

init_main();
video_init();

function video_init(){
	var url = URL_PREFIX + "playinfo.php?relocate=0&";
	if(typeof(video_querystring_p) == "number"){
		url += "id=" + video_querystring_p;
	}
	else{
		url += "source=" + video_querystring_p;
	}
	trace(url);
	
	var xmlvideo = new XML();
	xmlvideo.ignoreWhitespace = true;
	xmlvideo.load(url);
	xmlvideo.onLoad = function(){
		//先判断是否错误
		var e = xml_getElementByTagName(this, "error");
		if(e){
			tip_add(e.childNode[0]);
			return false;
		}
		
		//获取相关数据
		video_var_flvurl = xml_getElementByTagName(this, "flvURL").childNodes[0].nodeValue;
		video_var_flvid = xml_getElementByTagName(this, "flvID").childNodes[0].nodeValue;

		//压入评论表（该函数同时会启动字幕飘移事件）
		fly_comment_push(this);
		
		//启动播放
		main();
	}
}

function video_relocate(){
	var url = URL_PREFIX + "playinfo.php?relocate=1&";
	if(typeof(video_querystring_p) == "number"){
		url += "id=" + video_querystring_p;
	}
	else{
		url += "source=" + video_querystring_p;
	}
	var xmlvideo = new XML();
	xmlvideo.ignoreWhitespace = true;
	xmlvideo.load(url);
	tip_add("动画打开失败，正在重定位...")
	xmlvideo.onLoad = function(){
		var e = xml_getElementByTagName(this, "error");
		if(e){
			tip_add(e.childNode[0]);
			return false;
		}
		video_var_flvurl = xml_getElementByTagName(this, "flvURL").childNodes[0].nodeValue;
		video_var_relocated = true;
		video_play();
	}
}

function _comments_initpush(xmlcmt){
}


