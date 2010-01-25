	<fieldset class="GeCiShangChuan">
		<legend>给动画上传lrc歌词文件作为底部字幕</legend>
		<form enctype="multipart/form-data" action="uploadlrc.php?id=<?php echo $_GET['id'];?>" method="POST">
			
			<div>给这个系列的弹幕决定一个名字：<input type="text" name="groupname" value="" /></div>
			<div>弹幕颜色，请填入十六进制的颜色值：<input type="text" name="color" value="ffffff" /></div>
			<div>选择LRC歌词文件：<input name="lrc" type="file" /></div>
			
			<input type="hidden" name="id" value="<?php echo $_GET['id'];?>" />
			<input type="submit" value="上传文件" />
		</form>
	</fieldset>





<?php

if (isset($_GET['id']) == 0) die('');

require_once('类文件/头.php');
require_once('类文件/邀踢动画。歌词文件分析.php');


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

move_uploaded_file($_FILES['lrc']['tmp_name'], $savepath);

$savepath_s = $数据库->查询语句转义($savepath);
$groupname_s = $数据库->查询语句转义($groupname);

$数据库->查询("INSERT INTO 弹幕分组 (动画编号,用户编号,组名,文件地址)VALUES($id," .  $邀踢动画->用户->编号 . ",'$groupname_s','$savepath_s')");
$result = $数据库->查询('SELECT MAX(编号) AS m FROM 弹幕分组');
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

	$sql .= "INSERT INTO 分组弹幕(组编号,用户编号,内容,播放时间,字号,颜色,模式,速度)VALUES($组编号,$用户编号,'$内容',$片时,$大小,$颜色,$模式,$速度);";
}
$数据库->查询($sql);

ob_clean();
die('歌词上传成功，共添加了' . count($lrcs) . '条弹幕');

?>


