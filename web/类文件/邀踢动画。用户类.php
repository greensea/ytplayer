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
		$this->互联网地址 = $this->_获取互联网地址();
		$this->标识序列 = $_COOKIE['idenseq'];
		$this->名字 = $_COOKIE['name'];
		if($this->标识序列 == ''){
			$this->标识序列 = $this->_申请标识序列();
		}
		else{
			//检查是否是登录用户

		}
	}

	private function _获取互联网地址(){
		$地址 = $this->_获取互联网地址字串();
		return $this->_互联网地址转换($地址);
	}

	private function _获取互联网地址字串(){
		$地址 = $_SERVER['HTTP_X_FORWARDED_FOR'];
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



}
?>