package ;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class Bullet extends DisplaySprite
{

	private inline static var SPEED:Int = 200;
	
	public function new() 
	{
		super();
		makeGraphic(8, 8, FlxColor.CRIMSON);
		calcOnScreen = false;
		
	}
	
	public function launch(Location:FlxPoint, Angle:Float = 0):Void
	{
		super.reset(Location.x - width / 2, Location.y - height / 2);
		FlxAngle.rotatePoint(0, SPEED, 0, 0, Angle, _point);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
	}
	
	override public function update():Void 
	{
		if (!onScreen)
		{
			exists = false;
			alive = false;
		}
		else if (!alive)
		{
			exists = false;
		}
		else if (touching != 0)
		{
			kill();
		}
		
		if (!exists || !visible)
			return;
		super.update();
	}
	
	override public function kill():Void 
	{
		if (!alive)
		{
			return;
		}
		velocity.x = 0;
		velocity.y = 0;
		alive = false;
		solid = false;
		//super.kill();
	}
	override private function get_z():Float 
	{
		if (calcZ)
			return y + height + 16;
		else
			return _z;
		
		
	}
}