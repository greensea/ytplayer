/***********YTdonghuaPlayer************/
/*******	net.as			***********/
/*****	用以控制网络通信			******/
/**************************************/

var video_querystring_p = null;
var video_var_flvid = 0;
var video_var_relocated:Boolean = false;
var video_var_relocate_waiter = 0;

var VIDEO_RELOCATE_WAITTIME = 5;	//首次联系超时后进行重定位的时间

Security.loadPolicyFile("*");

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
	tip_add("加载动画信息：" );//+ url);
	
	var xmlvideo = new XML();
	xmlvideo.ignoreWhitespace = true;
	xmlvideo.load(url);
	xmlvideo.onLoad = function(){
		//先判断是否错误
		if(xml_getElementByTagName(this, "ytPlayer") == undefined){
			tip_add("无法加载影片信息");
			return false;
		}
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
		
		tip_add("影片信息加载成功");
		//启动播放
		main();
		video_var_relocate_waiter = setTimeout(video_relocate, VIDEO_RELOCATE_WAITTIME * 1000);
	}
}

function video_relocate(){
	if(video_var_relocated) return false;	//如果已经重定位过了，就不要重定位了
	if(video_var_relocate_waiter == 0){
		return false;	//如果已经开始播放了，那就不用重定位了
	}
	else{
		tip_add("正在重定位动画...");
	}
	video_var_relocated = true;		//仅允许一次重定位
	
	var url = URL_PREFIX + "playinfo.php?relocate=1&";
	if(typeof(video_querystring_p) == "number"){
		url += "id=" + video_querystring_p;
	}
	else{
		url += "source=" + video_querystring_p;
	}
	
	//tip_add(url);	//调试信息
	
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

		tip_add("重定位完毕，正在连接...");// + video_var_flvurl);
		_root.ns.play(video_var_flvurl);
	}
}


function _comments_initpush(xmlcmt){
}


