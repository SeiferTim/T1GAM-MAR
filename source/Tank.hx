package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVector;

class Tank extends DisplaySprite
{

	public static inline var SPEED:Int = 80;
	
	public var moving:Bool = false;
	
	private var _dest:FlxPoint;
	private var _vec:FlxVector;
	private var _turret:DisplaySprite;
	private var _target:FlxPoint;
	private var _shootClock:Float;
	private var _wasFacing:Int = -1;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		calcOnScreen = false;
		loadGraphic("images/tank.png", true, true, 64, 64);
		width = 24;
		height = 24;
		offset.x = 20;
		offset.y = 20;
		_dest = FlxPoint.get();
		_dest.x = X;
		_dest.y = Y;
		_vec = FlxVector.get();
		setPosition(X, Y);
		_turret = new DisplaySprite(0, 0);
		_turret.loadGraphic("images/tank-turret.png", false, false, 64, 64);		
		_turret.relativeX = (width / 2) - (_turret.width/2);
		_turret.relativeY = (height / 2) - (_turret.width / 2);
		_turret.centerOrigin();
		animation.add("lr", [0, 1], 12);
		animation.add("u", [2, 3], 12);
		animation.add("d", [4, 5], 12);
		animation.play("lr");
		facing = FlxObject.LEFT;
		add(_turret);
		_target = FlxPoint.get();
		onScreen = true;
	}
	
	public function init(xPos:Float, yPos:Float):Void
	{

		reset(xPos - width / 2, yPos - height / 2);
		_dest.x = x;
		_dest.y = y;
		_vec.set();
		health = 1;
		_shootClock = FlxRandom.floatRanged(0,2.9);
		moving = false;
		
	}
	
	public function moveTo(X:Float, Y:Float, Speed:Float):Void
	{
		moving = true;
		_dest.set(X, Y);
		_vec.x = _dest.x - x;
		_vec.y = _dest.y - y;
		_vec.normalize();
		velocity.x = _vec.x * Speed;
		velocity.y = _vec.y * Speed;
		updateAnimation();
	}
	
	private function updateAnimation():Void
	{
		
		if (velocity.x > 0 && Math.abs(velocity.x) > Math.abs(velocity.y))
		{
			facing = FlxObject.RIGHT;
		}
		else if (velocity.x < 0 && Math.abs(velocity.x) > Math.abs(velocity.y))
		{
			facing = FlxObject.LEFT;
		}
		else if (velocity.y > 0)
		{
			facing = FlxObject.DOWN;
		}
		else if (velocity.y < 0)
		{
			facing = FlxObject.UP;
		}
		
		if (animation.paused)
			animation.resume();
		
		if (_wasFacing == facing)
			return;
		
		var anim:String = "";
		switch(facing)
		{
			case FlxObject.LEFT, FlxObject.RIGHT:
				anim = "lr";
			case FlxObject.UP:
				anim = "u";
			case FlxObject.DOWN:
				anim = "d";
				
		}
		animation.play(anim, true);
		
		_wasFacing = facing;
	}
	
	private function finishMoveTo():Void
	{
		setPosition(_dest.x, _dest.y);
		stopMoving();
		animation.pause();
	}
	
	public function stopMoving():Void
	{
		velocity.set();
		moving = false;
	}
	
	override public function draw():Void 
	{
		_turret.relativeX = 0;
		_turret.relativeY = 0;
		_turret.x = x + (width / 2) - (_turret.width / 2);
		_turret.y = y + (height / 2) - (_turret.height / 2);
		super.draw();
	}
	
	
	override public function update():Void 
	{
		if (!alive || !exists || !visible)
			return;
		var t:FlxPoint = FlxPoint.get();
		t.copyFrom(_target);
		t.y -= 8;
		var a:Float = FlxAngle.getAngle(getMidpoint(_point), t);
		_turret.relativeAngle = a;
		t.put();
		var shoot:Bool = false;
		var os:Float = _shootClock;
		_shootClock += FlxG.elapsed;
		if ((os<4.0) && (_shootClock >=4.0))
		{
			_shootClock = 0;
			shoot = true;
		}
		else if ((os<3.0) && (_shootClock >= 3.0))
		{
			shoot = true;
		}
		
		if (shoot)
		{

			//if (onScreen)
			//	{
			if (Reg.playState.m.mapPathing.ray(getMidpoint(_point), _target))
			{					
				Reg.playState.shootBullet(getMidpoint(_point),a);
				FlxG.sound.play("sounds/Shoot-Standard.wav",.8);
			}
			//	}
			
		}
		
		
		var oldx:Float = _vec.x;
		var oldy:Float = _vec.y;
		super.update();
		_vec.x = _dest.x - x;
		_vec.y = _dest.y - y;
		if (signOf(oldx) != signOf(_vec.x) || signOf(oldy) != signOf(_vec.y))
			finishMoveTo();
	}
	
	private function signOf(f:Float):Int
	{
		if (f < 0)
			return -1;
		else
			return 1;
	}
	
	public function setTarget(X:Float, Y:Float):Void
	{
		_target.x = X;
		_target.y = Y;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_dest = FlxDestroyUtil.put(_dest);
		_target = FlxDestroyUtil.put(_target);
		_vec = FlxDestroyUtil.put(_vec);

	}
	
	override public function kill():Void 
	{
		if (!alive)
			return;
			
		if (onScreen)
		{
			Reg.playState.createSmallSmoke(x - 2, y - 2, width + 4, height + 4);
			FlxG.sound.play("sounds/Smash.wav",.8);
		}
		super.kill();
	}
	
	override public function hurt(Damage:Float):Void 
	{
		super.hurt(Damage);
	}
	
}