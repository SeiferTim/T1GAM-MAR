package ;


class Copter extends DisplaySprite
{

	public static inline var SPEED:Int = 100;
	public var moving:Bool = false;
	private var _target:FlxPoint;
	private var _bullets:FlxTypedGroup<Bullet>;
	private var _gibs:ZEmitterExt;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		
	}
	
}