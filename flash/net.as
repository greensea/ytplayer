/***********YTdonghuaPlayer************/
/*******	net.as			***********/
/*****	用以控制网络通信			******/
/**************************************/

var video_querystring_p = null;
var video_var_flvid = 0;
var video_var_relocated:Boolean = false;

init_main();
video_init();

function video_init(){
	//获取函数并判断是什么类型的
	if(_root.b.length != parseInt(_root.b).toString().length){
		video_querystring_p = _root.b;
	}
	else{
		video_querystring_p = parseInt(_root.b);
	}
	if(!_root.b) video_querystring_p = 1;
	
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
			tip_add("错误：" + e.childNodes[0].nodeValue);
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
	xmlvideo.onLoad = function(){
		var e = xml_getElementByTagName(this, "error");
		if(e){
			tip_add("错误：" + e.childNodes[0].nodeValue);
			return false;
		}
		video_var_flvurl = xml_getElementByTagName(this, "flvURL").childNodes[0].nodeValue;
		video_var_relocated = true;
		tip_add("重定位完毕，正在连接...");
		video_play();
	}
}

function _comments_initpush(xmlcmt){
}


