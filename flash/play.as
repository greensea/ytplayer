var _video_var_draging_playing = false;


/*****主函数*****/
function main(){
	nc = new NetConnection();
	nc.connect(null);
	ns = new NetStream(nc);
	//界面初始化
	_level0.playerControl.plyCtlTime.border = 0;
	mx.behaviors.DepthControl.bringToFront(flyTypeWindow);
	_init_dgrComments();
	
	//截获影片头数据
	ns.onMetaData = function(infoObject:Object) {
		video_var_timeTotal = infoObject["duration"];
	}
	//影片载入状态
	ns.onStatus = function(infoObject){
		switch(infoObject["code"]){
			case "NetStream.Play.Start":
				video_var_relocate_waiter = 0;
				video_var_playing_eof = false;
				mx.behaviors.DepthControl.bringToFront(dgrComments);	//显示评论层
				tip_add("播放已开始");
				break;
			case "NetStream.Buffer.Full":
			tip_add(infoObject["code"]);
				video_var_buffering = false;
				_level0.playerControl.plyCtlBar.enabled = true;	//控制条可用
				movLoading._visible = false;
				video_button_enable(true);
				video_play();
				break;
			case "NetStream.Buffer.Empty":
			tip_add(infoObject["code"]);
					
				if(Math.abs(ns.time - video_var_timeTotal) * 1000 < 1000){
					video_var_playing_eof = true;
				}
				if(!video_var_playing_eof){
					tip_add("停止判断偏差时间=Math.round(" + ns.time + "-" + video_var_timeTotal + ")=" + Math.abs(ns.time - video_var_timeTotal) * 1000);
					movLoading._visible = true;
					ns.setBufferTime(5);
					video_var_buffering = true;
				}
				video_pause(infoObject["code"]);
				break;
			case "NetStream.Play.Stop":
				//这个消息在用户点击停止按钮的时候不会被发送，仅在播放完毕以后才会发送
				//不过有点奇怪的是，有时候播放完毕后这个消息不会被发送，所以在上面的Buffer.Empty同时也判断了一下是否已经播放完毕
			tip_add(infoObject["code"]);
				video_var_playing_eof = true;
				video_var_playing = false;
				//video_stop();
				break;
			case "NetStream.Play.StreamNotFound":
				if(!video_var_relocated){
					tip_add("动画打开失败，正在重定位...")
					video_relocate();
				}
				else{
					tip_add("无法打开此动画，文件不存在");
				}
				break;
			case "NetStream.Play.FileStructureInvalid":
				tip_add("不支持这种格式的动画");
				break;
			default:
				tip_add("onStatus=" + infoObject["code"]);
				break;
		}

	}


	ytVideo.attachVideo(ns);
	ytVideo.smoothing = true;
	ns.setBufferTime(5);
	//ns.play('http://nn1.dhot.v.iask.com/f/1/79e419bb1d3a443321f9abe66ba8e2ec15982746.flv');
	//ns.play("http://nn5.dhot.v.iask.com/f/1/c720b5e069ca985d5dcddd4c4f44e0e312014458.flv");
	//ns.play("http://d111.v.iask.com/f/1/c720b5e069ca985d5dcddd4c4f44e0e312014458.flv")
	//ns.play("http://d126.v.iask.com/f/1/33984fcc8cae75e098a9c11973ac8e4216039514.flv");
	//ns.play("http://dl4.dhot.v.iask.com/f/1/50af6bff65fba43acd30b5fdfb7a61446879969.flv");
	//ns.play("http://d126.v.iask.com/f/1/310385da486b9c8dd44220eecb25ff8615982746.flv");
	tip_add("查找并加载动画…");// + video_var_flvurl);
	ns.play(video_var_flvurl);
	//ns.play("http://d126.v.iask.com/f/1/31be0bcf6bb2422f678112181b0a190c15982746.flv");

	//ns.play('http://nn6.dhot.v.iask.com/f/1/c7923910ad70c177118421fc9c01b81f15994187.flv');
	sts_download();
	
	//video_play();
}


/**************状态显示 函数*****************/
//状态 下载进度显示
function sts_download(){
	if(ns.bytesLoaded != ns.bytesTotal){
		setTimeout(sts_download,30);
	}
	//显示下载进度
	var fore = _level0.playerControl.plyCtlBar._plyCtlBar_fore;
	var backWidth = _level0.playerControl.plyCtlBar._plyCtlBar_back._width;
	fore._width = backWidth * (ns.bytesLoaded / ns.bytesTotal);
	//fore._x = _level0.playerControl.plyCtlBar._plyCtlBar_back._x + fore._width / 2;
}




/******************控制按钮部分******************/
_level0.playerControl.plyCtlPlay.onRelease = function() {
	video_play();
}
_level0.playerControl.plyCtlStop.onRelease = function() {
	video_stop();
}
_level0.playerControl.plyCtlPause.onRelease = function() {
	video_pause();
}
_level0.playerControl.plyCtlBar.onPress = function(){
	var ball = _level0.playerControl.plyCtlBar._plyCtlBar_ball;
	var back = _level0.playerControl.plyCtlBar._plyCtlBar_back;
	video_var_dragging = true;
	_video_var_dragging_playing |= video_var_playing;
	video_pause();
	var proc = back._xmouse / back._width;
	if(proc > 1) proc = 1;
	if(proc < 0) proc = 0;
	
	video_seek(video_var_timeTotal * proc);
}
_level0.playerControl.plyCtlBar.onReleaseOutside = _level0.playerControl.plyCtlBar.onRelease = function(){
	video_var_dragging = false;
	if(_video_var_dragging_playing) video_play();
	_video_var_dragging_playing = false;
}

_level0.playerControl.plyCtlBar._plyCtlBar_fore.onMouseMove = function(){
	if(video_var_dragging) _level0.playerControl.plyCtlBar.onPress();
}

//音量控制
_level0.playerControl.plyCtlVolume.onPress = function(){
	var vol = _level0.playerControl.plyCtlVolume;
	volume_set(vol._xmouse / vol._width * 100);
	
	//附加鼠标事件
	this.onMouseMove = function(){
		var volNum = this._xmouse / this._width * 100;
		if(volNum < 0) volNum = 0;
		if(volNum > 100) volNum = 100;
		volume_set(volNum);
	}
}
_level0.playerControl.plyCtlVolume.onRelease = function(){
	this.onMouseMove = null;
}
_level0.playerControl.plyCtlVolume.onReleaseOutside = function(){
	_level0.playerControl.plyCtlVolume.onRelease();
}



/***************影片播放 内部普通函数***************************/



/***************影片控制 抽象层 变量和函数****************/
var video_var_playing:Boolean = false;
var video_var_timeTotal:Number = 999999;
var video_var_dragging:Boolean = false;
var _video_var_time:Number = 0;
var video_var_buffering:Boolean = false;
var video_var_playing_eof = false;	//播放是否结束的标记
var video_var_lastFlashTime = 0;

function video_play(){
	video_var_playing = true;
	video_var_playing_eof = false;
	_level0.playerControl.plyCtlPlay._visible = false;
	_level0.playerControl.plyCtlPause._visible = true;
	ns.pause(false);
	//video_var_playing = true;
	_video_var_time = getTimer() / 1000;
	_video_var_time_ns = ns.time;
	_video_playing();
}

function video_pause(info){
	_level0.playerControl.plyCtlPlay._visible = true;
	_level0.playerControl.plyCtlPause._visible = false;
	if(info != "NetStream.Buffer.Empty") ns.pause(true);
	video_var_playing = false;
	//_video_var_time_ns = ns.time;
}

function video_stop(){
	_level0.playerControl.plyCtlPause._visible = false;
	_level0.playerControl.plyCtlPlay._visible = true;
	ns.stop();
	video_seek(0);
	_comment_seek(0);
	ns.pause(true);
	video_var_playing = false;
	//_video_var_time_ns = ns.time;
}

function video_seek(sec){
	//var ornPlaying = video_var_playing;
	//video_pause();
	ns.seek(sec);
	//trace("[video_seek] sec=" + sec + ", _video_get_time()="+  _video_get_time() + ", ns.time()=" + ns.time);
	//设置滚动球位置
	var proc = sec / video_var_timeTotal;
	_level0.playerControl.plyCtlBar._plyCtlBar_ball._x = proc * _level0.playerControl.plyCtlBar._plyCtlBar_back._width ;
	sts.text = _level0.playerControl.plyCtlBar._plyCtlBar_ball._x + "/" + proc + "\n" + _sec2disTime(video_var_timeTotal * proc) + "\n" + _sec2disTime(sec);
	//刷新显示的播放时间
	_level0.playerControl.plyCtlTime.text = _sec2disTime(ns.time) + " / " + _sec2disTime(video_var_timeTotal);
	//trace("[video_seek] sec=" + sec + ", _video_get_time()="+  _video_get_time() + ", ns.time()=" + ns.time);
	//setTimeout(_comment_seek, FLY_FLASH_INTERVAL * 1.5, -1);
	//if(ornPlaying) video_play();
}

function _video_playing(){
	//显示播放时间
	_level0.playerControl.plyCtlTime.text = _sec2disTime(ns.time) + " / " + _sec2disTime(video_var_timeTotal);
	
	//判断时间间隔
	if(Math.abs(ns.time - video_var_lastFlashTime) > 1){
		//重新校正时间
		_video_var_time = getTimer() / 1000;
		_video_var_time_ns = ns.time;
		trace("[_video_playing] 间隔时间超过阈值：ns.time=" + ns.time + ", video_var_lastFlashTime=" + video_var_lastFlashTime);
		_comment_seek(ns.time);
	}
	video_var_lastFlashTime = ns.time;
	
	//不在播放中则不用刷新
	if(!video_var_playing) return false;
		
	//设置播放进度条
	var ball = _level0.playerControl.plyCtlBar._plyCtlBar_ball;
	var back = _level0.playerControl.plyCtlBar._plyCtlBar_back;
	ball._x = back._x + (back._width * ns.time / video_var_timeTotal);	//这里的-8是小球显示的偏移量
	if(video_var_playing) setTimeout(_video_playing, 30);
}

//伪重载ns.time函数，返回秒
function _video_get_time(){
	if((video_var_playing || video_var_playing_eof) && !video_var_buffering ){
		var rTime = _video_var_time_ns + (getTimer() / 1000 - _video_var_time);
		//影片停止以后，时间仍继续走动，这样才能在影片结束后继续显示弹幕
		//但超过最慢的弹幕的时候以后就停止
		if(rTime - ns.time > FLY_SPEED_SLOW){
			return ns.time + FLY_SPEED_SLOW;
		}
		else{
			return rTime;
		}
	}
	else{
		return ns.time;
	}
}
	
	


/*************声音控制 抽象 函数 附加变量定义*******************/
vidsound.attachAudio(ns);
var sou:Sound = new Sound(vidsound);

init_set_volume();

var volume_var_dragging = false;

function volume_set(volNum){
	var back = _level0.playerControl.plyCtlVolume._plyCtlVolume_back;
	var fore = _level0.playerControl.plyCtlVolume._plyCtlVolume_fore;
	fore._width = back._width * (volNum / 100);
	sou.setVolume(volNum);
	set_cookie("volume", volNum);
}
/************影片设置 函数********************/
function video_smooth(){
	ytVideo.smoothing = !ytVideo.smoothing;
	var str = "";
	if(ytVideo.smoothing){
		str = "取消平滑";
	}
	else{
		str = "平滑";
	}
	ytVideo.menu.customItems[0].caption = str;
	trace(str);
}



/**************提示部分 函数******************/
function tip_add(info){
	stsLoading._stsLoading_text.text = stsLoading._stsLoading_text.text + info + "  " + getTimer() / 1000 + "s\n";
}
/***************其他 内部函数******************///秒转换成显示时间（xx:xx）
function _sec2disTime(sec){
	var str = Math.ceil(sec % 60) - 1;
	if(str < 0) str = 0;
	if(length(str) < 2) str = "0" + str;
	str = (sec - sec % 60) / 60  + ":" + str;
	if(length(str) < 5) str = "0" + str;
	return str;
}

function video_button_enable(b){
	btns = Array(
				 _level0.playerControl.plyCtlPlay,
				 _level0.playerControl.plyCtlPause,
				 _level0.playerControl.plyCtlStop
				 );
	for(var i = 0; i < btns.length; i++){
		btns[i].enabled = b;
	}
}
				

							
/*********调试函数**********/
function debug_sts(){
	sts.text = "rTime=" + _video_get_time() + "\nnsTime=" + ns.time + "\n" + (ns.time - _video_get_time()) + "\n video_var_playing=" + video_var_playing
		+ "\n video_var_playing_eof=" + video_var_playing_eof;
	setTimeout(debug_sts, 50);
}
debug_sts();


				