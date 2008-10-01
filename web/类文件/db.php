<?php

class 数据库类{
	public $主机;
	public $用户名;
	public $密码;
	public $模式;
	public $数据源 = '';

	protected $是否连接 = false;

	public function 查询($语句){}
	public function 连接(){}
	public function 断开(){}
	public function 查询语句转义($语句){}

}



?>