package;

import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		var t:GameFont = new GameFont(0, 16, "Dinosaur-Ghost", GameFont.STYLE_HUGE_TITLE, GameFont.COLOR_CYAN);
		FlxSpriteUtil.screenCenter(t, true, false);
		add(t);
		
		var t2:GameFont = new GameFont(0, t.y+t.height-8,  "RAMPAGE", GameFont.STYLE_BIG_TITLE, GameFont.COLOR_RED);
		FlxSpriteUtil.screenCenter(t2, true, false);
		add(t2);
		
		
		var b:FlxButton = new FlxButton(0, 0, "Play", goPlay);
		b.y = FlxG.height - b.width - 16;
		FlxSpriteUtil.screenCenter(b, true, false);
		add(b);
		
		super.create();
	}
	
	private function goPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}