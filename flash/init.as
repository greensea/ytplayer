/***********YTdonghuaPlayer************/
/*******	init.as			***********/
/**************************************/

init_main();

function init_main(){
	flyTypeWindow._visible = false;
	
	video_button_enable(false);
	
	dgrComment.setStyle("fontFamily", "宋体");
	
	tip_add("加载参数: p=" + _root.p);
}


function _init_dgrComments(){
	//import mx.controls.DataGrid;
	//var dgrComments:DataGrid;
/*	dgrComments.addItem({name:"nina", age:234});
	dgrComments.addItem({name:"flash", age:"Flash"});
	dgrComments.addItem({data:"dreamweaver", label:"Dreamweaver"});
	dgrComments.addItem({name:"coldfusion", age:"ColdFusion"});*/
/*	dgrComments.addColumn("片时");
	dgrComments.addColumn("内容");
	dgrComments.addColumn("评论时间");
	dgrComments.getColumnAt(0).width = 45;
	dgrComments.getColumnAt(1).width = 300;
	dgrComments.getColumnAt(2).width = 120;
	dgrComments.hScrollPolicy = "on";
	dgrComments.headerHeight = 25;*/
}