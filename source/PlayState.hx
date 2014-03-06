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
import flixel.ui.FlxButton;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
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
	private var _txtLoad:FlxText;
	private var _startedTween:Bool = false;
	public var grpDisplay:FlxGroup;
	
	
	
	override public function create():Void
	{
		
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		grpDisplay = new FlxGroup();
		
		m = new GameMap(100, 100, this);
		add(m._mapTerrain);
		add(grpDisplay);
		
		FlxG.worldBounds.set(0, 0, m._mapTerrain.width, m._mapTerrain.height);
		
		_player = new Player();
		
		
		//grpDisplay.add(_player);
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN);
		FlxG.camera.setBounds(FlxG.worldBounds.x, FlxG.worldBounds.y, FlxG.worldBounds.width, FlxG.worldBounds.height);
		
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
			if (o.alive && o.exists && o.visible && cast(o,CityTile).isOnScreen())
				grpDisplay.add(o);
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
				_txtLoad.text = "Loading..." + Std.string(m.loopMax - m.loopCounter);
			}
			else
			{
				if (!_startedTween)
				{
					_startedTween = true;
					grpDisplay.sort(zSort, FlxSort.ASCENDING);
					
					var sprTest:FlxSprite = new FlxSprite().makeGraphic(96, 96, FlxColor.BLACK);
					sprTest.x = (m._mapTerrain.width / 2) - (sprTest.width / 2);
					sprTest.y = (m._mapTerrain.height / 2) - (sprTest.height / 2);
					sprTest.moves = false;
					sprTest.immovable = true;
					//add(sprTest);
					
					
					FlxG.collide(sprTest, m.cityTiles, initialSetupCollision);
					sprTest.kill();
					_player.x = (m._mapTerrain.width / 2) - (_player.width / 2);
					_player.y = (m._mapTerrain.height / 2) - (_player.height / 2);
					
					var _t:FlxTween = FlxTween.singleVar(_sprLoad, "alpha", 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneLoad } );
				}
				_txtLoad.alpha = _sprLoad.alpha;
			}
			
		}
		else
		{
			playerMovement();
			FlxG.collide(_player, grpDisplay, playerTouchCityTile);
			
		}
		
		
		
		
		super.update();
	}
	
	private function initialSetupCollision(p:FlxSprite, c:CityTile):Void
	{
		c.kill();
	}
	
	private function playerTouchCityTile(p:Player, c:CityTile):Void
	{
		c.hurt(1);
	}
	
	private function zSort(Order:Int, A:FlxBasic, B:FlxBasic):Int
	{
		var result:Int = 0;
		
		var zA:Float = Type.getClassName(Type.getClass(A)) == "ZEmitterExt" ? cast(A, ZEmitterExt).z : cast(A, DisplaySprite).z;
		var zB:Float = Type.getClassName(Type.getClass(B)) == "ZEmitterExt" ? cast(B, ZEmitterExt).z : cast(B, DisplaySprite).z;
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