/** ytPlayer  飘移评论控制脚本 **/
var FLY_SPEED_FAST:Number = 3;		//快字幕速度：秒
var FLY_SPEED_NORMAL:Number = 5;	//中等速度字幕：秒
var FLY_SPEED_SLOW:Number = 7;		//慢字幕速度：秒
var FLY_FONTSIZE_BIG:Number = 28;		//字体大小，大：像素
var FLY_FONTSIZE_NORMAL:Number = 24;	//字体大小，中：像素
var FLY_FONTSIZE_SMALL:Number = 16;		//字体大小，小：像素
var FLY_TYPE_TOP:Number = 0x2;
var FLY_TYPE_BOTTOM:Number = 0x0;
var FLY_TYPE_FLY:Number = 0x3;

var FLY_STARTING_X:Number = ytVideo._width;		//字幕初始位置：相对与影片
var FLY_FLASH_INTERVAL:Number = 30;		//字幕刷新间隔：毫秒

/* a1 表示评论位置， a0 表示是否飘移 */
var fly_type:Object ={top:0x2, bottom:0x0, fly:0x3};
//var fly_var_queue:Object = {cmtID:Number, cmtText:String, sTime:Number, flyType:Number, flySpeed:Number, fontColor:Number, fontSize:Number};

var fly_var_indexNext = 0;
var fly_var_queueLength = 0;
var fly_var_queue = new Array();


fly_get_xml();

//获取字幕源XML
function fly_get_xml(url){
	var nsCmt:XML = new XML;
	tip_add("读取评论…");
	nsCmt.load("http://bbs.bbxy.net/sitemap_baidu.xml");
	trace(nsCmt);
}


//字幕队列控制，出队列
function fly_comment_new(){
	var comment = fly_var_queue[fly_var_indexNext];
	var channelY = _fly_channel_request(comment.cmtID);		//请求通道
	//创建文本实例
	var txt:TextField = _level0.createTextField(null, comment.cmtID, FLY_STARTING_X, channel, width, height);
	txt.autoSize = true;
	txt.text = comment.cmtText;
	txt.antiAliasType = "ADVANCED";
	txt.sharpness = 400;			
	txt.antiAliasType = "ADVANCED";
	txt.autoSize = true;
	//设置样式
	txt.setTextFormat(_fly_comment_get_style(comment.fontColor, comment.fontSize));
	//设置非飘移字体的位置
	if(comment.flyType != FLY_TYPE_FLY){
		txt.x = (ytVideo._width - txt.textWidth) / 2;
	}
		
	//显示
	fly_show(txt, FLY_SPEED_NORMAL, comment.sTime, comment.flyType);
	
	//设置下一次显示字体的事件
	fly_var_indexNext++;
	if(fly_var_indexNext < fly_var_queueLength){
		var nextTime = (fly_var_queue[fly_var_indexNext].sTime - comment.sTime) * 1000;
		if(nextTime <= 0) nextTime = 1;		//如果已经超过了下一个字幕显示的时间延迟1ms后立刻显示下一字幕
		setTimeout(fly_comment_new, nextTime);
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
	if(flyType != 11){		//飘移的字幕
		_fly_move(txt, speed, startTime);
	}
	else{		//定点显示的字幕
		setTimeout(fly_delete, speed * 1000, txt);
	}
}

//内部 刷新评论位置
function _fly_move(txt:TextField, speed:Number, startTime:Number){
	//计算当前字幕的x坐标（可能是负值）
	var timePsss = ns.time - startTime;
	if(timePass > speed){
		_fly_delete(txt);
		return false;	//若已经超出时间则退出
	}
	var txtX = (FLY_STARTING_X + txt.textWidth) * timePass / speed;		//字幕离开起点的距离
	txtX = FLY_STARTING_X - txtX;
	txt._x = txtX;
	setTimeout(_fly_move, FLY_FLASH_INTERVAL, txt, speed, startTime);
}

//内部 删除评论
function _fly_delete(txt:TextField){
	txt = null;
}
