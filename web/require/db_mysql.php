<?php
require('db.php');

class 数据库灭意思类 extends 数据库类{
	private $连接对象;

	public function 连接(){
		if($this->是否连接) return true;

		mysql_connect('localhost', $this->用户名, $this->密码);
		mysql_select_db($this->模式);
		mysql_query('SET NAMES utf8');
		
		$this->是否连接 = true;
	}
	
	public function 查询($语句){
		if(!$this->是否连接) $this->连接();

		$结果 = mysql_query($语句) or die(mysql_error() . "<strong>$语句</strong>");
		$this->影响行数 = @mysql_affected_rows($结果);
		
		//如果不是SELECT之类的语句就不用返回结果集了
		if(@mysql_num_rows($结果) == null) return $this->影响行数;

		$返回 = array();

		while($单行结果 = mysql_fetch_array($结果)){
			array_push($返回, $单行结果);
		}

		return count($返回) == 0 ? null : $返回;
	}

	public function 断开(){
		mysql_close();
		$this->是否连接 = false;
	}

	public function 查询语句转义($语句){
		return str_replace("'", "''", $语句);
	}

}
?>
