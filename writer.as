/***********YTdonghuaPlayer************/
/*******	writer.as		***********/
/*****	用以控制评论提交和输入	******/
/**************************************/

var _writer_var_fontsize = FLY_FONTSIZE_NORMAL;
var _writer_var_fontcolor = FLY_FONTCOLOR_DEFAULT;
var _writer_var_commentmode = FLY_TYPE_FLY;
var _writer_var_issubtitle = false;

function writer_submit(){
	var t = _level0.commentWriter.txtWriterInput;
	if(t.length == 0) return false;
	
	var playTime = _video_get_time() - 0.1;	//把评论时间提前0.1s
	if(playTime <= 0) playTime = 0.1;			//另外0.1s之前不允许评论
	
	trace(ns.time);
	
	//添加新的评论到屏幕上
	var newCmt = Array(t.text, {fontSize:_writer_var_fontsize, 
								 fontColor:_writer_var_fontcolor,
								 flyType:_writer_var_commentmode, 
								 sTime:playTime,
								 flySpeed:FLY_SPEED_NORMAL,
								 isSubtitle:_writer_var_issubtitle,
								 commentTime:(new Date())
						});
	comment_add_comment(newCmt[0], newCmt[1])
	
	//提交评论到服务器
	writer_send(newCmt[0], newCmt[1]);
	t.text = "";
}