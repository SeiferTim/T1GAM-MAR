package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;

class SmokeSpawner extends ZEmitterExt
{

	public var parent(default, null):CityTile;
	private var _t:FlxTimer;
	public var bursted(default, null):Bool = false;
	
	public function new(X:Float=0, Y:Float=0, Parent:CityTile) 
	{
		super(X, Y, 100, ZEmitterExt.STYLE_CLOUD);
		parent = Parent;
		z = Y;
		setRotation(0, 0);
		particleClass = Smoke;
		setMotion(0, 0, 100);
		setAlpha(0, 0, 0, 0);
		particleDrag.x = 0;
		particleDrag.y = 0;
		makeParticles("images/smoke.png", 20, 0, true, FlxObject.NONE);
		start(true,100,.1,20,100);		
	}
	
	override public function update():Void
	{
		if (_explode && !bursted && !on)
		{
			bursted = true;
			start(false, 10, .33);
			_quantity = 10;
			_t = FlxTimer.start(.66, reduceQuant, 0);
		}
		super.update();
	}
	
	private function reduceQuant(T:FlxTimer):Void
	{
		if (bursted)
		{
			if (frequency < .8)
			{
				if (frequency < .8)
					frequency += FlxG.elapsed * .2;
			}
			else
				T.abort();
		}
	}
	
}