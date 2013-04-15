var _video_var_draging_playing = false;
var g_playarea_width:Number = 510;
var g_playarea_height:Number = 400;

/*****主函数*****/
function main(){
	//nc = new NetConnection();
	//nc.connect(null);
	//ns = new NetStream(nc);

	//界面初始化
	_level0.playerControl.plyCtlTime.border = 0;
	mx.behaviors.DepthControl.bringToFront(flyTypeWindow);
	_init_dgrComments();
	
	
	//截获影片头数据
	for (i = 0; i < g_ns.length; i++) {
		trace("正在设置第" + g_ns.length + "段视频 NetStream 回调参数");
		g_ns[i].ns.onMetaData = function(infoObject:Object) {
			
			w = infoObject["width"];
			h = infoObject["height"];
			g_ns[this.id].videoheight = h;
			g_ns[this.id].videowidth = w
			
			
			g_ns[this.id].duration = infoObject["duration"];
			if (g_ns[this.id].secondtime != true) {
				video_var_timeTotal += infoObject["duration"];
				g_ns_loadedNum++;
			}
			
			show_black_bg();
			
			//ytvideo_setshape(w, h);
			
			tip_add("视频信息（第" + this.id + "段）：" + (Math.round(infoObject["duration"] * 100) / 100) + "s, " + infoObject["width"] + "x" + infoObject["height"]);
			
			/// 如果不是第一段视频，且是第一次加载，就暂停缓冲
			if (this.id != 0 && g_ns[this.id].secondtime != true) {
				g_ns[this.id].close();
				g_ns[this.id].ready = false;
			}
			
			g_ns[this.id].secondtime = true;
		}
		//影片载入状态
		g_ns[i].ns.onStatus = function(infoObject){
			switch(infoObject["code"]){
				case "NetStream.Play.Start":
					video_var_relocate_waiter = 0;
					video_var_playing_eof = false;
					
					g_ns[this.id].bytes_total = this.bytesTotal;
					
					tip_add(this.id + ">视频连接成功");
					
					break;
				case "NetStream.Buffer.Full":
					tip_add(this.id + ">" + infoObject["code"]);
					
					if (this.id == 0) {
						video_var_buffering = false;
					
						_level0.playerControl.plyCtlBar.enabled = true;	//控制条可用
						movLoading._visible = false;
					}
					
					break;
				case "NetStream.Buffer.Empty":
					tip_add(this.id + ">" + infoObject["code"]);
						
					//if(Math.abs(ns.time - video_var_timeTotal) * 1000 < 1000){
					/// duration 参数是不可靠的，所以这里做一个模糊判断

					if (Math.abs(g_ns[this.id].ns.time - g_ns[this.id].duration) * 1000 < 1000) {
						tip_add("第" + (this.id + 1) + " 段视频播放完毕了");
						video_var_playing_eof = true;
					}
					else {
						video_var_playing_eof = false;
					}
					
					if(!video_var_playing_eof){
						tip_add("停止判断偏差时间=Math.round(" + g_ns[this.id].ns.time + "-" + g_ns[this.id].duration + ")=" + Math.abs(g_ns[this.id].ns.time - g_ns[this.id].duration) * 1000);
						movLoading._visible = true;
						g_ns[this.id].ns.setBufferTime(5);
						video_var_buffering = true;
						video_pause(this.id + ">" + infoObject["code"]);
					}
					else {
						if (this.id == g_ns.length - 1) {
							/// 最后一段视频播放结束
							tip_add("视频播放结束");
						}
						else {
							/// 切换到下一段视频
							trace("准备切换到下一段视频：" + (this.id + 2));
							video_switch(this.id + 1);
						}
					}
			
					
					break;
					
				case "NetStream.Play.Stop":
					//这个消息在用户点击停止按钮的时候不会被发送，仅在播放完毕以后才会发送
					//不过有点奇怪的是，有时候播放完毕后这个消息不会被发送，所以在上面的Buffer.Empty同时也判断了一下是否已经播放完毕
					tip_add(this.id + ">" + infoObject["code"]);
					if (this.id == g_ns.length - 1) {
						/// 最后一段视频播放结束
						video_var_playing_eof = true;
						video_var_playing = false;
					}
					else {
						/// 切换到下一段视频
						video_switch(this.id + 1);
					}
					//video_stop();
					break;
					
				case "NetStream.Play.StreamNotFound":
					if(!video_var_relocated){
						tip_add(this.id + ">动画打开失败，正在重定位...")
						video_relocate();
					}
					else{
						tip_add(g_ns.indexOf(g_ns[i]) + ">无法打开此动画，文件不存在");
					}
					break;
					
				case "NetStream.Play.FileStructureInvalid":
					tip_add(this.id + ">不支持这种格式的动画");
					break;
					
				default:
					tip_add(this.id + ">onStatus=" + infoObject["code"]);
					break;
			}
	
		}
	}	// End for

	/// 等待所有视频的元信息加载成功
	for (i = 0; i < g_ns.length; i++) {
		tip_add("开始加载第 " + (i + 1) + " 段视频的信息");
		
		g_ns[i].ns.play(g_ns[i].flvurl);
		g_ns[i].ready = true;
		g_ns[i].ns.setBufferTime(5);
		g_ns[i].ns.pause();
		g_ns[i].ns.seek(0);
	}
	setTimeout(wait_metadata, 1);
	//while (g_ns_loadedNum < g_ns.length) {
	//	sleep(0.1);
	//}
}

// 等待所有视频分段的元数据，以便计算视频大小
function wait_metadata() {
	if (g_ns_loadedNum < g_ns.length) {
		setTimeout(wait_metadata, 100);
		return;
	}
	
	for (i = 0; i < g_ns.length; i++) {
		g_ns_bytesTotal += g_ns[i].bytes_total;
	}
	
	main_startplay();
	
	
	//ytVideo.attachVideo(g_ns[0].ns);
	//ns.play('http://nn1.dhot.v.iask.com/f/1/79e419bb1d3a443321f9abe66ba8e2ec15982746.flv');
	//ns.play("http://nn5.dhot.v.iask.com/f/1/c720b5e069ca985d5dcddd4c4f44e0e312014458.flv");
	//ns.play("http://d111.v.iask.com/f/1/c720b5e069ca985d5dcddd4c4f44e0e312014458.flv")
	//ns.play("http://d126.v.iask.com/f/1/33984fcc8cae75e098a9c11973ac8e4216039514.flv");
	//ns.play("http://dl4.dhot.v.iask.com/f/1/50af6bff65fba43acd30b5fdfb7a61446879969.flv");
	//ns.play("http://d126.v.iask.com/f/1/310385da486b9c8dd44220eecb25ff8615982746.flv");
	
	//tip_add("查找并加载动画…");// + video_var_flvurl);
	//ns.play(video_var_flvurl);
	
	//ns.play("http://d126.v.iask.com/f/1/31be0bcf6bb2422f678112181b0a190c15982746.flv");

	//ns.play('http://nn6.dhot.v.iask.com/f/1/c7923910ad70c177118421fc9c01b81f15994187.flv');
	
	
	//video_play();
}

/// 得到视频元数据之后，开始播放
function main_startplay() {
	trace("视频大小 " + g_ns_bytesTotal + " 字节，长度 " + video_var_timeTotal + " 秒");

	sts_download();
	
	mx.behaviors.DepthControl.bringToFront(dgrComments);	//显示评论层
	
	ytvideo_setshape(ytVideo._width, ytVideo._height);

	ytVideo.attachVideo(g_ns[0].ns);
	ytVideo.smoothing = true;
	g_ns[0].ns.seek(0);	/// 必须进行 Seek 操作，这样 ytVideo 对象才会刷新当前的显示。如果不执行 Seek 操作，就需要到下一个I帧之后 ytVideo 才会有显示
	g_ns[0].ns.resume();
	video_button_enable(true);
	
	video_play();
}

/// 设置播放界面的形态，即设置大小并调整位置
function ytvideo_setshape(w:Number, h:Number) {
	var px:Number = 0;	/// 计算得出的播放窗口坐标
	var py:Number = 0;
	var vh:Number = 0;	/// 计算得出的视频高宽
	var vw:Number = 0;
	var sh:Number = g_ns[g_ns_curPlaying].videoheight;	/// 视频原始的高宽
	var sw:Number = g_ns[g_ns_curPlaying].videowidth;
	
	tip_add(sh);
	tip_add(sw);
	tip_add(ytVideo);
	tip_add((sh / sw) + "<-->" + (h / w));
	tip_add("(" + sh + "," + sw + ")<-->(" + h + "," + w + ")");
	if (sh / sw <= h / w) {
		/// 视频是宽屏的，需要计算垂直坐标
		tip_add("宽屏视频");
		
		px = 0;
		
		vw = w;
		vh = sh / sw * vw;
		
		py = (h - vh) / 2;
	}
	else {
		/// 视频是瘦的，需要计算水平坐标
		tip_add("瘦视频");
		
		py = 0;
		
		vh = h;
		vw = sw / sh * vh;
		
		px = (w - vw) / 2;
	
	}
	
	ytVideo._height = vh;
	ytVideo._width = vw;
	ytVideo._y = py;
	ytVideo._x = px;
	tip_add("设置播放窗口形态：" + ytVideo._width + "x" + ytVideo._height +" (" + ytVideo._x + "," + ytVideo._y + ")");
	
	
	// Set popsub drawing area	
	fly_subtitle_redline = h;
	popsub_area_height = h;
	popsub_area_width = w;
	FLY_STARTING_X = w;
}

/**************状态显示 函数*****************/
//状态 下载进度显示
function sts_download(){
	var total:Number = g_ns_bytesTotal;
	var loaded:Number = 0;
	for (i = 0; i < g_ns.length; i++) {
		loaded += g_ns[i].ns.bytesLoaded;
	}
	
	if(total != loaded){
		setTimeout(sts_download,30);
	}
	//显示下载进度
	var fore = _level0.playerControl.plyCtlBar._plyCtlBar_fore;
	var backWidth = _level0.playerControl.plyCtlBar._plyCtlBar_back._width;
	fore._width = backWidth * (loaded / total);
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
var video_var_timeTotal:Number = 0;
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
	g_ns[g_ns_curPlaying].ns.pause(false);
	//video_var_playing = true;
	_video_var_time = getTimer() / 1000;
	
	_video_var_time_ns = 0;
	for (i = 0; i < g_ns_curPlaying; i++) {
		_video_var_time_ns += g_ns[i].duration;
	}
	_video_var_time_ns += g_ns[g_ns_curPlaying].ns.time;
	
	_video_playing();
}

function video_pause(info){
	_level0.playerControl.plyCtlPlay._visible = true;
	_level0.playerControl.plyCtlPause._visible = false;
	if(info != "NetStream.Buffer.Empty") {
		g_ns[g_ns_curPlaying].ns.pause(true);
	}
	video_var_playing = false;
	//_video_var_time_ns = ns.time;
}

function video_stop(){
	_level0.playerControl.plyCtlPause._visible = false;
	_level0.playerControl.plyCtlPlay._visible = true;
	
	g_ns[g_ns_curPlaying].ns.pause();
	g_ns_curPlaying = 0;
	
	video_seek(0);
	_comment_seek(0);
	
	video_var_playing = false;
	//_video_var_time_ns = ns.time;
}

function video_seek(sec){
	//var ornPlaying = video_var_playing;
	//video_pause();
	/// 计算该位置对应第几段视频的第几秒
	var nssec:Number = sec;
	var i:Number = 0;
	
	while (i < g_ns.length && nssec > g_ns[i].duration) {
		nssec -= g_ns[i].duration;
		i++;
	}
	
	trace("企图拖动到 " + sec + "，对应 ns[" + i + "] 视频流的" + nssec + "秒");
	
	if (i != g_ns_curPlaying) {
		g_ns[g_ns_curPlaying].ns.pause();
		video_switch(i);
	}
	g_ns[i].ns.seek(nssec);
	
	//trace("[video_seek] sec=" + sec + ", _video_get_time()="+  _video_get_time() + ", ns.time()=" + ns.time);
	//设置滚动球位置
	var proc = sec / video_var_timeTotal;
	_level0.playerControl.plyCtlBar._plyCtlBar_ball._x = proc * _level0.playerControl.plyCtlBar._plyCtlBar_back._width ;
	sts.text = _level0.playerControl.plyCtlBar._plyCtlBar_ball._x + "/" + proc + "\n" + _sec2disTime(video_var_timeTotal * proc) + "\n" + _sec2disTime(sec);
	
	//刷新显示的播放时间
	var actns:Number = 0;
	for (i = 0; i < g_ns_curPlaying; i++) {
		actns += g_ns[i].duration;
	}
	actns += g_ns[g_ns_curPlaying].ns.time;
	
	_level0.playerControl.plyCtlTime.text = _sec2disTime(actns) + " / " + _sec2disTime(video_var_timeTotal);
	//trace("[video_seek] sec=" + sec + ", _video_get_time()="+  _video_get_time() + ", ns.time()=" + ns.time);
	//setTimeout(_comment_seek, FLY_FLASH_INTERVAL * 1.5, -1);
	//if(ornPlaying) video_play();
}

/// 切换到第 i 段视频
function video_switch(i:Number) {
	g_ns_curPlaying = i;
	
	if (i >= g_ns.length) {
		tip_add("视频已经播放结束了");
		return;
	}
	
	tip_add("切换到第" + (i + 1) + " 段视频");
	
	//ytvideo_setshape(g_ns[i].videowidth, g_ns[i].videoheight);
	
	ytVideo.attachVideo(g_ns[i].ns);
	if (g_ns[i].ready != true) {
		g_ns[i].secondtime = true;
		g_ns[i].ns.play(g_ns[i].flvurl);
	}
	
	g_ns[i].ns.seek(0);
	
	if (video_var_playing == false) {
		g_ns[i].ns.pause();
	}
}

function _video_playing(){
	//显示播放时间
	var timeCur:Number = 0;
	for (i = 0; i < g_ns_curPlaying; i++) {
		timeCur += g_ns[i].duration;
	}
	timeCur += g_ns[g_ns_curPlaying].ns.time;
	
	_level0.playerControl.plyCtlTime.text = _sec2disTime(timeCur) + " / " + _sec2disTime(video_var_timeTotal);
	
	//判断时间间隔
	if(Math.abs(timeCur - video_var_lastFlashTime) > 1){
		//重新校正时间
		_video_var_time = getTimer() / 1000;
		_video_var_time_ns = timeCur;
		trace("[_video_playing] 间隔时间超过阈值：timeCur=" + timeCur + ", video_var_lastFlashTime=" + video_var_lastFlashTime);
		_comment_seek(timeCur);
	}
	video_var_lastFlashTime = timeCur;
	
	//不在播放中则不用刷新
	if(!video_var_playing) return false;
		
	//设置播放进度条
	var ball = _level0.playerControl.plyCtlBar._plyCtlBar_ball;
	var back = _level0.playerControl.plyCtlBar._plyCtlBar_back;
	ball._x = back._x + (back._width * timeCur / video_var_timeTotal);
	if(video_var_playing) setTimeout(_video_playing, 30);
}

//伪重载ns.time函数，返回秒
function _video_get_time(){
	var tsec:Number = 0;
	
	for (i = 0; i < g_ns_curPlaying; i++) {
		tsec += g_ns[i].duration;
	}
	tsec += g_ns[g_ns_curPlaying].ns.time;
	
	if((video_var_playing || video_var_playing_eof) && !video_var_buffering ){
		var rTime = _video_var_time_ns + (getTimer() / 1000 - _video_var_time);
		//影片停止以后，时间仍继续走动，这样才能在影片结束后继续显示弹幕
		//但超过最慢的弹幕的时候以后就停止
		if(rTime - tsec > FLY_SPEED_SLOW){
			return tsec + FLY_SPEED_SLOW;
		}
		else{
			return rTime;
		}
	}
	else{
		return tsec;
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
	trace("[tip_add]" + info + "  " + getTimer() / 1000 + "s\n");
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
				

/**********************/
/***    其他函数    ***/
/*********************/
function show_black_bg(){
	bg_black._alpha = 100;
}

							
/*********调试函数**********/
function debug_sts(){
	sts.text = "rTime=" + _video_get_time() + "\nnsTime=" + g_ns[g_ns_curPlaying].ns.time + "\n" + (g_ns[g_ns_curPlaying].ns.time - _video_get_time()) + "\n video_var_playing=" + video_var_playing
		+ "\n video_var_playing_eof=" + video_var_playing_eof;
	setTimeout(debug_sts, 50);
}
debug_sts();


				
