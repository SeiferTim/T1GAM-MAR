package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;

class CityTile extends DisplaySprite
{

	public var tier(default, null):Int;
	private var _hurtTimer:Float = 0;
	public var isDead(default, null):Bool;
	
	public function new(X:Float=0, Y:Float=0, Tier:Int = 1) 
	{
		super(X, Y);
		tier = Tier;
		
		loadGraphic("images/city-tiles.png", true, false, 64, 128);
		width = 66;
		height = 66;
		offset.y = 63;
		offset.x = -1;
		animation.frameIndex = tier;
		tier =  tier % 7;
		health = tier;
		moves = false;
		immovable = true;
		allowCollisions = FlxObject.ANY;
		calcOnScreen = false;
		onScreen = true;
	}
	
	override public function update():Void 
	{
		
	}
	
	override public function draw():Void
	{
		if (!exists || !onScreen || !alive)
			return;
		super.draw();
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0 || isDead)
			return;
		_hurtTimer = 1;
		
		super.hurt(Damage);
		if (!isDead)
		{
			FlxG.sound.play("sounds/Crash.wav",.3);
			//var _t:FlxTween = FlxTween.tween(this, {y: y - 2}, .1, { type:FlxTween.ONESHOT, complete:doneBounceUp } );
			FlxTween.num(y, y - 3, .1, { type:FlxTween.ONESHOT, complete:doneBounceUp }, tweenY);
			
		}
		
	}
	
	private function tweenY(v:Float):Void
	{
		y = v;
	}
	
	private function doneBounceUp(T:FlxTween):Void
	{
		//var _t:FlxTween = FlxTween.tween(this, {y: y + 2}, .1, { type:FlxTween.ONESHOT } );
		FlxTween.num(y, y + 3, .1, { type:FlxTween.ONESHOT, complete:doneBounceBack }, tweenY);
	}
	
	private function doneBounceBack(T:FlxTween):Void
	{
		_hurtTimer = 0;
	}
	
	override public function kill():Void
	{
		if (isDead || !alive || !exists)
			return;
		FlxG.sound.play("sounds/Collapse.wav", .8);
		isDead = true;
		animation.frameIndex = FlxRandom.intRanged(0, 2) * 7;
		allowCollisions = FlxObject.NONE;
		solid = false;
		Reg.playState.createCitySmoke(x, y, this);
		
	}
	
	override private function get_z():Float
	{
		if (!isDead)
			return y + height;
		else
			return y;
	}
	
	
}