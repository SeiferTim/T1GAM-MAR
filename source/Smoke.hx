package ;
import flixel.FlxObject;
import flixel.system.FlxCollisionType;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAngle;

import flixel.util.FlxRandom;

class Smoke extends ZParticle
{
	
	private var _yMod:Float;
	private var _xMod:Float;
	
	public function new() 
	{
		super();
		collisionType = FlxCollisionType.NONE;
		//moves = false;
		immovable = true;
		allowCollisions  = FlxObject.NONE;
		solid = false;
		
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
		//x += FlxRandom.floatRanged( -48, 48);
		//y -= FlxRandom.intRanged(0, 64);
		useColoring = false;
		useScaling = false;
		useFading = false;
		alpha = 0;
		animation.frameIndex = FlxRandom.intRanged(0, 3);
		draw();
		velocity.x = 0;
		velocity.y = 0;
		_yMod = 0;
		_xMod = 0;
		floor = y + height;
		FlxTween.tween(this, {alpha: FlxRandom.floatRanged(.4, .9)}, FlxRandom.floatRanged(.2, .6), { type:FlxTween.ONESHOT, ease:FlxEase.sineIn, complete:doneFadeIn } );
		FlxTween.tween(this, {_yMod:FlxRandom.intRanged(2,4)},FlxRandom.floatRanged(2,4), { type:FlxTween.ONESHOT, ease:FlxEase.quadOut} );
		FlxTween.tween(this, { _xMod: (FlxRandom.intRanged(1, 3)  * FlxRandom.sign())*.8 }, FlxRandom.floatRanged(.6, 1.6), { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
		
	}
	
	private function doneFadeIn(T:FlxTween):Void
	{
		FlxTween.tween(this, {alpha: 0}, FlxRandom.floatRanged(1.6, 3.6) ,{ type:FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:doneFadeOut } );
	}
	
	private function doneFadeOut(T:FlxTween):Void
	{
		lifespan = 0;
		kill();
	}
	
	override private function get_z():Float 
	{
		return _floor;
	}
	
	override public function update():Void 
	{
		if (!alive || !exists)
		{
			return;
		}
		if (lifespan > 0)
			lifespan = 100;
		FlxAngle.rotatePoint(0, 20*Reg.playState.windSpeed*FlxRandom.floatRanged(.6,1.4), 0, 0, Reg.playState.windDir, _point);
		velocity.x = _point.x;
		velocity.y = _point.y;
		y -= _yMod/4;
		x += _xMod;
		super.update();
	}
	
	override public function kill():Void 
	{
		velocity.x = 0;
		velocity.y = 0;
		alpha = 0;
		super.kill();
	}
	
}