package ;
import flixel.FlxObject;

class Player extends DisplaySprite
{

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/player.png", true, true, 64, 64);
		animation.add("lr", [0], 1);
		animation.add("d", [1], 1);
		animation.add("u", [2], 1);
		animation.play("lr");
		height = 32;
		width = 64;
		facing = FlxObject.RIGHT;
		
	}
	
}