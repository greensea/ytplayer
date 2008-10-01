<?php
error_reporting(E_ALL );//& ~E_NOTICE);
date_default_timezone_set('Asia/Shanghai');

require_once('db_dm.php');
$数据库 = new 数据库达梦类;
$数据库->数据源 = '邀踢动画';

require_once('类文件/邀踢动画。常量.php');
require_once('类文件/邀踢动画类.php');
$邀踢动画 = new 邀踢动画类;

?>