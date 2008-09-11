/** ytPlayer  飘移评论控制脚本 **/
var FLY_SPEED_FAST:Number = 1;		//快字幕速度：秒
var FLY_SPEED_NORMAL:Number = 3;	//中等速度字幕：秒
var FLY_SPEED_SLOW:Number = 5;		//慢字幕速度：秒
var FLY_FONTSIZE_BIG:Number = 26;		//字体大小，大：像素
var FLY_FONTSIZE_NORMAL:Number = 22;	//字体大小，中：像素
var FLY_FONTSIZE_SMALL:Number = 14;		//字体大小，小：像素
var FLY_TYPE_TOP:Number = 0x2;
var FLY_TYPE_BOTTOM:Number = 0x0;
var FLY_TYPE_FLY:Number = 0x3;

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


fly_get_xml();

//获取字幕源XML
function fly_get_xml(url){
	var nsCmt:XML = new XML;
	tip_add("读取评论…");
	//nsCmt.load("http://bbs.bbxy.net/sitemap_baidu.xml");
	//trace(nsCmt);
	fly_var_queue.push({cmtID:1, cmtText:"这条是测试的评论", sTime:5, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:2, cmtText:"这条是测试的评论——很长很长的哦~", sTime:2.1, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:3, cmtText:"这条是测试的评论~", sTime:2.5, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:4, cmtText:"fly_comment_new-->nextTime=99.9999999999996~", sTime:2.2, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:5, cmtText:"合唱_ニコニコ動画流星群+ version 1.3", sTime:2.4, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:6, cmtText:"囧", sTime:2.55, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:7, cmtText:"这是由 FinePlus 自动发送的用于探测您的IP的1*1像素的透明GIF图片", sTime:2.22, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:8, cmtText:"億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万億千万", sTime:2.9, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:9, cmtText:"*", sTime:2.7, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:10, cmtText:"这个条款旨在成为制造商和客户之间的纽带,其中制造商作为受益人.在美国造船工业中这个条款通常是全险条款,(制造商风险保险)其中作为例外的是战争,地震,斗争或没有在此列出的或通常认可的(例外风险).这个条款通常由以下几部分总和而成:不少于当客户向制造商当时根据游艇价格协议所应支付的数目加上客户向制造商提供的和游艇有关的项目所付出的款项,或者是加上客户向制造商支付的由制造商代销的项目的款项. ", sTime:2.8, flyType:0x3, flySpeed:3, fontColor:0xff0000, fontSize:24});
	fly_var_queue.push({cmtID:11, cmtText:"初音miku - 私の時間. ", sTime:2.8, flyType:FLY_TYPE_BOTTOM, flySpeed:3, fontColor:0x00ff00, fontSize:FLY_FONTSIZE_SMALL});
	fly_var_queue.push({cmtID:12, cmtText:"这是一曲非常经典的歌，慢慢欣赏吧. ", sTime:2.8, flyType:FLY_TYPE_TOP, flySpeed:3, fontColor:0x00ffff, fontSize:FLY_FONTSIZE_SMALL});
	
	fly_var_queueLength = 12;
	fly_comment_new();
	//trace("fly_get_xml" + getTimer());
}


//字幕队列控制，出队列
function fly_comment_new(){
	var comment = fly_var_queue[fly_var_indexNext];
	var channelY = _fly_channel_request(comment);		//请求通道
	//创建文本实例
	var txt:TextField = _level0.createTextField(null, comment.cmtID, FLY_STARTING_X, channelY, 1, 1);
	txt.autoSize = true;
	txt.text = comment.cmtText;
	//txt.antiAliasType = "ADVANCED";
	//txt.sharpness = 400;			
	txt.autoSize = true;
	//设置样式
	txt.setTextFormat(_fly_comment_get_style(comment.fontColor, comment.fontSize));
	//设置非飘移字体的位置
	if(comment.flyType != FLY_TYPE_FLY){
		txt._visible = false;
		txt._x = (ytVideo._width - txt.textWidth) / 2;
	}
		
	//显示
	//trace("show " + getTimer());
	fly_show(txt, FLY_SPEED_NORMAL, comment.sTime, comment.flyType);
	
	//设置下一次显示字体的事件
	fly_var_indexNext++;
	//trace("fly_comment_new " + fly_var_indexNext + "~~" + fly_var_queueLength);
	if(fly_var_indexNext < fly_var_queueLength){
		var nextTime = (fly_var_queue[fly_var_indexNext].sTime - comment.sTime) * 1000;
		if(nextTime <= 0) nextTime = 1;		//如果已经超过了下一个字幕显示的时间延迟1ms后立刻显示下一字幕
		setTimeout(fly_comment_new, nextTime);
		//trace("fly_comment_new-->nextTime=" + nextTime);
	}
}
	
//获取字体格式对象，返回 TextFormat
function _fly_comment_get_style(fColor, fSize){
	var s:TextFormat = new TextFormat;
	s.bold = true;
	s.size = fSize;
	s.color = fColor;
	return s;
}
	

//评论显示开始
function fly_show(txt:TextField, speed:Number, startTime:Number, flyType:Number){
	//trace("fly_show flyTYpe=" + flyType + " " + getTimer());
	if(flyType == FLY_TYPE_FLY){		//飘移的字幕
		//trace("fly_show=" + speed + "=" + startTime + " = " + getTimer());
		setTimeout(_fly_move, (startTime - ns.time) * 1000, txt, speed, startTime);
	}
	else{		//定点显示的字幕
		txt._visible = true;
		trace(speed);
		setTimeout(_fly_delete, speed * 1000, txt);
	}
}

//内部 刷新评论位置
function _fly_move(txt:TextField, speed:Number, startTime:Number){
	//计算当前字幕的x坐标（可能是负值）
	var timePass:Number = _video_get_time() - startTime;
	//trace("_fly_move timePass=" + timePass + " " + getTimer());
	if(timePass > speed){
		_fly_delete(txt);
		return false;	//若已经超出时间则退出
	}
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
	//trace(txtX);
	setTimeout(_fly_move, FLY_FLASH_INTERVAL, txt, speed, startTime);
}

//内部 删除评论
var debug:String;
function _fly_delete(txt:TextField){
	txt.removeTextField();
	trace(debug);
}

//内部 核心 通道请求
function _fly_channel_request(cmt){
	switch(cmt.flyType){
		case FLY_TYPE_FLY:
			return (cmt.cmtID - 1) * cmt.fontSize;
			break;
		case FLY_TYPE_BOTTOM:
			return (ytVideo._height - cmt.fontSize - 2);
			break;
	}
		
}