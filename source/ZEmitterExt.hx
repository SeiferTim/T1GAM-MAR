package ;

import flixel.effects.particles.FlxEmitterExt;

class ZEmitterExt extends FlxEmitterExt implements IFlxZ
{
	
	public static var STYLE_BLOOD:Int = 0;
	public static var STYLE_CLOUD:Int = 1;
	
	public var style:Int = 0;
	public var z(get, set):Float;
	private var _z:Float;
	public var onScreen:Bool = true;
	
	public function new(X:Float=0, Y:Float=0, Size:Int=0, Style:Int=0) 
	{
		super(X, Y, Size);	
		style = Style;
	}
	override public function toString():String { return Std.string(_z); }
	
	public inline function get_z():Float
	{
		return _z;
	}	
	
	public function set_z(Value:Float):Float
	{
		return _z = Value;
	}
}