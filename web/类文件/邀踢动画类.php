<?php

class 邀踢动画类{
	public $用户;

	function __construct(){
		require('邀踢动画。用户类.php');
		$this->用户 = new 邀踢动画。用户类;
	}

	function 保存弹幕($动画编号, $内容, $用户编号, $片时, $颜色, $模式, $大小){
		global $数据库;

		$动画编号 = intval($动画编号);
		$内容 = $数据库->查询语句转义($内容);
		$用户编号 = intval($用户编号);
		$片时 = intval($片时);
		$颜色 = intval($颜色);
		$模式 = intval($模式);
		$大小 = intval($大小);

		$语句 = "INSERT INTO 弹幕(动画编号,用户编号,内容,播放时间,字号,颜色,模式)VALUES($动画编号,$用户编号,'$内容',$片时,$大小,$颜色,$模式)";
		$数据库->查询($语句);
	}

	function _获取影片地址($页面地址){
		$源码 = file_get_contents("http://www.flvxz.com/getFlv.php?url=$页面地址");
		$结果 = array();

		if( preg_match('/"(http.+?)"/mi', $源码, $结果) == 0 ) return null;

		return $结果[1];
	}

	public function 新建动画数据($标题, $说明, $源页面, $缩略图){
		global $数据库;
		if($标题 == ''){
			$标题 = '...ypt...';
		}
		else{
			$标题 = $数据库->查询语句转义($标题);
		}
		
		$地址 = $this->_获取影片地址($源页面);
		if(!$地址) return false;

		$说明 = $数据库->查询语句转义($说明);
		$地址 = $数据库->查询语句转义($地址);
		$缩略图 = $数据库->查询语句转义($缩略图);

		$语句 = "INSERT INTO 动画(源页面,地址,标题,说明,缩略图路径,用户编号) VALUES ( '$源页面', '$地址', '$标题', '$说明', '$缩略图', " . $this->用户->编号 . ")";
		echo $语句;
		$数据库->查询($语句);
		return true;
	}
}

?>