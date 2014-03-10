package;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKeyboard;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	
	 private static inline var SPEED:Int = 200;
	private static inline var FRICTION:Float = .8;
	
	private var m:GameMap;
	private var _player:Player;
	private var _finished:Bool = false;
	private var _sprLoad:FlxSprite;
	
	private var _barLoad:FlxBar;
	private var _startedTween:Bool = false;
	public var grpDisplay:FlxGroup;
	private var _grpSmokes:FlxGroup;
	private var _smokeRect:FlxSprite;
	
	private var _grpHUD:FlxGroup;
	private var _barEnergy:FlxBar;
	
	
	
	override public function create():Void
	{
		Reg.playState = this;
		
		FlxG.fixedTimestep = false;
		
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		grpDisplay = new FlxGroup();
		_grpSmokes = new FlxGroup();
		
		m = new GameMap(80, 80, this);
		add(m._mapTerrain);
		add(m.cityStreets);
		add(grpDisplay);
		_grpHUD = new FlxGroup();
		add(_grpHUD);
		
		
		FlxG.worldBounds.set(0, 0, m._mapTerrain.width, m._mapTerrain.height);
		
		_player = new Player();
		
		_barEnergy = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 300, 16, _player, "energy", 0, 100, true);
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN);
		FlxG.camera.setBounds(FlxG.worldBounds.x, FlxG.worldBounds.y, FlxG.worldBounds.width, FlxG.worldBounds.height);
		
		_sprLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_sprLoad.scrollFactor.x = _sprLoad.scrollFactor.y = 0;
		add(_sprLoad);
		
		//_txtLoad = new FlxText(0, 0, 100, "Loading...");
		//FlxSpriteUtil.screenCenter(_txtLoad);
		//add(_txtLoad);
		
		_barLoad = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(FlxG.width / 2), 32, m, "loopCounter", 0, m.loopMax, true);
		_barLoad.scrollFactor.x = _barLoad.scrollFactor.y = 0;
		FlxSpriteUtil.screenCenter(_barLoad);
		add(_barLoad);
		
		_smokeRect = new FlxSprite( -16, -16).makeGraphic(FlxG.width + 16 +  48, FlxG.height + 16 + 48, 0x33000000);
		_smokeRect.scrollFactor.x = _smokeRect.scrollFactor.y = 0;
		
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

	override public function draw():Void 
	{
		buildDrawGroup();
		
		
		super.draw();
	}
	
	private function buildDrawGroup():Void
	{
		grpDisplay.clear();
		grpDisplay.add(_player);
		for (o in m.cityTiles.members)
		{
			if (o.alive && o.exists && o.visible)
			{
				if (cast(o,CityTile).isOnScreen())
					grpDisplay.add(o);
			}
		}
		var smk:SmokeSpawner;
		var added:Bool = false;
		for (s in _grpSmokes.members)
		{
			added = false;
			smk = cast(s, SmokeSpawner);				
			if (smk.alive && smk.exists && smk.visible)
			{
				if (_smokeRect.overlaps(smk.parent,true))
				{
					added = true;
					grpDisplay.add(smk);
				}
			}
		}
		grpDisplay.sort(zSort, FlxSort.ASCENDING);
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
				//_txtLoad.text = "Loading..." + Std.string(m.loopMax - m.loopCounter);
			}
			else
			{
				if (!_startedTween)
				{
					_startedTween = true;
					grpDisplay.sort(zSort, FlxSort.ASCENDING);
					
					var sprTest:FlxSprite = new FlxSprite().makeGraphic(96, 96, FlxColor.BLACK);
					
					sprTest.moves = false;
					sprTest.immovable = true;
					sprTest.scrollFactor.x = sprTest.scrollFactor.y = 0;
					sprTest.x = (m._mapTerrain.width / 2) - (sprTest.width / 2);
					sprTest.y = (m._mapTerrain.height / 2) - (sprTest.height / 2);
					add(sprTest);
					sprTest.draw();
					sprTest.update();
					
					for (c in m.cityTiles.members)
					{
						if (sprTest.overlaps(c, true))
						{
							c.destroy();							
						}
					}
					
					_player.x = sprTest.x + (sprTest.width / 2) - (_player.width / 2) - FlxG.camera.scroll.x;
					_player.y = sprTest.y + (sprTest.height / 2) - (_player.height / 2) - FlxG.camera.scroll.y;
					sprTest.kill();
					
					var _t:FlxTween = FlxTween.singleVar(_sprLoad, "alpha", 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneLoad } );
				}
				_barLoad.alpha = _sprLoad.alpha;
			}
			
		}
		else
		{
			playerMovement();
			FlxG.collide(_player, grpDisplay, playerTouchCityTile);
			
		}
		
		super.update();
	}
	
	private function playerTouchCityTile(p:Player, c:CityTile):Void
	{
		if(!c.isDead)
			c.hurt(1);	
	}
	
	private function zSort(Order:Int, A:FlxBasic, B:FlxBasic):Int
	{
		var result:Int = 0;
		var aName:String = Type.getClassName(Type.getClass(A));
		var bName:String = Type.getClassName(Type.getClass(B));
		var zA:Float = 0;
		var zB:Float = 0;
		
		switch (aName)
		{
			case "ZEmitterExt":
				zA = cast(A, ZEmitterExt).z;
			case "SmokeSpawner":
				zA = cast(A, SmokeSpawner).z;
			default:
				zA = cast(A, DisplaySprite).z;
		}
		switch (bName)
		{
			case "ZEmitterExt":
				zB = cast(B, ZEmitterExt).z;
			case "SmokeSpawner":
				zB = cast(B, SmokeSpawner).z;
			default:
				zB = cast(B, DisplaySprite).z;
		}
		
		if (zA < zB)
			result = Order;
		else if (zA > zB)
			result = -Order;
		return result;
	}
	
	private function doneLoad(T:FlxTween):Void
	{
		_finished = true;
	}
	
	public function createSmoke(X:Float, Y:Float, C:CityTile):Void
	{
		_grpSmokes.add(new SmokeSpawner(X, Y, C));
		
	}
	
	private function playerMovement():Void
	{
		#if (!FLX_NO_KEYBOARD)
		var _pressingUp:Bool = false;
		var _pressingDown:Bool = false;
		var _pressingLeft:Bool = false;
		var _pressingRight:Bool = false;
		_pressingUp = FlxG.keys.anyPressed(["W", "UP"]);
		_pressingDown = FlxG.keys.anyPressed(["S", "DOWN"]);
		_pressingLeft = FlxG.keys.anyPressed(["A", "LEFT"]);
		_pressingRight = FlxG.keys.anyPressed(["D", "RIGHT"]);
		if (_pressingDown && _pressingUp)
			_pressingDown = _pressingUp = false;
		if (_pressingLeft && _pressingRight)
			_pressingLeft = _pressingRight = false;
			
		var mA:Float = -400;
		if (_pressingUp)
		{
			if (_pressingLeft)
				mA = -135;
			else if (_pressingRight)
				mA = -45;
			else 
				mA = -90;
		}
		else if (_pressingDown)
		{
			if (_pressingLeft)
				mA = 135;
			else if (_pressingRight)
				mA = 45;
			else
				mA = 90;
		}
		else if (_pressingLeft)
			mA = -180;
		else if (_pressingRight)
			mA = 0;
		if (mA != -400)
		{
			
			var v:FlxPoint = FlxAngle.rotatePoint(SPEED, 0, 0, 0, mA);
			_player.velocity.x = v.x;
			_player.velocity.y = v.y;
			
			if (_player.velocity.x > 0 && Math.abs(_player.velocity.x) > Math.abs(_player.velocity.y))
			{
				_player.facing = FlxObject.RIGHT;
				_player.animation.play("lr");
			}
			else if (_player.velocity.x < 0 && Math.abs(_player.velocity.x) > Math.abs(_player.velocity.y))
			{
				_player.facing = FlxObject.LEFT;
				_player.animation.play("lr");
			}
			else if (_player.velocity.y > 0)
			{
				_player.facing = FlxObject.DOWN;
				_player.animation.play("d");
			}
			else if (_player.velocity.y < 0)
			{
				_player.facing = FlxObject.UP;
				_player.animation.play("u");
			}
		}
		
		if (!_pressingDown && !_pressingUp)
			if (Math.abs(_player.velocity.y) > 1)
				_player.velocity.y *= FRICTION;
		if (!_pressingLeft && !_pressingRight)
			if (Math.abs(_player.velocity.x) > 1)
				_player.velocity.x *= FRICTION;
		#end
	}
}