package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class CityTile extends DisplaySprite
{

	public var tier(default, null):Int;
	private var _onScreen:Bool;
	private var _hurtTimer:Float = 0;
	public var isDead(default, null):Bool;
	//private var _grpSmoke:FlxGroup;
	//private var _tmrSmoke:FlxTimer;
	
	public function new(X:Float=0, Y:Float=0, Tier:Int = 1) 
	{
		super(X, Y);
		tier = Tier;
		health = tier;
		loadGraphic("images/city-tiles.png", true, false, 64, 128);
		width = 66;
		height = 66;
		offset.y = 63;
		offset.x = -1;
		animation.frameIndex = tier;
		moves = false;
		immovable = true;
		allowCollisions = FlxObject.ANY;
		//_grpSmoke = new FlxGroup(20);
		
		
	}
	
	override public function update():Void 
	{
		if (_hurtTimer > 0)
			_hurtTimer -= FlxG.elapsed;
		//super.update();
	}
	
	/*override public function draw():Void
	{
		super.draw();
	}*/
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0 || isDead)
			return;
		_hurtTimer = .2;
		
		super.hurt(Damage);
		if (!isDead)
			var _t:FlxTween = FlxTween.tween(this, {y: y - 2}, .1, { type:FlxTween.ONESHOT, complete:doneBounceUp } );
		
	}
	
	private function doneBounceUp(T:FlxTween):Void
	{
		var _t:FlxTween = FlxTween.tween(this, {y: y + 2}, .1, { type:FlxTween.ONESHOT } );
	}
	
	override public function kill():Void
	{
		isDead = true;
		animation.frameIndex = 0;
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
	override public function destroy():Void 
	{
		
		super.destroy();
	}
	
	
}