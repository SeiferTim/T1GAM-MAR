package ;

import flixel.effects.particles.FlxParticle;

class ZParticle extends FlxParticle
{

	private var _floor:Float;
	private var _justBounced:Bool = false;
	private var _touchingFloor:Bool = false;
	private var _wasTouchingFloor:Bool = false;
	private var _z:Float;
	public function new() 
	{
		super();
		
	}
	
	override public function update():Void 
	{
		if (y >= _floor-1)
		{
			velocity.x = 0;
			velocity.y = 0;
			y = _floor-1;
		}
		super.update();
	}
	
	private function set_floor(value:Float):Float 
	{
		return _floor = value;
	}
	
	public var floor(null, set_floor):Float;
	
	function get_z():Float 
	{
		return y;
	}
	
	public var z(get_z, null):Float;
	
}