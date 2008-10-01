<?php
require_once('类文件/头.php');

$可扩展标记语言。评论元素 = '';
$可扩展标记语言 = '';

//载入模板
$可扩展标记语言模板。评论元素 = file_get_contents('模板/闪弹幕数据。评论元素.xml');
$可扩展标记语言模板 = file_get_contents('模板/闪弹幕数据.xml');

//获取动画数据
$是否重定位 = ($_GET['relocate'] == 1);
$动画编号 = intval($_GET['id']);

//读弹幕和动画数据
$语句 = "SELECT 播放数,标题,说明,缩略图路径,地址,源页面 FROM 动画 WHERE 编号=$动画编号";
$动画数组 = $数据库->查询($语句);
$语句 = "SELECT 内容,播放时间,评论时间,颜色,字号,速度,模式,编号 FROM 弹幕 WHERE 动画编号=$动画编号";
$弹幕数组 = $数据库->查询($语句);

$影片地址 = $动画数组[0]['地址'];
$播放次数 = $动画数组[0]['播放数'];
$标题 = $动画数组[0]['标题'];
$说明 = $动画数组[0]['说明'];

//重定位动画
if($是否重定位){
	重定位动画();
	exit();
}

//构建弹幕数组的XML
for($i = 0; $i < count($弹幕数组); $i++){
	//$弹幕数组[$i]['评论时间'] = strtotime($弹幕数组[$i]['评论时间']);
	$评论时间 = strtotime($弹幕数组[$i]['评论时间']);
	$速度 = 'normal';
	$字号 = $弹幕数组[$i]['字号'];
	$模式 = $弹幕数组[$i]['模式'];
	$是否字幕 = false;
	switch($模式){
		case FLY_MODE_FLY:
			$模式 = 'fly';
			break;
		case FLY_MODE_TOP:
			$模式 = 'top';
			break;
		case FLY_MODE_BOTTOM:
			$模式 = 'bottom';
			break;
		case FLY_MODE_SUBTITLE:
			$是否字幕 = true;
			$模式 = 'fly';
			break;
		default:
			$模式 = 'fly';
			break;
	}

	$可扩展标记语言。评论元素 .= sprintf($可扩展标记语言模板。评论元素,
															$弹幕数组[$i]['编号'],
															$字号,
															$速度,
															$弹幕数组[$i]['颜色'],
															$模式,
															$是否字幕,
															$弹幕数组[$i]['播放时间'] / 1000,
															$评论时间,
															htmlspecialchars($弹幕数组[$i]['内容'])
												);
															

	//	<comment id="%d" fontSize="%s" flySpeed="%s" fontColor="%6x" flyType="%s" isSubtitle="%d" playTime="%f" commentTime="%d">%s</comment>
}

$可扩展标记语言 = sprintf($可扩展标记语言模板, 
										htmlspecialchars($影片地址),
										$播放次数,
										htmlspecialchars($标题),
										htmlspecialchars($说明),
										$可扩展标记语言。评论元素
									);

echo htmlspecialchars($可扩展标记语言);





function 重定位动画(){
	global $动画数组;
	global $邀踢动画;
	global $数据库;
	global $动画编号;

	$新地址 = $邀踢动画->_获取影片地址($动画数组[0]['源页面']);

	if($新地址){
		$语句 = "UPDATE 动画 SET 地址='$新地址' WHERE 编号=$动画编号";
		$数据库->查询($语句);
	}
	else{
		$新地址 = '';
	}

	$重定位动画模板 = file_get_contents('模板/重定位动画.xml');
	$重定位动画 = sprintf($重定位动画模板, htmlspecialchars($新地址));
	
	echo htmlspecialchars($重定位动画);
}



?>