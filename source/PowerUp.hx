package ;
import flixel.util.FlxColor;

class PowerUp extends DisplaySprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		//makeGraphic(32, 32, FlxColor.AQUAMARINE);
		loadGraphic("images/powerup.png", true, false, 64, 64);
		animation.add("play", [2, 1, 0, 1], 12);
		calcOnScreen = false;
		animation.play("play");
	}
	
}