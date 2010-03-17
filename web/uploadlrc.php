<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link type="text/css" rel="stylesheet" href="/index.css" />
		<title>ytp alpha2 上传lrc歌词</title>
	</head>
	
	<fieldset class="GeCiShangChuan">
		<legend>给动画上传lrc歌词文件作为底部字幕</legend>
		<form enctype="multipart/form-data" action="uploadlrc.php?id=<?php echo $_GET['id']?>" method="POST">
			
			<div>给这个系列的弹幕决定一个名字：<input type="text" name="groupname" value="" /></div>
			<div>
				弹幕颜色，请填入十六进制的颜色值：#<input type="text" name="color" value="ffffff" onkeyup="change_color(this)" />
				<span id="color_test">（当前颜色是这个样子的）</span>
			</div>
			<div>选择LRC歌词文件：<input name="lrc" type="file" /></div>
			
			<input type="hidden" name="id" value="<?php echo $_GET['id'];?>" />
			<input type="submit" value="上传文件" />
		</form>
	</fieldset>

	<script type="text/javascript">
	function change_color(obj) {
		if (obj.value.length == 6) {
			document.getElementById("color_test").style.color = "#" + obj.value;
		}
		else {
			document.getElementById("color_test").style.color = "#000000";
		}
	}
	</script>

</body>
</html>



<?php

if (isset($_GET['id']) == 0) die('');
if (!isset($_POST['id'])) die('');

require_once('require/header.php');
require_once('require/ytp.lrcparser.php');


$id = intval($_GET['id']);
$groupname = $_POST['groupname'];
$color = $_POST['color'];
$color = hexdec(str_replace('#', '', $color));

$savepath = realpath('./lrcs') . '/';

// 确定保存路径
if (!file_exists($savepath . $_FILES['lrc']['name'])) {
	$savepath = $savepath . $_FILES['lrc']['name'];
}
else {
	$afternum = 1;
	while (file_exists($savepath . $_FILES['lrc']['name'] . '.' . $afternum)) $afternum++;
	$savepath = $savepath . $_FILES['lrc']['name'] . '.' . $afternum;
}

ytp_move_uploaded_file($_FILES['lrc']['tmp_name'], $savepath);

$savepath_s = $数据库->查询语句转义($savepath);
$groupname_s = $数据库->查询语句转义($groupname);

$数据库->查询("INSERT INTO popsub_group (videoid,userid,groupname,filepath)VALUES($id," .  $邀踢动画->用户->编号 . ",'$groupname_s','$savepath_s')");
$result = $数据库->查询('SELECT MAX(id) AS m FROM popsub_group');
$maxid = $result[0]['m'];

$sql = '';
$lrcs = 歌词文件分析($savepath);

for ($i = 0; $i < count($lrcs); $i++) {
	$组编号 = $maxid;
	$用户编号 = $邀踢动画->用户->编号;
	$内容 = $数据库->查询语句转义($lrcs[$i]['内容']);
	$片时 = $lrcs[$i]['片时'];
	$大小 = FLY_FONTSIZE_SMALL;
	$颜色 = $color;
	$模式 = FLY_MODE_BOTTOM;
	$速度 = $lrcs[$i]['速度'];
	$当前时间 = time();

	$sql = "INSERT INTO group_popsub(groupid,userid,content,playtime,fontsize,color,flymode,speed,popsubtime)VALUES($组编号,$用户编号,'$内容',$片时,$大小,$颜色,$模式,$速度,$当前时间)";
	$数据库->查询($sql);
}


ob_clean();
die('歌词上传成功，共添加了' . count($lrcs) . '条弹幕');

?>


