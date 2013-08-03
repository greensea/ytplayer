
class g_ns_t {
	public var id:Number;	/// 数组下标
	public var flvurl:String;
	public var bytes_total:Number;
	public var nc:NetConnection;
	public var ns:NetStream;
	public var ready:Boolean;	/// 是否已经调用了 nc.play() 方法（也就是是否已经设置了视频地址）
	public var secondtime:Boolean;	/// 是不是第二次进行连接（第二次调用 ns.play() 方法）
	
	public var videowidth:Number;
	public var videoheight:Number;
}


