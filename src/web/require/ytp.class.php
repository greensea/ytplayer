<?php

class 邀踢动画类{
	public $用户;

	function __construct(){
		require('ytp.user.php');
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
		$速度 = intval($速度);
		$当前时间 = time();
		if(!$速度) $速度 = FLY_SPEED_DEFAULT;

		//$语句 = "INSERT INTO 弹幕(动画编号,用户编号,内容,播放时间,字号,颜色,模式,速度)VALUES($动画编号,$用户编号,'$内容',$片时,$大小,$颜色,$模式,$速度)";
		$语句 = "INSERT INTO popsub(videoid,userid,content,playtime,fontsize,color,flymode,speed,popsubtime)VALUES($动画编号,$用户编号,'$内容',$片时,$大小,$颜色,$模式,$速度,$当前时间)";
		$数据库->查询($语句);
	}

	function _获取影片信息_flvcd($页面地址) {
		$str = file_get_contents('http://www.flvcd.com/parse.php?format=&kw=' . urlencode($页面地址));
		$str = iconv('gb2312', 'utf-8', $str);

		$m = array();
//die("<pre>" . htmlspecialchars($str).'</pre>');
		preg_match('/当前解析视频：(.+)（请用右键"目标另存为"/u', strip_tags($str), $m);
		$title = $m[1];

		preg_match_all('/<a href="(.+)" target="_blank" onclick/u', $str, $m);
		$url = join($m[1], "\n");
		
		return array('标题' => $title, '地址' => $url);
	}

	function _获取影片信息($页面地址){
		return $this->_获取影片信息_flvcd($页面地址);	/// --greensea 2013-04-09 flvcd 的信息获取方式又改了，于是修改之
		
		//$源码 = ytp_file_get_contents("http://www.flvxz.com/getFlv.php?url=$页面地址");
		//必须发送Cookie才能获取地址了
		/**
		 * 不用了，改用 flvcd.com 的服务
		 */
		/*
		$xmlhttp = new com('MSXML2.ServerXMLHTTP');
		$xmlhttp->open('GET', 'http://www.flvxz.net', false);
		$xmlhttp->setRequestHeader('Referer', 'http://www.flvxz.com/');
		$xmlhttp->send();
		$xmlhttp->open('GET', "http://www.flvxz.net/getFlv.php?url=$页面地址", false);
		$xmlhttp->setRequestHeader('Referer', 'http://www.flvxz.com/');
		$xmlhttp->send();
		$源码 = $xmlhttp->responseText;
		*/
		
		/**
		 * 从 flvcd.com 获取地址
		 */
		$curl = curl_init();
		curl_setopt_array($curl , array(CURLOPT_URL => 'http://www.flvcd.com/parse.php?kw=' . urlencode($页面地址),
										CURLOPT_USERAGENT => $_SERVER['HTTP_USER_AGENT'],
										CURLOPT_RETURNTRANSFER => 1
										));
		$源码 = curl_exec($curl);
		
		$正规式 = '/<N>(.+?)[\r\n][.\r\n\s\S]+?<U>(.+?)[\r\n]+/mi';
		$结果 = array();
		
		if( preg_match($正规式, $源码, $结果) == 0 ) return null;

		//$结果[1] = 哔——编码转换($结果[1]);
		return array(
					'标题' => $结果[1],
					'地址' => $结果[2]
					);
	}
	
	function _获取4shared影片信息($页面地址) {		
		$curl = curl_init();
		curl_setopt_array($curl, array( CURLOPT_URL => $页面地址,
										CURLOPT_USERAGENT => $_SERVER['HTTP_USER_AGENT'],
										CURLOPT_RETURNTRANSFER => 1
								));
		$源码 = curl_exec($curl);
		
		$地址正规式 = '/\.swf\?file=(.+?)"/mi';
		$标题正规式 = '/<meta name="title" content="(.+?)" \/>/mi';
		
		if (preg_match($地址正规式, $源码, $地址结果) == 0) return null;
		if (preg_match($标题正规式, $源码, $标题结果) == 0) return null;

		return array(
					'标题' => $标题结果[1],
					'地址' => $地址结果[1]
					);
	}
	
	function _获取sina影片信息($页面地址) {
		preg_match('/b\/(\d+)/mi', $页面地址, $vid);

		$curl = curl_init();
		curl_setopt_array($curl, array( CURLOPT_URL => 'http://v.iask.com/v_play.php?vid=' . $vid[1],
										CURLOPT_USERAGENT => $_SERVER['HTTP_USER_AGENT'],
										CURLOPT_RETURNTRANSFER => 1
								));
		$源码 = curl_exec($curl);

		$地址正规式 = '/<url><\!\[CDATA\[(.+)\]\]><\/url>/mi';
		$标题正规式 = '/<vname><\!\[CDATA\[(.+)\]\]><\/vname>/mi';
		
		if (preg_match($地址正规式, $源码, $地址结果) == 0) return null;
		if (preg_match($标题正规式, $源码, $标题结果) == 0) return null;

		return array(
					'标题' => $标题结果[1],
					'地址' => $地址结果[1]
					);
	}
	
	public function 新建动画数据($标题, $说明, $源页面, $缩略图){
		global $数据库;
		
		if (stripos($源页面, '4shared', 0) !== FALSE) {
			$影片信息 = $this->_获取4shared影片信息($源页面);
		}
		else if (stripos($源页面, 'sina.com.cn', 0) !== FALSE) {
			$影片信息 = $this->_获取sina影片信息($源页面);
		}
		else {
			$影片信息 = $this->_获取影片信息($源页面);
		}
		if(!$影片信息) return false;

		$地址 = $影片信息['地址'];
		if($标题 == '') $标题 = $影片信息['标题'];

		$说明 = $数据库->查询语句转义($说明);
		$地址 = $数据库->查询语句转义($地址);
		$标题 = $数据库->查询语句转义($标题);
		$缩略图 = $数据库->查询语句转义($缩略图);
		$当前时间 = time();

		if(strpos($源页面, '.youku.') || strpos($源页面, '.tudou.')) $标题 = iconv('gb2312', 'utf-8', $标题);	//土豆和优酷的标题是国标2312的

		//$语句 = "INSERT INTO 动画(源页面,地址,标题,说明,缩略图路径,用户编号) VALUES ( '$源页面', '$地址', '$标题', '$说明', '$缩略图', " . $this->用户->编号 . ")";
		$语句 = "INSERT INTO video(sourcepage,sourcefile,title,description,thumbnail,addtime,userid) VALUES ( '$源页面', '$地址', '$标题', '$说明', '$缩略图', $当前时间, " . $this->用户->编号 . ")";

		$数据库->查询($语句);

		//如果是新增加的动画，就返回新增的编号
		$语句 = 'SELECT MAX(id) AS id FROM video';
		$结果 = $数据库->查询($语句);
		$结果['编号'] = $结果['id'];
		return $结果;
	}

	public function 错误($信息){
		ob_clean();
		$输出 = ytp_file_get_contents('模板/错误.xml');
		$输出 = str_replace('{$错误信息}', htmlspecialchars($信息), $输出);
		header('Content-Type: text/xml; charset=utf-8');
		echo $输出;
		exit();
	}
}


function 哔——编码转换($str){
	//核心代码来源：http://blog.csdn.net/leinchu/archive/2008/02/27/2124810.aspx
	$str = preg_replace("|&#([0-9]{1,5});|", "\"._u2utf82gb(\\1).\"", $str);
	$str = "\$str=\"$str\";";
	eval($str);
	return  $str;
}

function ytp_file_get_contents($file) {
	return file_get_contents($file);
	return file_get_contents(iconv('utf-8', 'gb2312', $file));
}

function ytp_move_uploaded_file($tmp, $to) {
	return move_uploaded_file($tmp, iconv('utf-8', 'gb2312', $to));
}

function _u2utf82gb($c){
    $str="";
    if ($c < 0x80) {
         $str.=$c;
    } else if ($c < 0x800) {
         $str.=chr(0xC0 | $c>>6);
         $str.=chr(0x80 | $c & 0x3F);
    } else if ($c < 0x10000) {
         $str.=chr(0xE0 | $c>>12);
         $str.=chr(0x80 | $c>>6 & 0x3F);
         $str.=chr(0x80 | $c & 0x3F);
    } else if ($c < 0x200000) {
         $str.=chr(0xF0 | $c>>18);
         $str.=chr(0x80 | $c>>12 & 0x3F);
         $str.=chr(0x80 | $c>>6 & 0x3F);
         $str.=chr(0x80 | $c & 0x3F);
    }
    return iconv('UTF-8', 'GB2312', $str);
}

?>
