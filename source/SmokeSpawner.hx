package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;

class SmokeSpawner extends ZEmitterExt
{

	public var parent(default, null):CityTile;
	private var _t:FlxTimer;
	
	public function new(X:Float=0, Y:Float=0, Parent:CityTile) 
	{
		super(X, Y, 100, ZEmitterExt.STYLE_CLOUD);
		parent = Parent;
		z = Y;
		setRotation(0, 0);
		particleClass = Smoke;
		setMotion(0, 0, 100);
		particleDrag.x = 0;
		particleDrag.y = 0;
		//setAlpha(0, 0);
		makeParticles("images/smoke.png", 20, 0, true, FlxObject.NONE);
		start(false, 100, .33);
		_t = FlxTimer.start(.66, reduceQuant, 0);
		
	}
	
	private function reduceQuant(T:FlxTimer):Void
	{
		if (_quantity> 6)
		{
			_quantity--;
		
			if (frequency > .2)
				frequency -= FlxG.elapsed * .33;
		}
		else
			T.abort();
	}
	
}