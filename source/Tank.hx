package ;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;

class Tank extends DisplaySprite
{

	public static inline var SPEED:Int = 80;
	
	public var moving:Bool = false;
	
	private var _dest:FlxPoint;
	private var _vec:FlxVector;
	private var _turret:DisplaySprite;
	private var _target:FlxPoint;
	
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
		_turret.relativeY = (height / 2) - (_turret.width/2);
		add(_turret);
		_target = FlxPoint.get();
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
		var oldx:Float = _vec.x;
		var oldy:Float = _vec.y;
		super.update();
		_vec.x = _dest.x - x;
		_vec.y = _dest.y - y;
		if (signOf(oldx) != signOf(_vec.x) || signOf(oldy) != signOf(_vec.y))
			finishMoveTo();
		var a:Float = FlxAngle.getAngle(getMidpoint(), _target) - 90;
		_turret.relativeAngle = a;
		
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
	
}