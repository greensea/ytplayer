<?php
require_once('require/header.php');

$动画数组 = $弹幕数组 = null;

//载入模板

//获取动画数据
$是否重定位 = isset($_GET['relocate']) ? ($_GET['relocate'] == 1) : false;
$动画编号 = intval($_GET['id']);
$时间线 = isset($_GET['timeline']) ? $_GET['timeline'] : 0;

//读弹幕和动画数据
if(!$动画编号){	//根据源页面
	$源页面转义 = $数据库->查询语句转义($_GET['source']);
	if($源页面转义 == '') over('id和source全未定义');

	//$语句 = "SELECT 编号,播放数,标题,说明,缩略图路径,地址,源页面 FROM 动画 WHERE 源页面='$源页面转义'";
	$语句 = "SELECT id,hits,title,description,thumbnail,sourcefile,sourcepage FROM video WHERE sourcepage='$源页面转义'";
	$动画数组 = $数据库->查询($语句);
	if($动画数组){
		$动画编号 = $动画数组[0]['编号'];
	}
}
else{	 
	//根据编号
	//if(!$邀踢动画->新建动画数据('', '', $_GET['source'], '')) over('指定的视频不存在');
	$语句 = "SELECT id FROM video WHERE id=$动画编号";
	$结果 = $数据库->查询($语句);
	if(!$结果) over('无此动画');
}

/*
$语句一 = "SELECT 播放数,标题,说明,缩略图路径,地址,源页面 FROM 动画 WHERE 编号=$动画编号";
$语句二 = "SELECT 内容,播放时间,评论时间,颜色,字号,速度,模式,编号,通道,位置 FROM 弹幕 WHERE 动画编号=$动画编号
			UNION
			SELECT 内容,播放时间,评论时间,颜色,字号,速度,模式,编号,通道,位置 FROM 分组弹幕 WHERE 组编号 IN (SELECT 编号 FROM 弹幕分组 WHERE 动画编号=$动画编号)
			ORDER BY 播放时间 ASC";
*/
$语句一 = "SELECT hits,title,description,thumbnail,sourcefile,sourcepage FROM video WHERE id=$动画编号";
$语句二 = "SELECT content,playtime,popsubtime,color,fontsize,speed,flymode,id,channel,position FROM popsub WHERE videoid=$动画编号 AND popsubtime>$时间线
			UNION
			SELECT content,playtime,popsubtime,color,fontsize,speed,flymode,id,channel,position FROM group_popsub WHERE groupid IN (SELECT id FROM popsub_group WHERE videoid=$动画编号 AND popsubtime>$时间线)
			ORDER BY playtime ASC";
$语句三 = "SELECT COUNT(id) AS cnt FROM (SELECT content,playtime,popsubtime,color,fontsize,speed,flymode,id,channel,position FROM popsub WHERE videoid=$动画编号
                        UNION
                        SELECT content,playtime,popsubtime,color,fontsize,speed,flymode,id,channel,position FROM group_popsub WHERE groupid IN (SELECT id FROM popsub_group WHERE videoid=$动画编号)) AS t";

if(!$动画数组) $动画数组 = $数据库->查询($语句一);

$弹幕数组 = $数据库->查询($语句二);
$弹幕总数结果 = $数据库->查询($语句三);
$弹幕总数 = $弹幕总数结果[0]['cnt'];

$影片地址 = $动画数组[0]['sourcefile'];
$播放次数 = $动画数组[0]['hits'];
$标题 = $动画数组[0]['title'];
$说明 = $动画数组[0]['description'];

//重定位动画
if($是否重定位){
	重定位动画();
	exit();
}

function 可扩展标记语言输出($弹幕数组) {
	global $动画编号;
	global $影片地址;
	global $播放次数;
	global $标题;
	global $说明;
	
	$可扩展标记语言。评论元素 = '';
	$可扩展标记语言 = '';

	$可扩展标记语言模板。评论元素 = ytp_file_get_contents('模板/闪弹幕数据。评论元素.xml');
	$可扩展标记语言模板。评论元素。通道属性 = ytp_file_get_contents('模板/闪弹幕数据。评论元素。通道属性.xml');
	$可扩展标记语言模板。评论元素。位置属性 = ytp_file_get_contents('模板/闪弹幕数据。评论元素。位置属性.xml');
	$可扩展标记语言模板 = ytp_file_get_contents('模板/闪弹幕数据.xml');

	//构建弹幕数组的XML
	for($i = 0; $i < count($弹幕数组); $i++){
		if ($弹幕数组[$i]['id'] == 0) break;
		//$弹幕数组[$i]['评论时间'] = strtotime($弹幕数组[$i]['评论时间']);
		$评论时间 = $弹幕数组[$i]['popsubtime'];
		$速度 = $弹幕数组[$i]['speed'];
		$字号 = $弹幕数组[$i]['fontsize'];
		$模式 = $弹幕数组[$i]['flymode'];
		$通道 = $弹幕数组[$i]['channel'];
		$位置 = $弹幕数组[$i]['position'];
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
				$模式 = 'bottom';
				break;
			default:
				$模式 = 'fly';
				break;
		}

		$可扩展标记语言。评论元素 .= sprintf($可扩展标记语言模板。评论元素,
																$弹幕数组[$i]['id'],
																$字号,
																$速度,
																$弹幕数组[$i]['color'],
																$模式,
																$是否字幕,
																$弹幕数组[$i]['playtime'] / 1000,
																$评论时间,
																($通道 == null) ? '' : sprintf($可扩展标记语言模板。评论元素。通道属性, $通道),
																($位置 == null) ? '' : sprintf($可扩展标记语言模板。评论元素。位置属性, $位置),
																htmlspecialchars($弹幕数组[$i]['content'])
													);
																
	}

	$可扩展标记语言 = sprintf($可扩展标记语言模板, 
											$动画编号,
											htmlspecialchars($影片地址),
											$播放次数,
											htmlspecialchars($标题),
											htmlspecialchars($说明),
											$可扩展标记语言。评论元素
										);
										
	return $可扩展标记语言;
}


function 爪哇脚本对象表示($弹幕数组) {
	global $动画编号;
	global $影片地址;
	global $播放次数;
	global $标题;
	global $说明;
	
	/// 删除弹幕数组中以数字作为键的元素
	for ($i = 0; $i < count($弹幕数组); $i++) {
		$k = 0;
		while (array_key_exists($k, $弹幕数组[$i])) {
			unset($弹幕数组[$i][$k]);
			$k++;
		}
	}
	
	$结果数组 = array();
	
	$结果数组['video']['flvID'] = $动画编号;
	$结果数组['video']['flvURL'] = array();
	foreach (explode('\n', $影片地址) as $键 => $值) {
		array_push($结果数组['video']['flvURL'], $值);
	}
	$结果数组['video']['playTimes'] = $播放次数;
	$结果数组['video']['title'] = $标题;
	$结果数组['video']['description'] = $说明;
	
	
	/// 处理弹幕数组的键
	$键表 = array('playtime' => 'playTime',
			'popsubtime' => 'commentTime',
			'fontsize' => 'fontSize',
			'speed' => 'flySpeed',
			'flymode' => 'flyType',
			'color' => 'fontColor'
		);
	for ($i = 0; $i < count($弹幕数组); $i++) {
		foreach ($键表 as $键 => $值) {
			$弹幕数组[$i][$值] = $弹幕数组[$i][$键];
			unset($弹幕数组[$i][$键]);
		}
		$弹幕数组[$i]['playTime'] = sprintf('%0.3f', $弹幕数组[$i]['playTime'] / 1000.0);
		$弹幕数组[$i]['fontColor'] = sprintf('%06x', $弹幕数组[$i]['fontColor']);
	}
			

	// 继续处理 JSON 格式的数据
	for ($i = 0; $i < count($弹幕数组); $i++) {
		$是否字幕 = false;
		$模式 = $弹幕数组[$i]['flyType'];
		
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
				$模式 = 'bottom';
				break;
			default:
				$模式 = 'fly';
				break;
		}
		
		$弹幕数组[$i]['flyType'] = $模式;
		$弹幕数组[$i]['isSubtitle'] = ($是否字幕) ? '1' : '0';
	}


	$结果数组['comments'] = $弹幕数组;
	
	return json_encode($结果数组);
}

//echo htmlspecialchars($可扩展标记语言);
ob_clean();

if (isset($_GET['json'])) {
	echo 爪哇脚本对象表示($弹幕数组);
}
else {
	header("Content-Type: text/xml; charset=utf-8"); 
	header("Cache-Control: no-cache, must-revalidate");
	echo 可扩展标记语言输出($弹幕数组);
}

/*********************************************/

function 重定位动画(){
	global $动画数组;
	global $邀踢动画;
	global $数据库;
	global $动画编号;

	$影片数据 = '';
	if (stripos($动画数组[0]['sourcepage'], '4shared', 0) === FALSE) {
		$影片数据 = $邀踢动画->_获取影片信息($动画数组[0]['sourcepage']);
	}
	else {
		$影片数据 = $邀踢动画->_获取4shared影片信息($动画数组[0]['sourcepage']);
	}

	$新地址 = $影片数据['地址'];

	if($新地址){
		$语句 = "UPDATE video SET sourcefile='$新地址' WHERE id=$动画编号";
		$数据库->查询($语句);
	}
	else{
		$新地址 = '';
	}

	$重定位动画模板 = ytp_file_get_contents('模板/重定位动画.xml');
	$重定位动画 = sprintf($重定位动画模板, htmlspecialchars($新地址));
	
	ob_clean();
	header("Content-Type: text/xml; charset=utf-8"); 
	echo $重定位动画;
}


function over($信息){
	ob_clean();
	header("Content-Type: text/xml; charset=utf-8"); 
	$输出 =  '<?xml version="1.0" encoding="utf-8"?>';
	$输出 .= '<ytp><error>' . htmlspecialchars($信息) . '</error></ytp>';
	//$输出 = mb_convert_encoding($输出, 'utf-8', 'gb2312');
	echo $输出;
	exit();
}

?>
