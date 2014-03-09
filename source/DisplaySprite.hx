package ;

import flixel.addons.display.FlxNestedSprite;

class DisplaySprite extends FlxNestedSprite
{

	private var _z:Float = 0;
	
	/**
	 * If the system should calculate Z or not
	 */
	public var calcZ:Bool = true;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
	}
	
	function get_z():Float
	{
		if (calcZ)
			return y + height;
		else
			return _z;
	}
	
	function set_z(Value:Float):Float
	{
		if (!calcZ)
			_z = Value;
		return _z;
	}
	
	public var z(get_z, set_z):Float;
	
	override public function update():Void 
	{
		if (!isOnScreen())
			return;
		super.update();
	}
	
}