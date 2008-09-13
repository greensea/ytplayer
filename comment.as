/** ytPlayer  飘移评论控制脚本 **/
var FLY_SPEED_FAST:Number = 2.5;		//快字幕速度：秒
var FLY_SPEED_NORMAL:Number = 4;	//中等速度字幕：秒
var FLY_SPEED_SLOW:Number = 5.5;		//慢字幕速度：秒

var FLY_FONTSIZE_BIG:Number = 26;		//字体大小，大：像素
var FLY_FONTSIZE_NORMAL:Number = 22;	//字体大小，中：像素
var FLY_FONTSIZE_SMALL:Number = 14;		//字体大小，小：像素

var FLY_FONTCOLOR_DEFAULT:Number = 0xffffff;		//默认字体颜色：白

var FLY_TYPE_TOP:Number = 0x2;
var FLY_TYPE_BOTTOM:Number = 0x0;
var FLY_TYPE_FLY:Number = 0x3;

var FLY_LEVEL_RANGE:Number = 1000;
var FLY_LEVEL_FLY:Number = FLY_LEVEL_RANGE;
var FLY_LEVEL_TOP:Number =FLY_LEVEL_FLY + FLY_LEVEL_RANGE;
var FLY_LEVEL_BOTTOM:Number = FLY_LEVEL_TOP + FLY_LEVEL_RANGE;

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
var _fly_var_level_accumulator = 0;

fly_get_xml();



//获取字幕源XML
function fly_get_xml(url){
	var nsCmt = new XML();
	tip_add("读取评论…");
	nsCmt.load("data.xml");
	
	nsCmt.onLoad = function(){
		//trace("length = " + this);
		var cmts = xml_getElementByTagName(this, "comments").childNodes;
		//trace(cmts[1].attributes["playTime"]);
		fly_var_queueLength = 0;
		fly_var_queue = new Array(cmts.length);
		for(var i = 0; i < cmts.length; i++){
			if(cmts[i].nodeName){
				dgrComments.addItem({片时:_sec2disTime(cmts[i].attributes["playTime"]), 内容:cmts[i].lastChild, 评论时间:_timestamp2date(cmts[i].attributes["commentTime"])});
				//压入弹幕数据库
				var newCmt:Object = {
					cmtText:cmts[i].lastChild,
					sTime:cmts[i].attributes["playTime"],	//单位：s，基于影片开始的时间戳
					fontColor:cmts[i].attributes["fontColor"],
					fontSize:cmts[i].attributes["fontSize"],
					flyType:cmts[i].attributes["flyType"],
					flySpeed:FLY_SPEED_NORAML //单位：s
				}
				//一系列的判断
				if(newCmt.fontColor == "") newCmt.fontColor = FLY_FONTCOLOR_DEFAULT;
				if(newCmt.flyType == "") newCmt.flyType = FLY_TYPE_FLY;
				switch(newCmt.fontSize){
					case "small":
						newCmt.fontSize = FLY_FONTSIZE_SMALL;
						break;
					case "big":
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
		fly_comment_new();
	}
}


//字幕队列控制，出队列
function fly_comment_new(){
	var comment = fly_var_queue[fly_var_indexNext];
	var channel = _fly_channel_request(comment);		//请求通道
	//创建文本实例
	//trace(channel[1] + ", " + channel[0] + ", " + comment.cmtText);
	var txt:TextField = _level0.createTextField(null, channel[1], FLY_STARTING_X, channel[0], 1, 1);
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
	fly_show(txt, FLY_SPEED_NORMAL, comment.sTime, comment.flyType);
	
	//设置下一次显示字体的事件
	fly_var_indexNext++;
	//trace("fly_comment_new " + fly_var_indexNext + "~~" + fly_var_queueLength);
	if(fly_var_indexNext < fly_var_queueLength){
		var nextTime = (fly_var_queue[fly_var_indexNext].sTime - comment.sTime) * 1000;
		if(nextTime <= 0) nextTime = 1;		//如果已经超过了下一个字幕显示的时间延迟1ms后立刻显示下一字幕
		setTimeout(fly_comment_new, nextTime);
		//trace("fly_comment_new-->nextTime=" + nextTime + "	" + fly_var_queue[fly_var_indexNext].cmtText);
	}
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
function fly_show(txt:TextField, speed:Number, startTime:Number, flyType:Number){
	//trace("fly_show flyTYpe=" + flyType + " " + getTimer());
	if(flyType == FLY_TYPE_FLY){		//飘移的字幕
		//trace("fly_show=" + speed + "=" + startTime + " = " + getTimer());
		setTimeout(_fly_move, (startTime - _video_get_time()) * 1000, txt, speed, startTime);
	}
	else{		//定点显示的字幕
		txt._visible = true;
		//trace(speed);
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
	//trace(debug);
}

//内部 核心 通道请求
function _fly_channel_request(cmt){
	var d = Array(1, 1);	//(通道，层)
	_fly_var_level_accumulator++;
	var lvl = _fly_var_level_accumulator % FLY_LEVEL_RANGE;
	//trace(lvl);
	switch(cmt.flyType){
		case FLY_TYPE_FLY:
			d[0] = lvl * cmt.fontSize;
			d[1] = FLY_LEVEL_FLY + lvl;
			break;
		case FLY_TYPE_BOTTOM:
			d[0] = (ytVideo._height - cmt.fontSize - 2);
			d[1] = FLY_LEVEL_BOTTOM + lvl;
			break;
		case FLY_TYPE_TOP:
			d[0] = (ytVideo._y + cmt.fontSize + 1);
			d[1] = FLY_LEVEL_TOP + lvl;
			break;
	}
	return d;
}


//囧的XML的getElementByTagName函数 递归查找（注意是Element而不是Elements哦）
function xml_getElementByTagName(xml, nodeName){
	for(var i = 0; i < xml.childNodes.length; i++){
		if(xml.childNodes[i].nodeName == nodeName){
			return xml.childNodes[i]
		}
		else{
			if(xml.childNodes[i].nodeName){
				var node = xml_getElementByTagName(xml.childNodes[i], nodeName);
				if(node.nodeName == nodeName) return node;
			}
		}
	}
}