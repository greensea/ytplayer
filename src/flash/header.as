/***********YTdonghuaPlayer************/
/*******	header.as		***********/
/**************************************/


//导入包
import mx.controls.List;
import g_ns_t;

//定义全局常量
var FLASH_INTERVAL:Number = 30;	//通用刷新时间，毫秒
var URL_PREFIX:String = "http://ytp.bbxy.net/";
var VIDEO_REFRESH_COMMENT_INTERVAL = 2000;	// 弹幕“聊天”刷新的时间

var G_VIDEO_DEFAULT_WIDTH = ytVideo._width;
var G_VIDEO_DEFAULT_HEIGHT = ytVideo._height;

var G_LEVEL_DEFAULT_HEIGHT = ytVideo._height;
var G_LEVEL_DEFAULT_WIDTH = ytVideo._width;

//定义全局变量
var nc:NetConnection;
var ns:NetStream;

var video_var_requirerelocate = false;

var g_ns:Array = new Array();
var g_ns_bytesTotal:Number = 0;
var g_ns_loadedNum:Number = 0;	/// 已经载入的视频分段数
var g_ns_curPlaying:Number = 0;	/// 当前正在播放的视频分段




//包含文件
#include "_init.as"
#include "events.as"
#include "_functions.as"
#include "comment.as"
#include "commentgrid.as"
#include "writer.as"
#include "net.as"
