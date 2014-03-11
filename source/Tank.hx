package ;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;

class Tank extends DisplaySprite
{

	public static inline var SPEED:Int = 20;
	
	public var moving:Bool = false;
	
	private var _dest:FlxPoint;
	private var _vec:FlxVector;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		makeGraphic(8, 8, FlxColor.WHITE);
		_dest = FlxPoint.get();
		_vec = FlxVector.get();
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
		z = 80 * 64 * 2;
	}
	
	private function finishMoveTo():Void
	{
		setPosition(_dest.x, _dest.y);
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
	}
	
	private function signOf(f:Float):Int
	{
		if (f < 0)
			return -1;
		else
			return 1;
	}
	
}