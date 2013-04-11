/***********YTdonghuaPlayer************/
/*******	net.as			***********/
/*****	用以控制网络通信			******/
/**************************************/

var video_querystring_p = null;
var video_var_flvid = 0;
var video_var_relocated:Boolean = false;
var video_var_relocate_waiter = 0;


var VIDEO_RELOCATE_WAITTIME = 10;	//首次加载视频超时后进行重定位的时间

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
	if(!_root.b) video_querystring_p = 1;	//默认的视频编号，调试的时候可以改这个为指定的视频编号
		
	var url = URL_PREFIX + "playinfo.php?relocate=0&";

	if(typeof(video_querystring_p) == "number"){
		url += "id=" + video_querystring_p;
	}
	else{
		url += "source=" + video_querystring_p;
	}
	
	//var url = "data.52.xml";	/// <!>仅供调试

	trace(url);
	tip_add("加载动画信息：" );//+ url);
	
	var xmlvideo = new XML();
	xmlvideo.ignoreWhitespace = true;
	xmlvideo.load(url);
	xmlvideo.onLoad = function(){
		//先判断是否错误
		if(xml_getElementByTagName(this, "ytPlayer") == undefined){
			tip_add("无法加载动画信息");
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
		var urls = video_var_flvurl.split("\r");
		trace("共" + urls.length + "个视频分段");
		for (i = 0; i < urls.length; i++) {
			g_ns.push(new g_ns_t());
			g_ns[i].nc = new NetConnection();
			g_ns[i].nc.connect(null);
			
			g_ns[i].ns = new NetStream(g_ns[i].nc);
			g_ns[i].ns.id = i;
			g_ns[i].flvurl = urls[i];
			trace("第 " + (i + 1) + " 段视频地址：" + g_ns[i].flvurl);
		}
		
		//压入评论表（该函数同时会启动字幕飘移事件）
		fly_comment_push(this);
		
		tip_add("动画信息加载成功");
		//启动播放
		main();
		video_var_relocate_waiter = setTimeout(video_relocate, VIDEO_RELOCATE_WAITTIME * 1000);
	}
}

function video_refresh_comment() {
	var url = URL_PREFIX + "playinfo.php?relocate=0&";
	if(typeof(video_querystring_p) == "number"){
		url += "id=" + video_querystring_p;
	}
	else{
		url += "source=" + video_querystring_p;
	}
	url += "&timeline=" + _comment_var_last_timeline;
	trace("获取新弹幕：" + url);

	// 获取弹幕信息
	var xmlvideo = new XML();
	xmlvideo.ignoreWhitespace = true;
	xmlvideo.load(url);
	xmlvideo.onLoad = function(){
		//先判断是否错误
		if(xml_getElementByTagName(this, "ytPlayer") == undefined){
			tip_add("无法加载附加弹幕信息");
			return false;
		}
		var e = xml_getElementByTagName(this, "error");
		if(e){
			tip_add("错误：" + e.childNodes[0].nodeValue);
			return false;
		}

		//附加新的弹幕
		//fly_comment_push(this);
		var cmts = xml_getElementByTagName(this, "comments").childNodes;
		for (i = 0; i < cmts.length; i++) {
			if (cmts[i].nodeName) {
				// 不要显示自己的弹幕
				if (_writer_popsubs_sent_by_me[cmts[i].lastChild.nodeValue] == 1) break;
				
				var newCmt = Array(cmts[i].lastChild.nodeValue, {fontSize:cmts[i].attributes["fontSize"], 
								 fontColor:cmts[i].attributes["fontColor"],
								 flyType:cmts[i].attributes["flyType"],
								 sTime:cmts[i].attributes["playTime"],
								 flySpeed:cmts[i].attributes["flySpeed"] / 1000,
								 isSubtitle:cmts[i].attributes["isSubtitle"],
								 commentTime:Number(cmts[i].attributes["commentTime"])
								});
				
				// 一系列的判断
				//if (_comment_var_last_timeline < newCmt.commentTime) {
				//	_comment_var_last_timeline = newCmt.commentTime;
				//}
				
				if(newCmt[1].fontColor == "") newCmt[1].fontColor = FLY_FONTCOLOR_DEFAULT;
				if(newCmt[1].flyType == "") newCmt[1].flyType = FLY_TYPE_FLY;
				switch(newCmt[1].fontSize){
					case "14":
						newCmt[1].fontSize = FLY_FONTSIZE_SMALL;
						break;
					case "26":
						newCmt[1].fontSize = FLY_FONTSIZE_BIG;
						break;
					default:
						newCmt[1].fontSize = FLY_FONTSIZE_NORMAL;
						break;
				}
				switch(newCmt[1].flyType){
					case "bottom":
						newCmt[1].flyType = FLY_TYPE_BOTTOM;
						break;
					case "top":
						newCmt[1].flyType = FLY_TYPE_TOP;
						break;
					default:
						newCmt[1].flyType = FLY_TYPE_FLY;
						break;
				}
				
				if (newCmt[1].commentTime > _comment_var_last_timeline) {
					_comment_var_last_timeline = newCmt[1].commentTime;
				}

				comment_add_comment(newCmt[0], newCmt[1]);
			}
		}
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
		var urls = video_var_flvurl.split("\r");
		trace("共" + urls.length + "个视频分段");
		for (i = 0; i < urls.length; i++) {
			g_ns[i].nc = new NetConnection();
			g_ns[i].nc.connect(null);
			
			g_ns[i].ns = new NetStream(g_ns[i].nc);
			g_ns[i].ns.id = i;
			g_ns[i].flvurl = urls[i];
			trace("第 " + (i + 1) + " 段视频地址：" + g_ns[i].flvurl);
		}

		tip_add("重定位完毕，正在连接...");// + video_var_flvurl);
		main();
	}
}


function _comments_initpush(xmlcmt){
}


