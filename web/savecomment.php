<?php
require_once("类文件/头.php");

//获取传回来的数据

$内容 = $_GET['content'];
$字体 = intval($_GET['fontsize']);
$颜色 = $_GET['color'];
$模式 = $_GET['mode'];
$片时 = $_GET['playtime'];
$动画编号 = $_GET['id'];

$动画编号 = intval($动画编号);

if($内容 == '') 错误结束('内容为空');
if($片时 == '') 错误结束('片时为空');

if( $字体 != FLY_FONTSIZE_BIG &&
	$字体 != FLY_FONTSIZE_NORMAL &&
	$字体 != FLY_FONTSIZE_SMALL		){
		$字体 = FLY_FONTSIZE_DEFAULT;
}
$模式 = intval($模式);
if( $模式 != FLY_MODE_BOTTOM &&
	$模式 != FLY_MODE_TOP &&
	$模式 != FLY_MODE_SUBTITLE	){
		$模式 = FLY_MODE_DEFAULT;
}
if($颜色 == '') $颜色 = 0xffffff;

//判断动画是否存在或允许评论
$语句 = "SELECT 编号 FROM 动画 WHERE 编号=$动画编号";
$结果 = $数据库->查询($语句);
if(!$结果) 错误结束('无此动画');

$邀踢动画->保存弹幕($动画编号, $内容, $邀踢动画->用户->编号, $片时, $颜色, $模式, $字体);
die('<message>弹幕成功</message>');

function 错误结束($消息){
	die('<error>' . htmlspecialchars($消息) . '</error>');
}


?>

