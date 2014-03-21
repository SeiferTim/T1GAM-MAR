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

	public static inline var SPEED:Int = 180;
	public static inline var DIST:Int = 140;
	private var _shootClock:Float;
	private var _prop:DisplaySprite;
	public var isDead(default, null):Bool = false;
	private var _floor:Float;
	private var _target:FlxPoint;
	private var _thrust:Float;
	private var _body:DisplaySprite;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		calcOnScreen = false;
		makeGraphic(50, 50, 0x0);
		_body = new DisplaySprite();
		_body.loadGraphic("images/copter.png", false, false, 50, 50);
		add(_body);
		setPosition(X, Y);
		_prop = new DisplaySprite(0, 0);
		_prop.loadGraphic("images/propellor.png", true, false, 32, 32);		
		_prop.animation.add("spin", [0, 1], 12);
		_prop.relativeAngle = 0;
		_prop.relativeX = 0;
		_prop.relativeY = 0;
		_body.relativeX = (width/2) - (_body.width/2);
		_body.relativeY = (height/2) - (_body.height/2);
		_body.relativeAngularAcceleration = 0;
		_prop.relativeAngularAcceleration = 0;
		_body.relativeAngularVelocity = 0;
		_prop.relativeAngularVelocity = 0;
		_body.moves = false;
		_prop.moves = false;
		add(_prop);
		calcZ = false;
		_target = FlxPoint.get();
		maxAngular = 120;
		angularDrag = 200;
		drag.x = 60;
		_thrust = 0;
	}
	
	public function setTarget(X:Float, Y:Float):Void
	{
		_target.x = X;
		_target.y = Y;
	}

	
	public function init(xPos:Float, yPos:Float, TarX:Float, TarY:Float):Void
	{
		reset(xPos - width / 2, yPos -height / 2);
		health = 1;

		_shootClock = 0;
		isDead = false;
		
		setTarget(TarX, TarY);
		
		angle = angleTowardPlayer();
		_prop.animation.play("spin");
		
	}
	
	private function angleTowardPlayer():Float
	{
		return FlxAngle.getAngle(getMidpoint(_point), _target);
	}
	
	override public function update():Void
	{
		if (!alive || !exists || !visible)
		{
			return;
		}
		
		var a:Float;
		
		if (!isDead)
		{
			var da:Float = angleTowardPlayer();
			if (da < angle)
			{
				
				angularAcceleration  = -angularDrag;
			}
			else if (da > angle)
			{
				angularAcceleration = angularDrag;
			}
			else
			{
				angularAcceleration = 0;
			}
			
			var d:Float = FlxMath.getDistance(getMidpoint(_point), _target);
			//trace(d);
			if (d < DIST)
			{
				// move back
				_thrust = FlxVelocity.computeVelocity(_thrust, SPEED*.8, drag.x, SPEED/2);
				FlxAngle.rotatePoint(0, _thrust, 0, 0, -angle, velocity);
			}
			else if (d > DIST + (SPEED/2))
			{
				_thrust = FlxVelocity.computeVelocity(_thrust, SPEED*1.2, drag.x, SPEED);
				FlxAngle.rotatePoint(0, _thrust, 0, 0, angle, velocity);
			}
			else
			{
				acceleration.x = 0;
				acceleration.y = 0;
			}
			
			var shoot:Bool = false;
			var os:Float = _shootClock;
			_shootClock += FlxG.elapsed;
			if ((os<2) && (_shootClock >=2))
			{
				_shootClock = 0;
				shoot = true;
			}
			
			var m:FlxPoint = getMidpoint();
			if (shoot)
			{
				if (onScreen)
				{
					Reg.playState.shootBullet(m, _body.angle, Bullet.MISSLE);
					
				}
			}
			m = FlxDestroyUtil.put(m);
		}
		else
		{
			
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
	
	override public function draw():Void 
	{
		if (!isDead)
		{
			_body.relativeAngle = -angle+angleTowardPlayer();
			_prop.relativeAngle = -angle;
			_prop.angle = 0;
			_body.angle = angleTowardPlayer();
		}
		else
		{
			angle += 30;
		}
		
		_prop.relativeX = 0;
		_prop.relativeY = 0;// -8;
		_body.x = x + (width / 2) - (_body.width / 2);
		_body.y = y + (height / 2) - (_body.height / 2);
		_prop.x = x + (width / 2) - (_prop.width / 2);
		_prop.y = y + (height / 2) - (_prop.height / 2);
		
		super.draw();
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
		if (onScreen)
		{
			isDead = true;
			
			velocity.x = 0;
			velocity.y = SPEED*.75;
			
			_floor = 64 + y + (height / 2);
		}
		else
			super.kill();
		
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