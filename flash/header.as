/***********YTdonghuaPlayer************/
/*******	header.as		***********/
/**************************************/


//导入包
import mx.controls.List;

//定义全局常量
var FLASH_INTERVAL = 30;	//通用刷新时间，毫秒

//定义全局变量
var nc:NetConnection;
var ns:NetStream;


//包含文件
#include "init.as"
#include "_functions.as"
#include "comment.as"
#include "commentgrid.as"
#include "writer.as"
#include "net.as"