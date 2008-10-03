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



//囧的XML的getElementByTagName函数 递归查找（注意是Element而不是Elements哦）
function xml_getElementByTagName(xml, nodeName){
	for(var i = 0; i < xml.childNodes.length; i++){
		if(xml.childNodes[i].nodeName == nodeName){
			return xml.childNodes[i]
		}
		else{
			if(xml.childNodes[i].nodeName){
				var node = xml_getElementByTagName(xml.childNodes[i], nodeName);
				if(node.nodeName == nodeName) return node;
			}
		}
	}
}