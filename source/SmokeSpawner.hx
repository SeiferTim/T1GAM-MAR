package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class SmokeSpawner extends ZEmitterExt
{

	
	private var _t:FlxTimer;
	public var bursted(default, null):Bool = false;
	public var bounds(default, null):FlxSprite;
	
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 1, Height:Float = 1) 
	{
		super(X, Y, 0, ZEmitterExt.STYLE_CLOUD);
		//parent = Parent;
		bounds = new FlxSprite(X, Y);
		bounds.makeGraphic(Std.int(Width), Std.int(Height),FlxColor.WHITE);
		width = Width;
		height = Height;
		z = Y+Height;
		setRotation(0, 0);
		particleClass = Smoke;
		setMotion(0, 0, 100);
		setAlpha(0, 0, 0, 0);
		particleDrag.x = 0;
		particleDrag.y = 0;
		
		//makeParticles("images/smoke.png", 100, 0, true, FlxObject.NONE);
		
		
		start(true, 100, .1, Std.int((Width / 4) + (Height / 4)), 100);
	}
	
	override public function update():Void
	{
		
		if (_explode && !bursted && !on)
		{
			bursted = true;
//			_quantity = 10;
			start(false, 100, .2,0);
			
			_t = FlxTimer.start(.66, reduceQuant, 0);
		}
		super.update();
	}
	
	private function reduceQuant(T:FlxTimer):Void
	{
		if (bursted)
		{
			if (frequency < 1)
			{
				//if (frequency < .8)
				frequency += FlxG.elapsed * .2;
			}
			else
			{
				
				T.abort();
				_quantity = 1;
				_waitForKill = true;
				//on = false;
				//kill();
			}
		}
	}
	
}