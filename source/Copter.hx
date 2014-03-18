package ;
import flixel.FlxG;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVector;
import flixel.util.FlxVelocity;


class Copter extends DisplaySprite
{

	public static inline var SPEED:Int = 150;
	public static inline var DIST:Int = 120;
	private var _shootClock:Float;
	private var _prop:DisplaySprite;
	public var isDead(default, null):Bool = false;
	private var _floor:Float;
	private var _target:FlxPoint;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		calcOnScreen = false;
		loadGraphic("images/copter.png", false, false, 32, 32, false, "copter");
		setPosition(X, Y);
		_prop = new DisplaySprite(0, 0);
		_prop.loadGraphic("images/propellor.png", true, false, 32, 32, false, "prop");		
		_prop.animation.add("spin", [0, 1], 30);
		_prop.animation.play("spin");
		_prop.relativeAngle = 0;
		_prop.relativeX = (width / 2 )- (_prop.width / 2);
		_prop.relativeY = (height / 2 )- (_prop.height / 2)-8;
		add(_prop);
		calcZ = false;
		_target = FlxPoint.get();
		
	}
	
	public function setTarget(X:Float, Y:Float):Void
	{
		_target.x = X;
		_target.y = Y;
	}

	
	public function init(xPos:Float, yPos:Float):Void
	{
		reset(xPos - width / 2, yPos -height / 2);
		health = 1;

		_shootClock = 0;
		isDead = false;
	}
	

	
	override public function update():Void
	{
		if (!alive || !exists || !visible)
		{
			trace("...uh...");
			return;
		}
		
		var a:Float;
		
		if (!isDead)
		{
			var m:FlxPoint = getMidpoint();
			a = FlxAngle.getAngle(m, _target);
			angle = a;
		
			// if we are closer than DIST pixels from the target, back up,
			var d:Float = FlxMath.getDistance(m, _target);
			if (d < DIST)
			{
				// back up!
				FlxAngle.rotatePoint(SPEED / 2, 0, 0, 0, -a, _point);
				velocity.x = _point.x;
				velocity.y = _point.y;
				
			}
			else if (d >= DIST)
			{
				// get closer
				FlxAngle.rotatePoint(SPEED, 0, 0, 0, a, _point);
				velocity.x = _point.x;
				velocity.y = _point.y;
			}

			
			
			var shoot:Bool = false;
			var os:Float = _shootClock;
			_shootClock += FlxG.elapsed;
			if ((os<2) && (_shootClock >=2))
			{
				_shootClock = 0;
				shoot = true;
			}
			
			
			if (shoot)
			{
				if (onScreen)
				{
					Reg.playState.shootBullet(m, a, Bullet.MISSLE);
					
				}
			}
			m = FlxDestroyUtil.put(m);
			
			

		}
		else
		{
			angle += 10;
			if (y + (height/2) >= _floor)
			{
				velocity.set();
				Reg.playState.createSmallSmoke(x - 8, y - 8, width + 16, height + 16);
				alive = false;
				exists = false;
			}
			
		}
		super.update();
	}
	
	
	override public function destroy():Void 
	{
		super.destroy();
		_target = FlxDestroyUtil.put(_target);
		
	}
	
	override public function kill():Void 
	{
		if (!alive)
			return;
		isDead = true;
		
		velocity.x = 0;
		velocity.y = SPEED/2;
		
		_floor = 64 + y + (height / 2);
		
		
	}
	
	override private function get_z():Float 
	{
		if (!isDead)
		{
			return y + (height / 2) + 130;
			
		}
		else
		{
			return _floor - (64 - y + (height / 2)) - 8;
		}
	}
}