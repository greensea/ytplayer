<?php
require('db.php');

class 数据库灭意思类 extends 数据库类{
	private $连接对象;
	
	public function 连接(){
		if($this->是否连接) return true;

		$this->连接对象 = mysqli_connect('localhost', $this->用户名, $this->密码) or die(mysqli_error($this->连接对象));
		mysqli_select_db($this->连接对象, $this->模式);
		mysqli_query($this->连接对象, 'SET NAMES utf8');
		
		$this->是否连接 = true;
	}
	
	public function 查询($语句){
		if(!$this->是否连接) $this->连接();

		$结果 = mysqli_query($this->连接对象, $语句) or die(mysqli_error($this->连接对象) . "<strong>$语句</strong>");
		$this->影响行数 = @mysqli_affected_rows($this->连接对象);
		
		//如果不是SELECT之类的语句就不用返回结果集了
		if(@mysqli_num_rows($结果) == null) return $this->影响行数;

		$返回 = array();

		while($单行结果 = mysqli_fetch_array($结果)){
			array_push($返回, $单行结果);
		}

		return count($返回) == 0 ? null : $返回;
	}

	public function 断开(){
		mysqli_close($this->连接对象);
		$this->是否连接 = false;
	}

	public function 查询语句转义($语句){
		return str_replace("'", "''", $语句);
	}

}
?>
