package ;

import flixel.FlxSprite;

class RoarMarker extends FlxSprite
{

	private var _available:Bool = false;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/roars.png", true, false, 18, 18);
		animation.frameIndex = 0;
		scrollFactor.set();
		_available = false;
		
	}
	
	function get_available():Bool 
	{
		return _available;
	}
	
	function set_available(value:Bool):Bool 
	{
		_available = value;		
		animation.frameIndex = _available ? 1 : 0;
		return _available;
	}
	
	public var available(get_available, set_available):Bool;
	
}