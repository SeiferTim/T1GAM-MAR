package ;
import flixel.FlxG;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class Bullet extends DisplaySprite
{

	private var _time:Float;
	
	private inline static var SPEED:Int = 200;
	
	public inline static var STANDARD:Int = 0;
	public inline static var MISSLE:Int = 1;
	
	public var style(default, null):Int;
	
	public function new() 
	{
		super();
		loadGraphic("images/missilepix.png", true, false, 16, 16);
		width = 6;
		height = 6;
		offset.x = 5;
		offset.y = 5;
		calcOnScreen = false;
	}
	
	public function launch(Location:FlxPoint, Angle:Float = 0, Style:Int = 0):Void
	{
		super.reset(Location.x - width / 2, Location.y - height / 2);
		FlxAngle.rotatePoint(0, SPEED, 0, 0, Angle, _point);
		angle = Angle;
		style = Style;
		_time = 0;
		switch(style)
		{
			case STANDARD:
				//makeGraphic(8, 8, FlxColor.CRIMSON);
				velocity.x = _point.x;
				velocity.y = _point.y;
			case MISSLE:
				
				acceleration.x = _point.x*2;
				acceleration.y = _point.y*2;
		}
		
		onScreen = true;
		solid = true;
	}
	
	override public function update():Void 
	{
		if (!onScreen)
		{
			exists = false;
			alive = false;
			return;
		}
		else if (!alive)
		{
			Reg.playState.spawnExplosion(x - 4, x + width + 8, y - 4, y + height + 8);
			exists = false;
		}
		else if (touching != 0)
		{
			kill();
		}
		
		if (!exists || !visible)
			return;
		
		var os:Float = _time;
		_time += FlxG.elapsed;
		if (style == MISSLE)
		{
			if (os < 1 && _time > 1)
			{
				style = STANDARD;
			}
			else
			{
				acceleration.x *= 1.02;
				acceleration.y *= 1.02;
			}

		}
		else 
		{
			if (os < 2 && _time > 2)
			{
				kill();
			}
		}
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
		acceleration.x = 0;
		acceleration.y = 0;
		alive = false;
		solid = false;
	}
	
	override private function get_z():Float 
	{
		if (calcZ)
		{
			if (style == MISSLE)
			{
				return y + (height / 2) + 16 + 130;
			}
			else
			{
				return super.get_z();
			}
		}
		else
			return super.get_z();
	}
}