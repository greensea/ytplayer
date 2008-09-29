/***********YTdonghuaPlayer************/
/*******	commentgrid.as	***********/
/**************************************/

//var dgrComments:DataGrid;
dgrCmtsLsn = new Object();

dgrCmtsLsn.change = function(eventObject){
	trace(dgrComments.selectedItem);
	for(var a in dgrComments.selectedItem){
		trace(a + "=" + dgrComments.selectedItem[a]);
	}
}


dgrComments.addEventListener("change", dgrCmtsLsn);

