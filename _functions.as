/***********YTdonghuaPlayer************/
/*******	_functions.as	***********/
/**************************************/

function _timestamp2date(ts){
	var t:Date = new Date(ts * 1000);
	return _leaderZ(t.getMonth(), 2) + "月" + _leaderZ(t.getDate(), 2) + "日 "
			+ _leaderZ(t.getHours(), 2) + ":" + _leaderZ(t.getMinutes(), 2) + ":" + _leaderZ(t.getSeconds(), 2);
}

function _date2date(vdate){
	var t:Date = vdate;
	return _leaderZ(t.getMonth(), 2) + "月" + _leaderZ(t.getDate(), 2) + "日 "
			+ _leaderZ(t.getHours(), 2) + ":" + _leaderZ(t.getMinutes(), 2) + ":" + _leaderZ(t.getSeconds(), 2);
}
	

//前导零，（数字，总位数）
function _leaderZ(num, wid){
	var s = num + "";
	while(s.length < wid) s = "0" + s;
	return s;
}
