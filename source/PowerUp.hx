package ;
import flixel.util.FlxColor;

class PowerUp extends DisplaySprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		makeGraphic(32, 32, FlxColor.AQUAMARINE);
	}
	
}