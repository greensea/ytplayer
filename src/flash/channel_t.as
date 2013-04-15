class channel_t {
	public var channel:Number;
	public var cmtID:Number;
	public var channelBreadth:Number;
	public var deathTime:Number;
	public var textWidth:Number;
	public var text:String;
	public var sTime:Number;
	public var flyType:Number;
	public var flySpeed:Number;
	public var isSubtitle:Boolean;
	public var alignment:Number;
		
	function channel_t(txt:TextField, cmt:Object){
		this.channel = (cmt.channel == undefined) ? null : int(cmt.channel);
		this.cmtID = cmt.cmtID; 
		this.channelBreadth = cmt.fontSize + 2; 
		this.deathTime = (cmt.sTime + cmt.flySpeed); 
		this.textWidth = txt.textWidth; 
		this.text = cmt.cmtText; 
		this.sTime = cmt.sTime;
		this.flyType = cmt.flyType;
		this.flySpeed = cmt.flySpeed;
		this.alignment = (cmt.alignment == undefined) ? null : cmt.alignment;
	}
	
}

