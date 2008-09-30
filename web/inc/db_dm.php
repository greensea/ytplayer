<?php
require('db.php');

class 数据库达梦类 extends 数据库类{
	private $连接对象;

	public function 连接(){
		if(!$连接对象) $连接对象 = new com('ADODB.Connection');
		echo("Provider=DMOLEDB; User ID='$this->用户名'; Password=$this->密码; Catalog=$this->模式");
		$连接对象->open("Provider=DMOLEDB; User ID=$this->用户名; Password=$this->密码; Catalog=$this->模式");
		$是否连接 = true;
	}
	
	public function 查询($语句){
		if(!$是否连接) this->连接();
		$结果 = $连接对象->execute($语句, $this->影响行数);

		var $返回 = array();
		while($结果->bof){
			$键名 = $值 = array();
			for($i = 0; $i < $结果->fields->count; $i++){
				array_push($键名, $结果->fields[$i]->name);
				array_push($值, $结果->fields[$i]->value);
			}
			array_push($返回, array_combine($键名, $值));
		}

		return $返回;
	}

	public function 断开(){
		$连接对象->close();
		$是否连接 = false;
	}

}
?>
