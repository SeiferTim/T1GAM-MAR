package;

import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKeyboard;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	
	var m:GameMap;
	override public function create():Void
	{
		
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		m = new GameMap(500, 500);
		
		add(m._mapTerrain);
		add(m._mapPop);
		
		super.create();
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
		
		if (FlxG.keys.anyPressed(["RIGHT"]))
		{
			if (m._mapTerrain.x > FlxG.width - m._mapTerrain.width)
				m._mapTerrain.x -= 20;
			else 
				m._mapTerrain.x = FlxG.width - m._mapTerrain.width;
		}
		else if (FlxG.keys.anyPressed(["LEFT"]))
		{
			if (m._mapTerrain.x < 0)
				m._mapTerrain.x += 20;
			else
				m._mapTerrain.x = 0;
		}
		if (FlxG.keys.anyPressed(["UP"]))
		{
			if (m._mapTerrain.y < 0)
				m._mapTerrain.y += 20;
			else
				m._mapTerrain.y = 0;
		}
		else if (FlxG.keys.anyPressed(["DOWN"]))
		{
			if (m._mapTerrain.y > FlxG.height - m._mapTerrain.height)
				m._mapTerrain.y -= 20;
			else 
				m._mapTerrain.y = FlxG.height - m._mapTerrain.height;
		}
		
		m._mapPop.x = m._mapTerrain.x;
		m._mapPop.y = m._mapTerrain.y;
		
		super.update();
	}	
}