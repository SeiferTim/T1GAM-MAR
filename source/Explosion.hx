package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxCollisionType;
import flixel.util.FlxRandom;

class Explosion extends DisplaySprite
{
	private var _sounded:Bool = false;
	private var _chanceSound:Int = 1;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/explosion.png", true, false, 64, 64);
		animation.add("explode", [0, 1, 2, 3], 16, false);
		collisionType = FlxCollisionType.NONE;
		moves = false;
		immovable = true;
		allowCollisions  = FlxObject.NONE;
		solid = false;
		calcOnScreen = false;
		
		
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X-(width/2), Y-(height/2));
		animation.play("explode", true);
		_sounded = false;
		_chanceSound = 1;
		
	}
	
	override public function update():Void 
	{
		if (animation.finished || !onScreen)
			kill();
		if (!onScreen || !alive || !exists || !visible)
			return;
		if (!_sounded)
		{
			if (FlxRandom.chanceRoll(_chanceSound))
			{
				FlxG.sound.play("sounds/Blast.wav", FlxRandom.floatRanged(.4, .66));
			}
			else
				_chanceSound++;
		}
		super.update();
	}
	
	override private function get_z():Float 
	{
		return y + (height/2) + 64;
	}
	
	
}