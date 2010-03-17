<?php
/**
 * @param $filepath 歌词文件路径
 * @return 解析结果，以二维数组形式保存。各个字段名称分别为：片时，速度，内容
 */
function 歌词文件分析($歌词路径){
	$content = ytp_file_get_contents($歌词路径);
	if ($content == '') return NULL;

	// 规格化歌词的分行，并删除所有空行
	$content = str_replace("\r\n", "\n", $content);
	$content = str_replace("\r", "\n", $content);
	while (stripos($content, "\n\n") !== FALSE) {
		$content = str_replace("\n\n", "\n", $content);
	}

	$line = explode("\n", $content);
	$result = array();

	for ($i = 0; $i < count($line, COUNT_RECURSIVE); $i++) {
		$lineresult = lrc_analysis_line($line[$i]);
		if ($lineresult == NULL) continue;
		
		$namedresult = array('片时' => lrc_timestr2milli($lineresult[1]),
							'内容' => $lineresult[2],
							'速度' => 0
						);

		if ($lineresult !== NULL) array_push($result, $namedresult);
	}

	$result = lrc_calculate_speed($result);
	$result = lrc_delete_emptyline($result);

	return $result;
}


function lrc_analysis_line($line){
	$matches = null;

	preg_match('/\[([0-9:\.]+?)\](.+)?/mi', $line, $matches);
	if (count($matches) < 3) array_push($matches, '');
	
	if (count($matches) < 3) return NULL;

	return $matches;
}


function lrc_calculate_speed($res){
	for ($i = 0; $i < count($res) - 1; $i++) {
		$res[$i]['速度'] = $res[$i + 1]['片时'] - $res[$i]['片时'];
		if ($res[$i]['速度'] <= 0) $res[$i]['速度'] = 3000;
	}

	// 对于最后一个弹幕，如果为空则无视，否则就按照默认的3秒
	if ($res[$i]['内容'] != '') $res[$i]['速度'] = 3000;

	return $res;
}

function lrc_timestr2milli($timestr){
	$times = explode('.', str_replace(':', '.', $timestr));

	$milli = 0;
	$jinvi = array(1, 1000, 60 * 1000, 60 * 60 * 1000);
	for ($i = count($times); $i > 0; $i--) {
		$milli += (intval($times[$i - 1]) * $jinvi[count($times) - $i]);
	}

	return $milli;
}


function lrc_delete_emptyline($res){
	$ret = array();
	for ($i = 0; $i < count($res); $i++) {
		if ($res[$i]['内容'] != '') array_push($ret, $res[$i]);
	}

	return $ret;
}
?>
	