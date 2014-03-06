package ;
import flixel.FlxG;
import flixel.tweens.FlxTween;

class CityTile extends DisplaySprite
{

	public var tier(default, null):Int;
	private var _onScreen:Bool;
	private var _hurtTimer:Float = 0;
	
	public function new(X:Float=0, Y:Float=0, Tier:Int = 1) 
	{
		super(X, Y);
		tier = Tier;
		health = tier;
		loadGraphic("images/city-tiles.png", true, false, 64, 128);
		width = 64;
		height = 64;
		offset.y = 64;
		animation.frameIndex = tier;
		moves = false;
		immovable = true;
	}
	
	override public function update():Void 
	{
		//_onScreen = isOnScreen();
		if (_hurtTimer > 0)
			_hurtTimer -= FlxG.elapsed;
		if (!_onScreen)
			return;
		super.update();
	}
	
	override public function draw():Void
	{
		_onScreen = isOnScreen();
		if (!_onScreen)
			return;
		super.draw();
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (_hurtTimer > 0)
			return;
		_hurtTimer = .2;
		var _t:FlxTween = FlxTween.singleVar(this, "y", y-2, .1, { type:FlxTween.ONESHOT, complete:doneBounceUp } );
		super.hurt(Damage);
	}
	
	private function doneBounceUp(T:FlxTween):Void
	{
		var _t:FlxTween = FlxTween.singleVar(this, "y", y+2, .1, { type:FlxTween.ONESHOT } );
	}
	
}