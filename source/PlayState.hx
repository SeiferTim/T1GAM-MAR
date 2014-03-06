package;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKeyboard;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	
	private var m:GameMap;
	private var s:FlxSprite;
	private var _finished:Bool = false;
	private var _sprLoad:FlxSprite;
	private var _txtLoad:FlxText;
	private var _startedTween:Bool = false;
	private var _grpTiles:FlxGroup;
	
	override public function create():Void
	{
		
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		m = new GameMap(100, 100);
		
		add(m._mapTerrain);
		//add(m._mapPop);
		_grpTiles = new FlxGroup();
		add(_grpTiles);
		
		FlxG.worldBounds.set(0, 0, m._mapTerrain.width, m._mapTerrain.height);
		
		s = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.RED);
		FlxSpriteUtil.screenCenter(s);
		add(s);
		
		FlxG.camera.follow(s);
		
		_sprLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(_sprLoad);
		_txtLoad = new FlxText(0, 0, 100, "Loading...");
		FlxSpriteUtil.screenCenter(_txtLoad);
		add(_txtLoad);
		
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
		
		if (!_finished)
		{
			if (!m.finished)
			{
				m.update();
				_txtLoad.text = "Loading..." + Std.string(m.loopMax - m.loopCounter);
			}
			else
			{
				if (!_startedTween)
				{
					_startedTween = true;
					_grpTiles.add(m.cityTiles);
					var _t:FlxTween = FlxTween.singleVar(_sprLoad, "alpha", 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneLoad } );
				}
				_txtLoad.alpha = _sprLoad.alpha;
			}
			
		}
		else
		{
			#if !FLX_NO_KEYBOARD
			if (FlxG.keys.anyPressed(["RIGHT"]))
			{
				if (s.x <= FlxG.worldBounds.right)
					s.x += 10;
				else
					s.x = FlxG.worldBounds.right;
			}
			else if (FlxG.keys.anyPressed(["LEFT"]))
			{
				if (s.x >= FlxG.worldBounds.x)
					s.x -= 10;
				else
					s.x = FlxG.worldBounds.x;
			}
			if (FlxG.keys.anyPressed(["UP"]))
			{
				if (s.y >= FlxG.worldBounds.y)
					s.y -= 10;
				else
					s.y = FlxG.worldBounds.y;
			}
			else if (FlxG.keys.anyPressed(["DOWN"]))
			{
				if (s.y <= FlxG.worldBounds.bottom)
					s.y += 10;
				else
					s.y = FlxG.worldBounds.bottom;
			}
			#end
			
		}
		super.update();
	}
	
	private function doneLoad(T:FlxTween):Void
	{
		_finished = true;
	}
}