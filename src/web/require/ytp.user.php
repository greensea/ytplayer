<?php
class 邀踢动画。用户类{
	public $编号;
	public $互联网地址;
	public $标识序列;
	public $名字;

	public function __construct(){
		$this->_初始化用户信息();
	}


	private function _初始化用户信息(){
		global $数据库;

		$是否登录 = false;

		$this->互联网地址 = $this->_获取互联网地址();
		$this->标识序列 = $_COOKIE['idenseq'];
		if($this->标识序列 != ''){
			//检查是否是登录用户
			$编号 = hexdec(substr($this->标识序列, 0, 8));
			$编号 ^= hexdec(substr($this->标识序列, 8, 8));
			
			$标识 = $数据库->查询语句转义($this->标识序列);

			$语句 = "SELECT id,name FROM user WHERE id=$编号 AND sid='$标识'";
			$结果 = $数据库->查询($语句);
			if($结果){
				$this->标识序列 = $标识;
				$this->编号 = $结果[0]['id'];
				$this->名字 = $结果[0]['name'];
				$是否登录 = true;
				$this->_更新客户端小甜饼();
			}
		}
		
		if(!$是否登录){
			$this->标识序列 = $this->_申请标识序列();
			$this->_更新客户端小甜饼();
		}
	}

	private function _获取互联网地址(){
		$地址 = $this->_获取互联网地址字串();
		return $this->_互联网地址转换($地址);
	}

	private function _获取互联网地址字串(){
		$地址 = isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : '';
		return $地址 != '' ? $地址 : $_SERVER['REMOTE_ADDR'];
	}

	private function _互联网地址转换($地址){
		if(is_int($地址)){
			$地址字串 = $地址 >> 24;
			$地址字串 .= '.';
			$地址字串 .= ($地址 & 0x00ff0000) >> 16;
			$地址字串 .= '.';
			$地址字串 .= ($地址 & 0x0000ff00) >> 8 . '.';
			$地址字串 .= '.';
			$地址字串 .= ($地址 & 0x000000ff);
			return $地址字串;
		}
		else{
			$地址数组 = explode('.', $地址);
			return ($地址数组[0] << 24) + ($地址数组[1] << 16) + ($地址数组[2] << 8) + $地址数组[3];
		}
	}

	private function _申请标识序列(){
		/*
		标识序列格式：
		64个二进制位
		高32位为用户编号序列，值为 （用户编号 XOR 低32位）
		低32位为随机校验值，值为CRC32(time())
		最后以十六进制字符串形式返回
		*/
		global $数据库;

		$用户编号 = $数据库->查询('SELECT MIN(id) FROM user');
		$低位 = crc32(time());
		$用户编号 = $高位 = count($用户编号) == 0 ? -1 : $用户编号[0][''] - 1;
		$高位 ^= $低位;

		$序列 = dechex($低位);
		while(strlen($序列) < 8) $序列 = '0' . $序列;
		$序列 = dechex($高位) . $序列;
		while(strlen($序列) < 16) $序列 = '0' . $序列;
		
		$this->_新建用户数据($用户编号, null, $序列, $this->互联网地址);

		return $序列;

		//return count($用户编号) == 0 ? -1 : $用户编号[0][0] - 1;
		
	}

	private function _新建用户数据($编号, $名字, $序列, $地址){
		global $数据库;
		$编号 = intval($编号);
		$地址 = intval($地址);
		$名字 = $数据库->查询语句转义($名字);
		$序列 = $数据库->查询语句转义($序列);
		$语句 = "INSERT INTO user(id, name, sid, ip)VALUES($编号,'$名字','$序列', $地址)";
		$数据库->查询($语句);
	}

	private function _更新客户端小甜饼(){
		$过期时间 = time() + 86400 * 90;		//90天过期
		setCookie('idenseq', $this->标识序列, $过期时间);
	}
}

?>