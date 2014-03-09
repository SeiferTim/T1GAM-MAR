package ;
import flixel.FlxObject;
import flixel.system.FlxCollisionType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;

class Smoke extends ZParticle
{
	public function new() 
	{
		super();
		collisionType = FlxCollisionType.NONE;
		moves = false;
		immovable = true;
		allowCollisions  = FlxObject.NONE;
		
		
	}
	
	//override public function reset(X:Float, Y:Float):Void 
	//{
		//super.reset(X+FlxRandom.floatRanged(-48,48), Y-FlxRandom.intRanged(0,64));
	//}
	
	override public function onEmit():Void 
	{
		super.onEmit();
		lifespan = 100;
		//super.reset(X+FlxRandom.floatRanged(-48,48), Y-FlxRandom.intRanged(0,64));
		x += FlxRandom.floatRanged( -48, 48);
		y -= FlxRandom.intRanged(0, 64);
		useColoring = false;
		useScaling = false;
		useFading = false;
		alpha = 0;
		animation.frameIndex = FlxRandom.intRanged(0, 3);
		draw();
		FlxTween.singleVar(this, "alpha", FlxRandom.floatRanged(.4, .9), FlxRandom.floatRanged(.4, .8), { type:FlxTween.ONESHOT, ease:FlxEase.sineIn, complete:doneFadeIn } );
		FlxTween.singleVar(this, "y",y - (FlxRandom.intRanged(2,4)*8),FlxRandom.floatRanged(2,4), { type:FlxTween.ONESHOT, ease:FlxEase.quadOut} );
		FlxTween.singleVar(this, "x", x + (FlxRandom.intRanged(1,3) * 4 * FlxRandom.sign()), FlxRandom.floatRanged(.6, 1.6), { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
	}
	
	private function doneFadeIn(T:FlxTween):Void
	{
		FlxTween.singleVar(this, "alpha", 0, FlxRandom.floatRanged(1.6, 3.6) ,{ type:FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:doneFadeOut } );
	}
	
	private function doneFadeOut(T:FlxTween):Void
	{
		lifespan = 0;
	}
	
	override private function get_z():Float 
	{
		return _floor;
	}
	
	override public function update():Void 
	{
		if (lifespan > 0)
			lifespan = 100;
		super.update();
	}
	
}