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
		immovable = true;
		allowCollisions  = FlxObject.NONE;
		solid = false;
		loadGraphic("images/smoke.png", true, false, 32, 32);
		
	}

	override public function onEmit():Void 
	{
		super.onEmit();
		lifespan = 100;
		useColoring = false;
		useScaling = false;
		useFading = false;
		alpha = 0; 
		animation.frameIndex = FlxRandom.intRanged(0, 7);
		draw();
		velocity.x = 0;
		velocity.y = 0;
		_yMod = 0;
		_xMod = 0;
		floor = y + height;
		
		FlxTween.num(alpha, FlxRandom.floatRanged(.4, .9), FlxRandom.floatRanged(.2, .6), { type:FlxTween.ONESHOT, ease:FlxEase.sineIn, complete:doneFadeIn }, tweenAlpha);
		FlxTween.num(_yMod , FlxRandom.intRanged(2, 4), FlxRandom.floatRanged(2, 4), { type:FlxTween.ONESHOT, ease:FlxEase.quadOut }, tweenYMod);
		FlxTween.num(_xMod, (FlxRandom.intRanged(1, 3)  * FlxRandom.sign()) * .8, FlxRandom.floatRanged(.6, 1.6), { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut }, tweenXMod);
	}
	
	private function tweenAlpha(v:Float):Void
	{ 
		alpha = v;
	}
	
	private function tweenYMod(v:Float):Void
	{
		_yMod = v;
	}
	
	private function tweenXMod(v:Float):Void
	{
		_xMod = v;
	}
	
	
	private function doneFadeIn(T:FlxTween):Void
	{
		FlxTween.num(alpha, 0, FlxRandom.floatRanged(1.6, 3.6), { type:FlxTween.ONESHOT, ease:FlxEase.quartIn, complete:doneFadeOut }, tweenAlpha);
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
		x += _xMod/2;
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