package ;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitterExt;
import flixel.FlxG;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
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
	private var _bullets:FlxTypedGroup<Bullet>;
	//private var _gibs:ZEmitterExt;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		calcOnScreen = false;
		loadGraphic("images/tank.png", false, false, 28, 28);
		width = 24;
		height = 24;
		offset.x = 2;
		offset.y = 2;
		_dest = FlxPoint.get();
		_dest.x = X;
		_dest.y = Y;
		_vec = FlxVector.get();
		setPosition(X, Y);
		_turret = new DisplaySprite(0, 0);
		_turret.loadGraphic("images/tank-turret.png", false, false, 48, 48);		
		_turret.relativeX = (width / 2) - (_turret.width/2);
		_turret.relativeY = (height / 2) - (_turret.width / 2);
		_turret.setOriginToCenter();
		add(_turret);
		_target = FlxPoint.get();
	}
	
	public function init(xPos:Float, yPos:Float, Bullets:FlxTypedGroup<Bullet>):Void
	{
		
		_bullets = Bullets;
		//_gibs = Gibs;
		
		reset(xPos - width / 2, yPos - height / 2);
		_dest.x = x;
		_dest.y = y;
		_vec.set();
		health = 1;
		_shootClock = 0;
		
	}
	
	public function moveTo(X:Float, Y:Float, Speed:Float):Void
	{
		//trace("moveto: " + X + ", " + Y);
		moving = true;
		_dest.set(X, Y);
		_vec.x = _dest.x - x;
		_vec.y = _dest.y - y;
		_vec.normalize();
		velocity.x = _vec.x * Speed;
		velocity.y = _vec.y * Speed;
		
	}
	
	private function finishMoveTo():Void
	{
		setPosition(_dest.x, _dest.y);
		stopMoving();
	}
	
	public function stopMoving():Void
	{
		velocity.set();
		moving = false;
	}
	
	override public function update():Void 
	{
		
		var a:Float = FlxAngle.getAngle(getMidpoint(_point), _target);
		_turret.relativeAngle = a;
		
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
			var b:Bullet = _bullets.recycle(Bullet);
			b.launch(getMidpoint(_point), a);
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
		
		_dest.put();
		_target.put();
		_vec.put();
		
		_bullets = null;
		//_gibs = null;
		
		_dest = null;
		_target = null;
		_vec = null;
		
		
	}
	
	override public function kill():Void 
	{
		if (!alive)
			return;
		
		super.kill();
		
		//_gibs.at(this);
		//_gibs.z = z;
		/*
		var p:ZParticle;
		for (i in _gibs.members)
		{
			p = cast i;
			p.floor = FlxRandom.intRanged(Std.int(y -2), Std.int(y + height + 2));
		}
		_gibs.start(true, 2, 0, 10,4);
		_gibs.update();
		*/
		Reg.playState.createSmallSmoke(x - 2, y - 2, width + 4, height + 4);
		
	}
	
	override public function hurt(Damage:Float):Void 
	{
		
		
		super.hurt(Damage);
	}
	
}