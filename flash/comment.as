/** ytPlayer  飘移评论控制脚本 **/

import channel_t;

//定义全局常量
var FLY_SPEED_FAST:Number = 2500;		//快字幕速度：秒
var FLY_SPEED_NORMAL:Number = 4000;	//中等速度字幕：秒
var FLY_SPEED_SLOW:Number = 5500;		//慢字幕速度：秒

var FLY_FONTSIZE_BIG:Number = 26;		//字体大小，大：像素
var FLY_FONTSIZE_NORMAL:Number = 22;	//字体大小，中：像素
var FLY_FONTSIZE_SMALL:Number = 14;		//字体大小，小：像素
var FLY_FONTSIZE_SUBTITLE:Number = FLY_FONTSIZE_SMALL;	//字体大小，字幕：像素

var FLY_FONTCOLOR_DEFAULT:Number = 0xffffff;		//默认字体颜色：白

var FLY_TYPE_TOP:Number = 0x2;
var FLY_TYPE_BOTTOM:Number = 0x0;
var FLY_TYPE_FLY:Number = 0x3;
var FLY_TYPE_SUBTITLE:Number = 0x4;

var FLY_LEVEL_RANGE:Number = 1000;
var FLY_LEVEL_FLY:Number = FLY_LEVEL_RANGE;
var FLY_LEVEL_TOP:Number =FLY_LEVEL_FLY + FLY_LEVEL_RANGE;
var FLY_LEVEL_BOTTOM:Number = FLY_LEVEL_TOP + FLY_LEVEL_RANGE;

var FLY_SUBTITLE_LINES:Number = 2;		//字幕占据的最大行数
var FLY_SUBTITLE_RANGE:Number = FLY_FONTSIZE_SUBTITLE * FLY_SUBTITLE_LINES;		//字幕占据的高度数素

var FLY_STARTING_X:Number = ytVideo._width;		//字幕初始位置：相对与影片
var FLY_FLASH_INTERVAL:Number = 30;		//字幕刷新间隔：毫秒



/* a1 表示评论位置， a0 表示是否飘移 */
var fly_type:Object ={top:0x2, bottom:0x0, fly:0x3};
/*
var fly_var_queue:Object = {
	cmtID:Number, cmtText:String, 
	sTime:Number, flyType:Number, flySpeed:Number, fontColor:Number, fontSize:Number
};
*/

var fly_var_indexNext = 0;
var fly_var_queueLength = 0;
var _fly_var_level_accumulator = 0;

var fly_var_queue:Array = new Array();
var _fly_var_channels:Array = new Array();		//Array(channelID, {cmtID:Number, channelBreadth:Number, deathTime:playTime-Seconds})
var fly_subtitle_redline = ytVideo._height;			//当前字幕所占据的高度

var popsub_area_height = ytVideo._height;
var popsub_area_width = ytVideo._width;

var _comment_var_display = true;		//是否显示评论
var _comment_user_total = 0;		//记录用户在本页面发表的评论总数



//获取字幕源XML
function fly_comment_push(xmlcmt){	
	var cmts = xml_getElementByTagName(xmlcmt, "comments").childNodes;
	fly_var_queueLength = 0;
	fly_var_queue = new Array();
	for(var i = 0; i < cmts.length; i++){
		if(cmts[i].nodeName){
			// 弹幕过滤
			//if (cmts[i].attributes["flyType"] != "bottom") continue;
			//if (cmts[i].attributes["flyType"] == "bottom") cmts[i].attributes["flyType"] = "top";
			// 增加到播放器评论表格
			dgrComments.addItem({
				片时:_sec2disTime(cmts[i].attributes["playTime"]),
				内容:cmts[i].lastChild.nodeValue, 
				评论时间:_timestamp2date(cmts[i].attributes["commentTime"])
				});
				
			//压入弹幕数据库
			var newCmt:Object = {
				cmtID:cmts[i].attributes["id"],
				cmtText:cmts[i].lastChild.nodeValue,
				sTime:(cmts[i].attributes["playTime"] * 1),	//单位：s，基于影片开始的时间戳
				fontColor:cmts[i].attributes["fontColor"],
				fontSize:cmts[i].attributes["fontSize"],
				flyType:cmts[i].attributes["flyType"],
				flySpeed:(cmts[i].attributes["flySpeed"] / 1000.0), //单位：s
				channel:cmts[i].attributes["channel"],
				alignment:cmts[i].attributes["alignment"]
			}
			
			//一系列的判断
			if(newCmt.fontColor == "") newCmt.fontColor = FLY_FONTCOLOR_DEFAULT;
			if(newCmt.flyType == "") newCmt.flyType = FLY_TYPE_FLY;
			switch(newCmt.fontSize){
				case "14":
					newCmt.fontSize = FLY_FONTSIZE_SMALL;
					break;
				case "26":
					newCmt.fontSize = FLY_FONTSIZE_BIG;
					break;
				default:
					newCmt.fontSize = FLY_FONTSIZE_NORMAL;
					break;
			}
			switch(newCmt.flyType){
				case "bottom":
					newCmt.flyType = FLY_TYPE_BOTTOM;
					break;
				case "top":
					newCmt.flyType = FLY_TYPE_TOP;
					break;
				default:
					newCmt.flyType = FLY_TYPE_FLY;
					break;
			}
			fly_var_queue[fly_var_queueLength] = newCmt;
			fly_var_queueLength++;
		}
	}		
	dgrComments.sortItemsBy("评论时间", "DESC");
	dgrComments.getColumnAt(0).width = 50;
//	dgrComments.getColumnAt(1).width = 100;
	dgrComments.getColumnAt(2).width = 150;
	
	fly_comment_new();
}


//字幕队列控制，出队列
//						（指定显示特定的评论，无论何种情况都强制显示）
function fly_comment_new(nextQueueIndex:Number, enforce:Boolean){
	//不显示弹幕则不用执行此函数
	if(!_comment_var_display) return false;
	
	 //设置函数参数默认值
	if(!enforceFlag) autoNext = false;
	if(!nextQueueIndex) nextQueueIndex = -1;
	
	//-----判断本次是否需要执行此函数，不需要则设置下一次执行时间，并退出
	var toExit = false;
	
	//视频没有在播放则不显示
	if(!video_var_playing) toExit = true;
	
	//如果需要显示的评论编号超出队列长度则不显示
	if(nextQueueIndex >= fly_var_queueLength || fly_var_indexNext >= fly_var_queueLength) toExit = true;
	
	
	//是否退出
	if(toExit && !enforce){
		setTimeout(fly_comment_new, FLASH_INTERVAL);
		return false;
	}
	
	var comment;
	switch(nextQueueIndex){
		case -1:	//如果没有指定需要显示的字幕，则显示fly_var_indexNext指定的字幕
			comment = fly_var_queue[fly_var_indexNext];
			break;
		default:
			comment = fly_var_queue[nextQueueIndex];
			break;
	}
	
	
	//如果评论是非飘移的字幕，则先不显示。这是因为字幕有可能在显示之前就被放到屏幕上，
	//对于飘移的字幕来说，即使在被显示之前放到屏幕上，其所在的位置也是不可见的，所以没关系，
	//但对于不会飘移的字幕来说，其位置是固定的，故不能立即提前把非飘移字幕放上来
	if((comment.sTime - _video_get_time()) * 1000 > FLASH_INTERVAL){
		setTimeout(fly_comment_new, FLASH_INTERVAL);
		return false;
	}
			
trace("[fly_comment_new] indexNext=" + fly_var_indexNext + ", videotime=" + _video_get_time() + ",sTime=" + comment.sTime + ", color=" + comment.fontColor + 
		", size=" + comment.fontSize + ", id=" + comment.cmtID + ", text=" + comment.cmtText + ", _fly_var_channels.length=" + _fly_var_channels.length);
	//该字体是否已经在通道上（即正在显示），是则查找下一个未显示的评论（此部分不完善，禁止多次调用）
	for(var i = 0; i < _fly_var_channels.length; i++){
		if(comment.cmtID == _fly_var_channels[i].cmtID){
			_fly_comment_set_nextnew(comment);
			return false;
		}
	}	
	trace("追踪调试：cmtID=" + comment.cmtID + ", text=" + comment.cmtText);
	_fly_comment_putScreen(comment);
	
	if(nextQueueIndex == -1) _fly_comment_set_nextnew(comment);		//只有显示非指定评论时才自动显示下一个，否则停止
}

//设置下一次显示字体的事件（你要说是时间也可以……不过这里写的就是事件没错）
function _fly_comment_set_nextnew(comment){
	fly_var_indexNext++;
	if(fly_var_indexNext < fly_var_queueLength){
		var nextTime = (fly_var_queue[fly_var_indexNext].sTime - _video_get_time()) * 1000;
		if(nextTime <= 0) nextTime = 1;		//如果已经超过了下一个字幕显示的时间延迟1ms后立刻显示下一字幕
		setTimeout(fly_comment_new, nextTime);
		//trace(getTimer() + " set [fly_comment_new] to " + (nextTime / 1000 + _video_get_time()) + ", after " + nextTime);
	}
	else{	//如果已经到末尾的话，就按照FLASH_INTERVAL的频率监控
		setTimeout(fly_comment_new, FLASH_INTERVAL);
	}
}


//把字幕放到屏幕上，并将字幕转交动画函数
//不用进行任何判断，判断都在fly_comment_new()函数中完成，这函数只管put上去并移交给动画控制就行了
function _fly_comment_putScreen(comment){
	//分配层
	_fly_var_level_accumulator++;
	var lvl = _fly_var_level_accumulator % FLY_LEVEL_RANGE;
	switch(comment.flyType){
		case FLY_TYPE_FLY:
			lvl += FLY_LEVEL_FLY;
			break;
		case FLY_TYPE_TOP:
			lvl += FLY_LEVEL_TOP;
			break;
		case FLY_TYPE_BOTTOM:
			lvl += FLY_LEVEL_BOTTOM;
			break;
	}
	
	//创建文本实例
	var txt:TextField = _level0.createTextField("popsub_" + comment.cmtID, lvl, FLY_STARTING_X, 1, 1, 1);
	txt.autoSize = true;
	txt.text = comment.cmtText;
	
	//给文本添加滤镜
	if(true || comment.fontColor == "ffffff"){
		var myFilters = txtFilterSample.filters;
		myFilters[0].color = 0x0; //parseInt(comment.fontColor, 16) ^ 0xffffff;
		txt.filters = myFilters;
	}

	//设置样式
	txt.setTextFormat(_fly_comment_get_style(comment.fontColor, comment.fontSize));
	//设置非飘移字体的位置
	if(comment.flyType != FLY_TYPE_FLY){
		txt._visible = false;
		txt._x = (ytVideo._width - txt.textWidth) / 2;
	}
	
	//请求通道，并将文本放到通道上
	var channel = _channel_request(comment, txt);
	txt._y = channel[0];
	//显示文本
	fly_show(txt, comment.flySpeed, comment.sTime, comment.flyType, comment.cmtID);
}



	
//获取字体格式对象，返回 TextFormat
function _fly_comment_get_style(fColor, fSize){
	var s:TextFormat = new TextFormat;
	s.bold = true;
	s.size = fSize;
	s.color = int("0x" + fColor);
	return s;
}

//评论显示开始
function fly_show(txt:TextField, speed:Number, startTime:Number, flyType:Number, cmtID:Number){
	if(flyType == FLY_TYPE_FLY){		//飘移的字幕
		setTimeout(_fly_move, (startTime - _video_get_time()) * 1000, txt, speed, startTime, cmtID);
	}
	else{		//定点显示的字幕
		txt._visible = true;
		trace("[fly_show] text=" + txt.text + ", speed=" + speed + ", _visible=" + txt._visible + ", txt._x=" + txt._x + ", txt._y=" + txt._y);
		setTimeout(_fly_delete, speed * 1000, cmtID, txt);
	}
}

//内部 刷新评论位置
function _fly_move(txt:TextField, speed:Number, startTime:Number, cmtID:Number){
	//若已经超出时间则退出
	var timePass:Number = _video_get_time() - startTime;
	//trace("[_fly_move]（计算是否超时） timePass=" + timePass + ", speed=" + speed + ", _video_get_time() - ns.time = " + (_video_get_time() - ns.time));
	/*
	 * 因为这里的timePass计算出来的值可能受到计算机性能影响而造成偏差，所以这里加上预期的偏差值
	 */
	if(timePass > speed || timePass + Math.abs(_video_get_time() - ns.time) <= 0){
		_fly_delete(cmtID, txt);
		return false;	
	}

	//计算当前字幕的x坐标（可能是负值）
	var txtX = (FLY_STARTING_X + txt.textWidth) * (timePass / speed);		//字幕离开起点的距离
	txtX = FLY_STARTING_X - txtX;
	if(video_var_playing && false){
		txtX = (txt.textWidth + FLY_STARTING_X) / (speed * 1000 / FLY_FLASH_INTERVAL);
		txt._x -= txtX;
	}
	else{
		txt._x = txtX;
		//debug = debug + "\n" + ns.time + "," + startTime + "," + timePass + "," + getTimer() + "," + txtX;
	}
	//trace("(_fly_move) x = " + txtX + ", cmtID=" + cmtID + ", timePass=" + timePass + ", speed=" + speed + ", txt.textWidth = " + txt.textWidth + ", FLY_STARTING_X=" + FLY_STARTING_X);
	setTimeout(_fly_move, FLY_FLASH_INTERVAL, txt, speed, startTime, cmtID);
}

/**
 * 删除弹幕
 * 
 * 根据弹幕编号来删除现有的弹幕
 * （我对这个函数还有疑问，但是现在先不审阅了，感觉上这个函数做的事情太多了点，不过可能也是我想错了，先留着在这里好了——2010.1.22）
 * 
 * @param Number cmtID	欲删除的弹幕编号
 * @param TextField txt	该弹幕对应的文本域（可为空）
 * @return Boolean	若删除成功，返回true，删除失败或未删除则返回false，找不到此弹幕或文本域也返回false
 */
function _fly_delete(cmtID:Number, txt:TextField){
	var cmt = null;
	if (txt == null) txt = eval("popsub_" + _fly_var_channels[i].cmtID);
	
	//判断当前的播放时间是否已经到达了应该删除的时间，这是为了防止影片暂停的时候留言被删除
	//但如果是不显示弹幕的话则不管三七二十一一律删除
	// 另外，为了配合通道选择时试图删除当前弹幕获取最低通道，所以也应该判断这个弹幕是否可删除
	for(var i = 0; i < _fly_var_channels.length; i++){
		if(_fly_var_channels[i].cmtID == cmtID){
			cmt = _fly_var_channels[i];
			i = _fly_var_channels.length;
		}
	}
	var leaveTime = cmt.sTime + cmt.flySpeed - _video_get_time();
	trace("[fly_delete]删除判断：leaveTime = " + cmt.sTime + " + " + cmt.flySpeed + " - " + _video_get_time() + ", rTime - nsTime = " + (_video_get_time() - ns.time));
	trace("[_fly_delete]删除判断：leaveTime=" + leaveTime + ", cmt.flySpeed=" + cmt.flySpeed + ", _comment_var_display=" + _comment_var_display);
	// 这里比较哔——。在通道选择的时候会调用此函数试图删除已经应该删除的弹幕以获得最低弹幕通道。理论上来说在选择通道的时候计算弹幕消失的时间应该是0了，但是结果却是0.0109999999999xx，或者0.0190000000xx之类的，有10毫秒左右的误差
	// 据猜测这个误差可能是timer控件的精确度引起的，而且嘛，反正10毫秒的时间人也反应不过来，干脆就这样。如果弹幕剩余的生存期已经小于0.02秒的话，也直接删除了。
	// 于是下面的 leaveTime 就改成 > 0.02，只有生存期大于0.02秒才不删除
	// 然后发现如果性能比较差劲的时候，这个结果可能会大于0.02，变成0.02xxxx，于是决定改成0.04，这样帧速变成25，也能让人眼接受了
	if(leaveTime > 0.04 && _comment_var_display){
		//——【不删除】
		setTimeout(_fly_delete, leaveTime * 1000, cmtID, txt);
		
		return false;
	}
	else{
		//——【删除】
		trace(getTimer() + ",[_fly_delete](删除弹幕) cmtID=" + cmtID + ", txt=" + txt.text);
		//释放通道
		_fly_channel_release(cmtID);
		//删除文本实例
		txt.removeTextField();
		
		return true;
	}
}

//内部 通道占用
function _fly_channel_occupy(chl){
	//如果数组空则直接push进去
	if(_fly_var_channels.length == 0){
		_fly_var_channels.push(chl);
		return false;
	}
	//数组不空才需要查找
	var i = 0;
	while(i < _fly_var_channels.length){
		if(_fly_var_channels[i].channel >= chl.channel){
			break;
		}
		i++;
	}
	_fly_var_channels.splice(i, 0, chl);
}
	

//内部 通道释放
function _fly_channel_release(cmtID){
	for(var i = 0; i < _fly_var_channels.length; i++){
		if(_fly_var_channels[i].cmtID == cmtID){
			_fly_var_channels.splice(i, 1);
			break;
		}
	}
}		


/***************************************/
/********** 弹幕通道申请函数 *************/
/***************************************/
/**
 * 数据类型说明
 * 
 * typedef channel_t
 * channel_t 类型数据
 * 
 * 该数据类型同时为 _fly_var_channels 数组所使用
 */
 
/**
 * 分配通道
 * 
 * 该函数会根据当前屏幕上的弹幕情况，决定分配哪个通道给申请通道的弹幕
 * 
 * @param Object cmt	申请通道的弹幕对象
 * @param TextField txt		已经初始化的文本域对象
 * @return Array	一维数组，r[0]表示申请到的通道，已经根据影片高度取模，可以直接显示；r[1]表示弹幕所在层
 */
function _channel_request(cmt:Object, txt:TextField) {
	var ret:Array = Array(0, 1);
	var chl_try:Number;
	var conflicts:Array;
	var i:Number;
	var gotChannel:Boolean;
	var curr:channel_t = new channel_t(txt, cmt);

	if (curr.channel != null) {
		_fly_channel_occupy(curr);
		ret[0] = curr.channel;
		
		return ret;
	}

	/**
	 * 特别地，对于底部类型的弹幕，其通道是从负的影片高度开始的，并且和飞行类以及顶部弹幕不冲突
	 * 查找冲突弹幕的时候，这两种类型的弹幕就要分开处理，顶部类弹幕自然是从0号通道开始查找冲突
	 * 而底部类弹幕则是从负的影片高度通道开始查找冲突
	 */
	if (cmt.flyType == FLY_TYPE_FLY || cmt.flyType == FLY_TYPE_TOP) {
		ret[0] = 0;
	}
	else {
		ret[0] = -popsub_area_height;
	}
	curr.channel = ret[0];
	
	/**
	 * 确定首个开始检查的通道之后，就调用冲突查询函数，列出所有屏幕上与当前通道冲突的弹幕占用的通道以及弹幕数据
	 */
	do {
		gotChannel = true;
		conflicts = _channel_get_conflicts(int(curr.channel), int(curr.channelBreadth));
		//trace("冲突检查结果数：" + conflicts.length);
		for (i = 0; i < conflicts.length; i++) {
			/**
			 * 见图 1.1.1
			 */
			if (_channel_check_conflict(curr, conflicts[i]) == false) {
				// 没有冲突，可以继续下一个通道的检查
			}
			else if (_fly_delete(conflicts[i].cmtID) == true) {
				// 删除成功，所以不算冲突，可以继续下一个通道的检查
			}
			else {
				// 存在冲突，不能分配这个通道
				trace("conflicts[" + i + "].channel=" + conflicts[i].channel);
				ret[0] = conflicts[i].channel + int(conflicts[i].channelBreadth) + 1;
				curr.channel = ret[0];
				gotChannel = false;
				//trace("设置通道到 " + ret[0]);
				break;
			}
		}
	}
	while (!gotChannel);
	
	ret[0] = _channel_do_mod(curr.channel, curr.channelBreadth, curr.flyType);
	_fly_channel_occupy(curr);

	ret[0] -= 2;
	return ret;
}

/**
 * 获取当前所有冲突通道
 * 
 * 该函数会根据（也仅仅根据）当前弹幕的通道占用信息来检查冲突，并以一个数组返回所有冲突
 * 
 * @param Number r_chl	欲进行冲突检查的通道（r_chl = request_chl）
 * @param Number r_breadth	欲进行冲突检查的通道宽度
 * @return Array(channel_t)	所有冲突的通道，按通道升序排序
 */
function _channel_get_conflicts(r_chl:Number, r_breadth:Number) {
	var ret:Array = new Array();
	var i:Number = 0;
	var r_bot:Number = r_chl + r_breadth;
	
	trace(_fly_var_channels[i].text);
	trace("(" + i + ") " + _fly_var_channels[i].cmtID + " <  " + r_chl  + "+" + r_breadth);
	for (i = 0; i < _fly_var_channels.length && (_fly_var_channels[i].channel < r_chl + r_breadth || true); i++) {
		var cur_chl:channel_t = _fly_var_channels[i];
		var chl_top:Number = int(cur_chl.channel);
		var chl_bot:Number = int(chl_top) + int(cur_chl.channelBreadth);
		/**
		 * 见图 1.2
		 */
		if ((chl_bot >= r_chl && chl_bot <= r_bot) ||
			(chl_top >= r_chl && chl_top <= r_bot) ||
			(chl_top <= r_chl && chl_bot >= r_bot))
		{
			trace("　冲突：r_chl=" + r_chl + ", r_bot=" + r_bot + ", chl_top=" + chl_top + ", chl_bot=" + chl_bot);
			ret.push(cur_chl);
		}
		else {
			trace("不冲突：r_chl=" + r_chl + ", r_bot=" + r_bot + ", chl_top=" + chl_top + ", chl_bot=" + chl_bot);
		}
	}
	
	return ret;
}

/**
 * 弹幕申请通道冲突判断
 * 
 * @param channel_t curr	当前弹幕通道
 * @param channel_t prev	目前已经存在的弹幕通道
 * @return Boolean	是否冲突，true为发生冲突，false为没有冲突
 */
function _channel_check_conflict(curr:channel_t, prev:channel_t) {
	/**
	 * 见图 2.x
	 * 在水平方向上判断是否有冲突，实质上顶部、底部和字幕等固定弹幕的性质都是相同的，只需要区分出飞行弹幕和其他弹幕就可以了
	 */
	switch (curr.flyType) {
		case FLY_TYPE_FLY:
			return _channel_check_conflict_fly(curr, prev);
			break;
		case FLY_TYPE_TOP:
		case FLY_TYPE_BOTTOM:
		case FLY_TYPE_SUBTITLE:
			return _channel_check_conflict_top(curr, prev);
			break;
	}
	return true;
}


/**
 * 飞行弹幕通道冲突判断（水平方向）
 * 
 * @param 见 _channel_check_conflict 函数
 * @return 见 _channel_check_conflict 函数
 */
function _channel_check_conflict_fly(curr:channel_t, prev:channel_t) {
	var curr_left_to_area_left:Number;		// 当前弹幕的左边缘碰到播放区域左边的片时
	var prev_right:Number;					// 前弹幕右边缘的水平坐标
	var curr_left_to_prev_right:Number;	// 当前弹幕碰到前弹幕（仅限静止弹幕）右边缘的时间
	
	/**
	 * 计算方法参考 图 2.1
	 */
	curr_left_to_area_left = (curr.deathTime - curr.sTime) * (popsub_area_width / (curr.textWidth + popsub_area_width)) + curr.sTime;
	prev_right = eval("popsub_" + prev.cmtID)._x + prev.textWidth;
	curr_left_to_prev_right = (curr.deathTime - curr.sTime) * ((popsub_area_width - prev_right) / (curr.textWidth + popsub_area_width)) + curr.sTime;
	
	/**
	 * 见图 2.1
	 */
	switch (prev.flyType) {
		/**
		 * 见图 2.2.1
		 */	
		case FLY_TYPE_FLY:
			// 追尾
			if (curr_left_to_area_left < prev.deathTime) return true;
			
			// 出不来
			if (eval("popsub_" + prev.cmtID)._x + prev.textWidth >= popsub_area_width) return true;
			
			break;
			
		/**
		 * 见图 2.2.2
		 */
		case FLY_TYPE_TOP:
		case FLY_TYPE_BOTTOM:
		case FLY_TYPE_SUBTITLE:
			// 追尾
			if (curr_left_to_prev_right < prev.deathTime) return true;
			
			// 出不来
			if (prev_right > popsub_area_width) return true;
			
			break;
			
		default:
			return true;
			break;
	}
	
	return false;
} 

/**
 * 顶部弹幕通道冲突判断（水平方向）
 * 
 * @param 见 _channel_request 函数
 * @return 见 _channel_request 函数
 */
function _channel_check_conflict_top(curr:channel_t, prev:channel_t) {
	var onshow_prev_left:Number;	// 在本弹幕出现时，前弹幕（仅限飞行类）左边缘的水平坐标
	var onshow_prev_right:Number;	// 在本弹幕出现时，前弹幕（仅限飞行类）右边缘的水平坐标
	var ondel_prev_left:Number;	// 在本弹幕消失时，前弹幕（仅限飞行类）左边缘的水平坐标
	var ondel_prev_right:Number;	// 在本弹幕消失时，前弹幕（仅限飞行类）右边缘的水平坐标
	var curr_left:Number;		// 本弹幕左边缘的水平坐标
	var curr_right:Number;		// 本弹幕右边缘的水平坐标
	var prev_left:Number;		// 前弹幕（仅限固定类）左边缘的水平坐标
	var perv_right:Number;		// 前弹幕（仅限固定类）右边缘的水平坐标
	
	/**
	 * 计算方法见 图 2.2
	 */
	onshow_prev_left = popsub_area_width - (prev.textWidth + popsub_area_width) * ((curr.sTime - prev.sTime) / (prev.deathTime - prev.sTime))
	onshow_prev_right = onshow_prev_left + prev.textWidth;
	ondel_prev_left = popsub_area_width - (prev.textWidth + popsub_area_width) * ((curr.deathTime - prev.sTime) / (prev.deathTime - prev.sTime))
	ondel_prev_right = ondel_prev_left + prev.textWidth;
	curr_left = eval("popsub_" + curr.cmtID)._x;
	curr_right = curr_left + curr.textWidth;
	prev_left = eval("popsub_" + prev.cmtID)._x;
	prev_right = prev_left + prev.textWidth;
	
	/**
	 * 见图 2.2
	 */
	switch (prev.flyType) {
		/**
		 * 见图 2.2.1
		 */
		case FLY_TYPE_FLY:
			// 不能与头区间有水平交集
			if (!(curr_right < ondel_prev_left || curr_left > onshow_prev_left)) return true;
			
			// 不能与尾区间有水平交集
			if (!(curr_right < ondel_prev_right || curr_left > onshow_prev_right)) return true;
			
			break;
		
		/**
		 * 见图 2.2.2
		 */
		case FLY_TYPE_TOP:
		case FLY_TYPE_BOTTOM:
		case FLY_TYPE_SUBTITLE:
			// 盖尾
			if (curr_left >= prev_left && curr_left <= prev_right) return true;
			
			// 盖头
			if (curr_right >= prev_left && curr_right <= prev_right) return true;
			
			// 超盖
			if (curr_left <= prev_left && curr_right >= prev_right) return true;
			
			break;
		
		default:
			return true;
			break;
	}
	
	return false;
} 

/**
 * 通道取模计算
 * 
 * 对已经分配好的通道进行取模计算，以符合影片高度
 * 
 * @param Number channel	分配的通道
 * @param Number breadth	通道占用的宽度
 * @param Number fly_type	弹幕类型
 * @return Number	通道计算结果
 */
function _channel_do_mod(channel:Number, breadth:Number, fly_type:Number) {
	var m:Number;
	trace("传入通道: " + channel + ", breadth=" + breadth + ", flyType=" + fly_type);
	m = popsub_area_height - breadth;
	m = 200;
	
	switch (fly_type) {
		case FLY_TYPE_FLY:
		case FLY_TYPE_TOP:
			trace("判断顶部类型弹幕");
			channel %= m;
			break;
		case FLY_TYPE_BOTTOM:
		case FLY_TYPE_SUBTITLE:
			/**
			 * 见图 1.3
			 */
			m = popsub_area_height - breadth;
			while (channel > 0) ret -= m;
			channel = -(channel + breadth);
			break;
	}
	trace("mod计算结果：" + channel);
	return channel;
}
/********************************/
/*********通道分配函数 结束********/
/********************************/

//添加新评论
function comment_add_comment(con, attr){
	//先查找位置和分配一个ID，顺便插入位置
	var id:Number = 0;
	var insertPos:Number = 0;
	for(var i = 0; i < fly_var_queue.length; i++){
		if(id < fly_var_queue[i].cmtID) id = fly_var_queue[i].cmtID;
		if(attr.sTime > fly_var_queue[i].sTime){
			insertPos++;
		}
	}
	id += ++_comment_user_total;
	
	//压入弹幕数据库
	var newCmt:Object = {
		cmtID:id,
		cmtText:con,
		sTime:(attr.sTime * 1),	//单位：s，基于影片开始的时间戳
		fontColor:attr.fontColor.toString(16),
		fontSize:attr.fontSize,
		flyType:attr.flyType,
		flySpeed:(attr.flySpeed) //单位：s
	}

	//添加到右部评论
	dgrComments.addItemAt(0, {
		片时:_sec2disTime(attr.sTime),
		内容:con, 
		评论时间:_date2date(new Date())
	});
	
	//偷懒……直接压到 fly_var_indexNext 这个位置去，然后就不用 _comment_seek 了
	fly_var_queue.splice(insertPos, 0, newCmt);
	fly_var_queueLength++;
	
	fly_comment_new(insertPos, true);
	
	//看看要不要重启动
	//if(fly_var_indexNext >= fly_var_queueLength - 1) fly_comment_new();
}
		

//重新从 tTime:秒 处开始显示评论
function _comment_seek(tTime){
	var needRestart = false;
	var chl = null;
	if(tTime == -1) tTime = ns.time;
	//在字幕列表中查找相应的位置，设置 _fly_var_nextIndex
	//这里应该找到这个时间之前还不应该消失字幕
	for(var i = 0; i < fly_var_queue.length; i++){
		trace("_comment_seek查找判断：i=" + i + ", tTime=" + tTime + ", sTime=" + fly_var_queue[i].sTime + ", flySpeed=" + fly_var_queue[i].flySpeed);
		if(tTime <= (fly_var_queue[i].sTime + fly_var_queue[i].flySpeed)){
			if(fly_var_indexNext >= fly_var_queueLength) needRestart = true;
			fly_var_indexNext = i;
			i = fly_var_queue.length;
		}
	}
	
	//扫描通道列表，删除在这个时间不应该显示的弹幕所占用的通道
	var delList:Array = new Array();
	for(var i = 0; i < _fly_var_channels.length; i++){
		chl = _fly_var_channels[i];
		if(tTime < chl.sTime || tTime > chl.sTime + chl.flySpeed){
			delList.push(chl.cmtID);
		}
	}
	//删除已经释放了通道的TextField对象
	for(var i = 0; i < delList.length; i++){
		_fly_channel_release(delList[i]);
		eval("popsub_" + delList[i]).removeTextField();
	}
	
	//设置下一次显示字幕的调用，如果不是已经没有字幕要显示的话
	var nextTime = 0;
	nextTime = fly_var_queue[fly_var_indexNext].sTime - tTime;
	nextTime *= 1000;
	if(nextTime <= 0) nextTime = 1;
	trace("[_comment_seek] set next after " + nextTime + ", fly_var_indexNext=" + fly_var_indexNext + ", ns.time=" + ns.time + ", _video_get_time()=" + _video_get_time() + ", tTime=" + tTime);
	if(nextTime > 0){
		setTimeout(fly_comment_new, nextTime);
	}
	//if(needRestart) fly_comment_new();	//如果已经到队尾的话必须重新启动字幕显示进程
}
	


//评论显示与否
function comment_display(btn){
	_comment_var_display = !_comment_var_display;
	if(_comment_var_display){
		_comment_show();
		btn.label = "隐藏评论";
		btn.setStyle("color", 0x000000);
		btn.setStyle("fontWeight", "");
	}
	else{
		_comment_hide();
		btn.label = "显示评论";
		btn.setStyle("color", 0x006600);
		btn.setStyle("fontWeight", "bold");
	}
	
}

function _comment_show(){
	_comment_seek(_video_get_time());
}
function _comment_hide(){
	var delID:Number = 0;
	while(_fly_var_channels.length > 0){
		delID = _fly_var_channels[0].cmtID;
		_fly_delete(delID);
	}
}