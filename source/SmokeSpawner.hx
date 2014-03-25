package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

class SmokeSpawner extends ZEmitterExt
{

	
	private var _t:FlxTimer;
	public var bursted(default, null):Bool = false;
	public var bounds(default, null):FlxSprite;
	
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 1, Height:Float = 1) 
	{
		super(0, 0, 0, ZEmitterExt.STYLE_CLOUD);

		setRotation(0, 0);
		particleClass = Smoke;
		setMotion(0, 0, 100);
		setAlpha(0, 0, 0, 0);
		particleDrag.x = 0;
		particleDrag.y = 0;
		
		for (i in 0...100)
		{
			add(new Smoke());
		}		
		
	}
	
	public function init(X:Float, Y:Float, Width:Float, Height:Float):Void
	{
		setPosition(X, Y);
		width = Width;
		height = Height;
		bursted = false;
		bounds = new FlxSprite(X, Y);
		bounds.makeGraphic(Std.int(Width), Std.int(Height),FlxColor.WHITE);
		z = Y+Height;
		var quant:Int = Std.int((Width / 4) + (Height / 4));
		start(true, 100, .1, quant, 100);
	}
	
	override public function update():Void
	{
		
		if (_explode && !bursted && !on)
		{
			bursted = true;
			start(false, 100, .2,0);
			_t = FlxTimer.start(.05, reduceQuant, 0);
		}
		super.update();
	}
	
	private function reduceQuant(T:FlxTimer):Void
	{
		if (bursted)
		{
			if (frequency < 1)
			{
				frequency += FlxG.elapsed * .2;
			}
			else
			{
				T.abort();
				_quantity = 1;
				_waitForKill = true;
				life.max = 4;
			}
		}
	}
	
	override public function kill():Void
	{
		bounds.kill();
		bounds = FlxDestroyUtil.destroy(bounds);
		super.kill();
	}
	
	
}