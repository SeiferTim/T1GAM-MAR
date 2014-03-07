package ;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;

class Smoke extends ZParticle
{

	public function new() 
	{
		super();
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X+FlxRandom.floatRanged(-48,48), Y-FlxRandom.intRanged(0,64));
		
	}
	
	override public function onEmit():Void 
	{
		super.onEmit();
		alpha = 0;
		animation.frameIndex = FlxRandom.intRanged(0, 3);
		var _a:FlxTween = FlxTween.singleVar(this, "alpha", FlxRandom.floatRanged(.4, .9), FlxRandom.floatRanged(.1, .4), { type:FlxTween.ONESHOT, ease:FlxEase.quintIn, complete:doneFadeIn } );
		var _t:FlxTween = FlxTween.singleVar(this, "y",y - (FlxRandom.intRanged(2,4)*8),FlxRandom.floatRanged(2,4), { type:FlxTween.ONESHOT, ease:FlxEase.quartOut} );
		var _s:FlxTween = FlxTween.singleVar(this, "x", x + (FlxRandom.intRanged(1,3) * 8 * FlxRandom.sign()), FlxRandom.floatRanged(.6, 1.6), { type:FlxTween.PINGPONG, ease:FlxEase.circInOut } );
	}
	
	private function doneFadeIn(T:FlxTween):Void
	{
		var _a:FlxTween = FlxTween.singleVar(this, "alpha", 0, FlxRandom.floatRanged(1.6, 3.6) ,{ type:FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:doneFadeOut } );
	}
	
	private function doneFadeOut(T:FlxTween):Void
	{
		lifespan = 0;
	}
	
	override private function get_z():Float 
	{
		return _floor;
	}
	
}