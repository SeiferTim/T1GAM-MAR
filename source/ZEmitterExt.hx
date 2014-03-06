package ;

import flixel.effects.particles.FlxEmitterExt;

class ZEmitterExt extends FlxEmitterExt
{
	
	public static var STYLE_BLOOD:Int = 0;
	public static var STYLE_CLOUD:Int = 1;
	
	
	public var z:Float;
	public var style:Int = 0;
	
	public function new(X:Float=0, Y:Float=0, Size:Int=0, Style:Int=0) 
	{
		super(X, Y, Size);	
		style = Style;
	}
	
}