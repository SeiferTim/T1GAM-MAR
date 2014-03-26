package ;

import flixel.FlxSprite;

class SpaceHint extends FlxSprite
{

	public function new() 
	{
		super(0, 0);
		loadGraphic("images/space-hint.png", true, false, 210, 66);
		animation.add("standard", [0, 1, 2, 3, 4], 10);
		animation.play("standard");
		
	}
	
}