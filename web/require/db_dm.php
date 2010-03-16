<?php
require('db.php');

class 数据库达梦类 extends 数据库类{
	private $连接对象;

	public function 连接(){
		if($this->是否连接) return true;

		if(!$this->连接对象) $this->连接对象 = new com('ADODB.Connection');
		if($this->数据源 == ''){
			$语句 = "Provider=DMOLEDB; User ID=$this->用户名; Password=$this->密码; Catalog=$this->模式; Data Source=127.0.0.1";
		}
		else{
			$语句 = "DSN=$this->数据源";
		}
		$this->连接对象->open($语句);
		$this->是否连接 = true;
	}
	
	public function 查询($语句){
		if(!$this->是否连接) $this->连接();
		echo $语句 . '<hr />';
		$结果 = $this->连接对象->execute($语句, $this->影响行数);
		
		//如果不是SELECT之类的语句就不用返回结果集了
		if($结果->state == 0) return $this->影响行数;

		$返回 = array();
		while(!$结果->eof){
			$键名 = $值 = array();
			for($i = 0; $i < $结果->fields->count; $i++){
				array_push($键名, $结果->fields[$i]->name);
				array_push($值, $结果->fields[$i]->value);
			}
			array_push($返回, array_combine($键名, $值));
			$结果->MoveNext();
		}

		return count($返回) == 0 ? null : $返回;
	}

	public function 断开(){
		$this->连接对象->close();
		$this->是否连接 = false;
	}

	public function 查询语句转义($语句){
		return str_replace("'", "''", $语句);
	}

}
?>
