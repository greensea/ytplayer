<?php
//error_reporting(~E_ALL & ~E_NOTICE);
error_reporting(E_ALL | E_NOTICE);
date_default_timezone_set('Asia/Shanghai');

require_once('db_mysql.php');
$数据库 = new 数据库灭意思类;
$数据库->用户名 = 'ytp';
$数据库->密码 = 'McTAmnWvCD62RcFz';
$数据库->模式 = 'ytp';

require_once('require/ytp.constant.php');
require_once('require/ytp.class.php');
$邀踢动画 = new 邀踢动画类;

?>