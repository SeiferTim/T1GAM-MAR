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
	
	override public function update():Void 
	{
		
		switch(facing)
		{
			case FlxObject.LEFT:
				width = 44;
				height = 24;
				offset.x = 4;
				offset.y = 7;
			case FlxObject.RIGHT:
				width = 44;
				height = 24;
				offset.x = 16;
				offset.y = 7;
			case FlxObject.DOWN:
				width = 22;
				height = 40;
				offset.x = 18;
				offset.y = 20;
			case FlxObject.UP:
				width = 22;
				height = 40;
				offset.x = 22;
				offset.y = 4;
		}
		
		super.update();
	}
	
}