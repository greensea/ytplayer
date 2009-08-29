/** ytPlayer  飘移评论控制脚本 **/

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
var fly_var_queue:Array = new Array();
var _fly_var_channels:Array = new Array();		//Array(channelID, {cmtID:Number, channelBreadth:Number, deathTime:playTime-Seconds})
var fly_subtitle_redline = ytVideo._height;			//当前字幕所占据的高度
var _fly_var_level_accumulator = 0;

var _comment_var_display = true;		//是否显示评论
var _comment_user_total = 0;		//记录用户在本页面发表的评论总数



//获取字幕源XML
function fly_comment_push(xmlcmt){	
	var cmts = xml_getElementByTagName(xmlcmt, "comments").childNodes;
	fly_var_queueLength = 0;
	fly_var_queue = new Array();
	for(var i = 0; i < cmts.length; i++){
		if(cmts[i].nodeName){
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
				flySpeed:(cmts[i].attributes["flySpeed"] / 1000.0) //单位：s
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
		if(comment.cmtID == _fly_var_channels[i][1].cmtID){
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
	var channel = _fly_channel_request(comment, txt);
	txt._y = channel[0];
	
	//显示文本
	fly_show(txt, comment.flyTime, comment.sTime, comment.flyType, comment.cmtID);
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
		//trace("[fly_show] text=" + txt.text + ", speed=" + speed + ", _visible=" + txt._visible + ", txt._x=" + txt._x + ", txt._y=" + txt._y);
		setTimeout(_fly_delete, speed * 1000, cmtID, txt);
	}
}

//内部 刷新评论位置
function _fly_move(txt:TextField, speed:Number, startTime:Number, cmtID:Number){
	//若已经超出时间则退出
	var timePass:Number = _video_get_time() - startTime;
	if(timePass > speed || timePass <= 0){
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
	setTimeout(_fly_move, FLY_FLASH_INTERVAL, txt, speed, startTime, cmtID);
}

//内部 删除评论
var debug:String;
function _fly_delete(cmtID:Number, txt:TextField){
	var cmt = null;
	//判断当前的播放时间是否已经到达了应该删除的时间，这是为了防止影片暂停的时候留言被删除
	//但如果是不显示弹幕的话则不管三七二十一一律删除
	// 另外，为了配合通道选择时试图删除当前弹幕获取最低通道，所以也应该判断这个弹幕是否可删除
	for(var i = 0; i < _fly_var_channels.length; i++){
		if(_fly_var_channels[i][1].cmtID == cmtID){
			cmt = _fly_var_channels[i][1];
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
		if(_fly_var_channels[i][0] >= chl[0]){
			break;
		}
		i++;
	}
	_fly_var_channels.splice(i, 0, chl);

}
	

//内部 通道释放
function _fly_channel_release(cmtID){
	for(var i = 0; i < _fly_var_channels.length; i++){
		if(_fly_var_channels[i][1].cmtID == cmtID){
			_fly_var_channels.splice(i, 1);
			break;
		}
	}
}		

//内部 核心 通道请求
function _fly_channel_request(cmt, txt:TextField){
	var debugstr:String;
	
	var cl = Array(1, 1);	//(通道，层) cl-->Channel Level
	/*数据结构定义 _fly_var_channels */
	var lastCheckShareChannel = 0;
	var chl = new Array(0, 
							{
							cmtID:cmt.cmtID, 
							channelBreadth:cmt.fontSize + 2, 
							deathTime:(cmt.sTime + cmt.flySpeed), 
							textWidth:txt.textWidth, 
							text:cmt.cmtText, 
							sTime:cmt.sTime,
							flyType:cmt.flyType,
							flySpeed:cmt.flySpeed
							}
					   	);
	
	//分配通道
	switch(cmt.flyType){
		case FLY_TYPE_BOTTOM:
			//设置查找初始位置。chl[0]指的是弹幕的上边框所占据的通道号
			if(chl[1].isSubtitle){
				chl[0] = ytVideo._height - chl[1].channelBreadth;
			}
			else{
				chl[0] = fly_subtitle_redline - chl[1].channelBreadth;
			}
			
			trace("[_fly_channel_request]{FLY_TYPE_BOTTOM} minBottomPopsubChl=" + chl[0]);
			
			//从尾开始查找可用的通道，因为第二页以后就是负的通道ID，所以基本上不会与FLY和TOP的字幕相互影响
			tryChannel = chl[0];
			for (var i = _fly_var_channels.length - 1; i >= 0; i--) {
				// 跳过不是底部的弹幕
				if (_fly_var_channels[i][1].flyType != FLY_TYPE_BOTTOM) continue;
				
				// 先试图删除当前弹幕
				if (_fly_delete(_fly_var_channels[i][1].cmtID, eval("popsub_" + _fly_var_channels[i][1].cmtID)) == false) {
					// 删除失败，必须处理此弹幕
					// 判断是否冲突，如果冲突，则使用该弹幕的顶边框通道作为申请通道底边框通道；如果不冲突，可以使用当前通道，并退出
					// 申请的通道小于当前弹幕的底边框通道，则冲突
					if (tryChannel < _fly_var_channels[i][0] + _fly_var_channels[i][1].channelBreadth) {
						tryChannel = _fly_var_channels[i][0] - chl[1].channelBreadth;
						chl[0] = tryChannel;
					}
					else {
						break;
					}
				}
				else {
					// 删除成功，可以跳过
					i--;
				}
			}
			
			if(chl[0] <= 0){
				var modNum = 0;
				if(chl[1].isSubtitle){
					modNum = (ytVideo._height - chl[1].channelBreadth);
				}
				else{
					modNum = FLY_SUBTITLE_REDLINE - chl[1].channelBreadth;
				}
				chl[0] = chl[0] % modNum + modNum;
			}
			cl[0] = chl[0] - 1;		//因为是底部对齐的，所以让它离开底部1个像素会比较好看
			cl[1] = 0;	//废弃行，本来是层编号的
			
			trace("[_fly_channel_request]{FLY_TYPE_BOTTOM}(分配通道) cmtID=" + cmt.cmtID + ", cmttext=" + cmt.cmtText + ", cl[0] = " + cl[0]);
						
			break;
			
		
		//默认的飘移字幕和顶部字幕的通道分配
		default:
		
			//从头开始查找可用的通道，直到字幕红线为止
			var fFlag = false;
			//先设置查找初始数组索引，直到找到通道0为止
			var stIndex = 0;
			if(_fly_var_channels.length != 0){
				//查找到非负通道，也就是非底部评论的通道
				while(!fFlag && stIndex <= _fly_var_channels.length){
					if(_fly_var_channels[stIndex][0] >= 0){
						fFlag = true;
					}
					else{
						stIndex++;
					}
				}
				//如果到了数组末尾还找不到大于0的通道就可以从通道1开始分配
				if(stIndex == _fly_var_channels.length){
					fFlag = true;
					chl[0] = 1;
				}
				else{
					fFlag = false;
				}
			}

			//循环查找可用的通道
			while(!fFlag){
				chl[0]++;
				if(_fly_var_channels.length == 0){	//如果已经分配的通道数为0则可以直接分配1号通道
					fFlag = true;
				}
				else{			//否则就要查找可用的通道
					if(_fly_var_channels[stIndex][0] >= chl[0] + chl[1].channelBreadth){		//如果前通道头大于本通道尾，继续判断
						//还要判断我们的通道尾有没有超过下一个通道的头
						if(stIndex + 1 == _fly_var_channels.length){	//后面已经没有通道了，可以分配
							fFlag = true;
							
						}
						else if(_fly_var_channels[stIndex + 1][0] >= chl[0] + chl[1].channelBreadth){	//否则还要判断一下
							fFlag = true;
						}
					}
					if(!fFlag && lastCheckShareChannel != _fly_var_channels[stIndex][0]){	//否则，计算是否能在该通道占用者消失前使用该通道
					/**************
					·这里的情况比较复杂，共有4种不同的情况，其中的3中情况都有可能让两个字幕共享同一通道
						·为方便描述，这里做个约定：当前占用通道的字幕称为“前字幕”，试图使用此通道的字幕称为“本字幕”；
					放置字幕的TextField的左边框成为“字幕头”，右边框称为“字幕尾”
					·（字幕都是自右向左飞行的）
					·首先看下表
					----------------------------------------------------------------------
					~\	本字幕	前字幕	|	可以共享此通道的条件
					----------------------------------------------------------------------
					1	飞行		飞行		|前字幕尾消失前，本字幕头X坐标不能小于飞行范围的X零坐标
					2	飞行		固定		|前字幕消失前，本字幕头X坐标不能小于前字幕尾的X坐标
					3	固定		飞行		|本字幕出现前，前字幕尾X坐标必须小于本字幕头X坐标
					4	固定		固定		|这种情况无论如何不能共享通道
					----------------------------------------------------------------------
					·下面就要分开这三种情况编写响应的代码进行判断
					**************/
						var ourTime:Number;	//我们字幕的头碰到左边（或碰到现有字幕右边）（或……）的时间
						var hisTime:Number;	//他们字幕的尾碰到左边（或他们字幕消失）（或……）的时间
						var hisAllShowedTime:Number;	//前字幕尾已经出现（即前字幕已经完全显示出来）的时间
						var prevCmt = _fly_var_channels[stIndex];
						switch(cmt.flyType){
							case FLY_TYPE_FLY:
								if(prevCmt[1].flyType == FLY_TYPE_FLY){	//第1种情况
									//trace("情况1 stIndex=" + stIndex);
									hisTime = prevCmt[1].deathTime;
									ourTime = cmt.flySpeed * (FLY_STARTING_X / (txt.textWidth + FLY_STARTING_X)) + cmt.sTime;
									hisAllShowedTime = prevCmt[1].textWidth / (FLY_STARTING_X + prevCmt[1].textWidth) * prevCmt[1].flySpeed + prevCmt[1].sTime;
									//这里注意，这里偷懒了点。如果前字幕是一个比屏幕还长的字幕的话，可能这时候这个字幕还没有完全显示出来，
									//这个时候如果共享通道的话，就会发生冲突
									//现在仅仅判断前字幕是否过长，其实可以判断前字幕是否已经完全显示出来，偷懒了 = =  
									// 本字幕头后于前字幕尾到达左边  且  前字幕长度小于屏幕长度  且  前字幕尾已出现（前字幕尾先于本字幕头出现）
									if(ourTime >= hisTime && prevCmt[1].textWidth < FLY_STARTING_X && hisAllShowedTime < cmt.sTime){
										fFlag = true;
										//chl[0] += 1;
										trace("情况1 前字幕非过长 stIndex=" + stIndex + ", fFlag=" + fFlag + ",下注vvv");
										trace(ourTime + " >=" + hisTime + " && " + prevCmt[1].textWidth + " < " + FLY_STARTING_X
															+ " && " + hisAllShowedTime + " < " + cmt.sTime);
									}
									else{
										lastCheckShareChannel = prevCmt[0];		//这里是防止如果该通道已经共享的话，重复地与此通道中的两个字幕对比
									}
								}
								else{	//第2种情况
									hisTime = prevCmt[1].deathTime;
									ourTime = ((FLY_STARTING_X - prevCmt[1].textWidth) / 2) / (txt.textWidth + FLY_STARTING_X) * cmt.flySpeed + cmt.sTime;
									if(ourTime > hisTime){
										fFlag = true;
									}
								}
								break;
							case FLY_TYPE_TOP:
								if(prevCmt[1].flyType == FLY_TYPE_FLY){		//第3种情况
									//			（						本字幕空隙      +	本字幕长度	  +	前字幕长度）			/	(前字幕总长）
									hisTime = ((FLY_STARTING_X - txt.textWidth) / 2 + chl[1].textWidth + prevCmt[1].textWidth) / (prevCmt[1].textWidth + FLY_STARTING_X);
									hisTime = hisTime * prevCmt[1].flySpeed + prevCmt[1].sTime;
									ourTime = chl[1].sTime;
									if(ourTime > hisTime){
										fFlag = true;
									}
									else{
										lastCheckShareChannel = prevCmt[0];
									}
								}

								break;
						}
					}
									
					//如果还是不行的话就只能死翘翘了，继续查找吧
					if(!fFlag){
						chl[0] = _fly_var_channels[stIndex][0] + _fly_var_channels[stIndex][1].channelBreadth + 1;
						stIndex++;

						if(stIndex >= _fly_var_channels.length){
							fFlag = true;
						}
					}

				}
			}
			//超过字幕红线的必须从头取模，另加一个小偏移量，避免通道ID完全一致
			debugstr += ", chl[0]=" + chl[0] + ", breadth=" + chl[1].channelBreadth;
			/*if(chl[0] + chl[1].channelBreadth >= fly_subtitle_redline){
				chl[0] = chl[0] % FLY_SUBTITLE_RANGE + Math.round(chl[0] % FLY_SUBTITLE_RANGE);
			}*/
			
			
			//！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
			//弱弱地尝试一下仅允许偶数通道，懒得去查找是哪里造成了本来可以使用同一通道的两个字幕使用了相差为1的两个通道
			//虽然是很XXOO的解决方法，极有可能失败，但还是试一下吧
			//--不行，++才行
			if(chl[0] / 2 == Math.round(chl[0] / 2)){
				chl[0]++;
			}
			
			//查找终于完毕了
			cl[0] = chl[0];
			
			//超过字幕红线的必须从头取模，然后减去该字幕的带宽，去绝对值。至于为什么请看算法文档
			if(cl[0] + chl[1].channelBreadth >= fly_subtitle_redline){
				debugstr += ", modnum=" + Math.round(fly_subtitle_redline - FLY_SUBTITLE_RANGE - chl[1].channelBreadth);// - fly_subtitle_redline - chl[1].channelBreadth);
				cl[0] = cl[0] % Math.round(fly_subtitle_redline - FLY_SUBTITLE_RANGE - chl[1].channelBreadth);
				cl[0] = Math.abs(cl[0] - chl[1].channelBreadth);
			}
			
			cl[1] = 0;		//废弃行，本来是用于层编号的
			
			break;
			
/*		case FLY_TYPE_TOP:
			cl[0] = (ytVideo._y + chl[1].channelBreadth);
			cl[1] = FLY_LEVEL_TOP + lvl;
			break;
*/

	}
	
	
	debugstr += ", cl[0]=" + cl[0];
	debugstr += ", chl[0]=" + chl[0];
	//trace("分配通道：" + debugstr);
	
	_fly_channel_occupy(chl);
	
	return cl;
}

//添加新评论
function comment_add_comment(con, attr){
	//先查找位置和分配一个ID，顺便插入位置
	var id = 0;
	var insertPos = 0;
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
		if(tTime < chl[1].sTime || tTime > chl[1].sTime + chl[1].flySpeed){
			delList.push(chl[1].cmtID);
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
		delID = _fly_var_channels[0][1].cmtID;
		_fly_delete(delID, eval("popsub_" + delID));
	}
}