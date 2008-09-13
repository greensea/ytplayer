/***********YTdonghuaPlayer************/
/*******	_functions.as	***********/
/**************************************/

function _timestamp2date(ts){
	var t:Date = new Date(ts * 1000);
	return t.getMonth() + "月" + t.getDate() + "日 " + t.getHours() + ":" + t.getMinutes() + ":" + t.getSeconds();
}