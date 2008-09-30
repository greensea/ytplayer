<?php
require('inc/db_dm.php');

$数据库 = new 数据库达梦类;

$数据库->主机 = 'localhost';
$数据库->用户名 = '邀踢动画';
$数据库->用户名 = mb_convert_encoding($数据库->用户名, 'utf-8');
echo $数据库->用户名;
$数据库->密码 = 'ydmzfnfsosftd12h';
//$数据库->密码 = 'SYSDBA';
$数据库->模式 = '邀踢动画';
$数据库->连接();
?>