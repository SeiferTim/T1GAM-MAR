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
import flixel.group.FlxTypedGroup.FlxTypedGroup;
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
	
	private var _grpTanks:FlxTypedGroup<Tank>;
	private var _eDistances:Array<Int>;
	
	private var _calcTmr:Float;
	
	public var distmap:FlxTilemap;
	
	
	private var _tank:Tank;
	
	override public function create():Void
	{
		Reg.playState = this;
		
		FlxG.fixedTimestep = false;
		
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true));
		
		grpDisplay = new FlxGroup();
		_grpSmokes = new FlxGroup();
		_grpTanks = new FlxTypedGroup<Tank>();
		
		m = new GameMap(80, 80);
		add(m.mapTerrain);
		add(m.cityStreets);
		add(grpDisplay);
		_grpHUD = new FlxGroup();
		add(_grpHUD);
		
		FlxG.worldBounds.set(0, 0, m.mapTerrain.width, m.mapTerrain.height);
		
		_player = new Player();
		
		_barEnergy = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 300, 16, _player, "energy", 0, 100, true);
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN);
		FlxG.camera.setBounds(FlxG.worldBounds.x, FlxG.worldBounds.y, FlxG.worldBounds.width, FlxG.worldBounds.height);
		
		_sprLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_sprLoad.scrollFactor.x = _sprLoad.scrollFactor.y = 0;
		add(_sprLoad);
		
		_barLoad = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(FlxG.width / 2), 32, m, "loopCounter", 0, m.loopMax, true);
		_barLoad.scrollFactor.x = _barLoad.scrollFactor.y = 0;
		FlxSpriteUtil.screenCenter(_barLoad);
		add(_barLoad);
		
		_smokeRect = new FlxSprite( -16, -16).makeGraphic(FlxG.width + 16 +  48, FlxG.height + 16 + 48, 0x33000000);
		_smokeRect.scrollFactor.x = _smokeRect.scrollFactor.y = 0;
		
		_calcTmr = .33;
		
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
		//var added:Bool = false;
		for (s in _grpSmokes.members)
		{
			//added = false;
			smk = cast(s, SmokeSpawner);				
			if (smk.alive && smk.exists && smk.visible)
			{
				if (_smokeRect.overlaps(smk.parent,true))
				{
					//added = true;
					grpDisplay.add(smk);
				}
			}
		}
		for (t in _grpTanks.members)
		{
			if (t.alive && t.exists && t.visible)
			{
				if (cast(t, Tank).isOnScreen())
					grpDisplay.add(t);
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
					sprTest.x = (m.mapTerrain.width / 2) - (sprTest.width / 2);
					sprTest.y = (m.mapTerrain.height / 2) - (sprTest.height / 2);
					add(sprTest);
					sprTest.draw();
					sprTest.update();
					
					for (c in m.cityTiles.members)
					{
						if (sprTest.overlaps(c, true))
						{
							//c.destroy();							
							c.kill();
						}
					}
					
					_player.x = sprTest.x + (sprTest.width / 2) - (_player.width / 2) - FlxG.camera.scroll.x;
					_player.y = sprTest.y + (sprTest.height / 2) - (_player.height / 2) - FlxG.camera.scroll.y;
					sprTest.kill();
					
					//add(m.mapPathing);
					
					_tank = new Tank(_player.x + 128, _player.y + 128);
					FlxG.watch.add(_tank, "x");
					FlxG.watch.add(_tank, "y");
					_grpTanks.add(_tank);
					
					
					
					distmap = new FlxTilemap();
					distmap.scale.set(32, 32);
					var tw:Int = m.mapPathing.widthInTiles;
					var th:Int = m.mapPathing.heightInTiles;
					var arr:Array<Int> = [];
					var arr2:Array<Int> = [];
					for (ww in 0...tw)
					{
						for (hh in 0...th)
						{
							arr.push(0);
							arr2.push(0);
						}
					}
					
					distmap.widthInTiles = tw;
					distmap.heightInTiles = th;
					
					distmap.loadMap(arr2, "images/heat-opaque.png", 1, 1);
					//
					
					add(m.mapPathing);
					add(distmap);
					calculateDistances();
					var _t:FlxTween = FlxTween.tween(_sprLoad, {alpha:0}, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneLoad } );
				}
				_barLoad.alpha = _sprLoad.alpha;
			}
			
		}
		else
		{
			
			FlxG.collide(_player, m.cityTiles, playerTouchCityTile);
			playerMovement();
			if (_calcTmr > 0)
			{
				_calcTmr -= FlxG.elapsed;
			}
			else
			{
				_calcTmr = .33;
				calculateDistances();
			}
			enemyMovement();
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
		m.mapPathing.setTile(Math.floor(X/32)-1, Math.floor(Y/32)-2, 0);
		m.mapPathing.setTile(Math.floor(X/32), Math.floor(Y/32)-2, 0);
		m.mapPathing.setTile(Math.floor(X/32)-1, Math.floor(Y/32)-1, 0);
		m.mapPathing.setTile(Math.floor(X/32), Math.floor(Y/32)-1, 0);
		
		
	}
	
	private function enemyMovement():Void
	{
		
		//FlxG.collide(m.mapPathing, _grpTanks);
		
		var tank:Tank;
		for (basic in _grpTanks.members)
		{
			tank = cast basic;
			
			if (!tank.moving)
			{
				var tx:Int = Std.int((tank.x - tank.offset.x) / 32);
				var ty:Int = Std.int((tank.y - tank.offset.y) / 32);
				//trace(tx + ", " + ty);
				var bestX:Int = 0;
				var bestY:Int = 0;
				var bestDist:Float = Math.POSITIVE_INFINITY;
				var neighbors:Array<Array<Float>> = [[999, 999, 999], [999, 999, 999], [999, 999, 999]];
				for (yy in -1...2)
				{
					for (xx in -1...2)
					{
						var theX:Int = tx + xx;
						var theY:Int = ty + yy;
						
						
						if (theX >= 0 && theY < distmap.widthInTiles)
						{
							if (theY >= 0 && theY < distmap.heightInTiles)
							{
								if (xx == 0 || yy == 0)
								{
									if (_eDistances != null)
									{
										var distance:Float = _eDistances[theY * distmap.widthInTiles + theX];
										neighbors[yy + 1][xx + 1] = distance;
										if (distance > 0)
										{
											if (distance < bestDist || (bestX == 0 && bestY == 0))
											{
												bestDist = distance;
												bestX = xx;
												bestY = yy;
											}
										}
									}
								}
							}
						}
					}
				}
				
				if (!(bestX == 0 && bestY == 0))
				{
					tank.moveTo((tx * 32) + (bestX * 32) + tank.offset.x, (ty * 32) + (bestY * 32) + tank.offset.y, Tank.SPEED);
				}
			}
			
		}
	}
	
	private function calculateDistances():Void
	{
		var pM:FlxPoint = FlxPoint.get(Math.floor(_player.x + (_player.width / 2)), Math.floor(_player.y + _player.height));
		var startX:Int = Std.int(((pM.y/32) * m.mapPathing.widthInTiles) + (pM.x/32));
		var endX:Int = 0;
		if (startX == endX)
			endX = 1;
		//trace(startX + " " + (m.mapPathing.widthInTiles * m.mapPathing.heightInTiles));
		var tmpDistances = m.mapPathing.computePathDistance(startX, endX, true, false);
		if (tmpDistances == null)
			return;
		else
			_eDistances = tmpDistances;
			
		// turn off when no heatmap
		var maxDistance:Int = 1;
		for (dist in _eDistances) 
		{
			if (dist > maxDistance)
				maxDistance = dist;
		}

		for (i in 0..._eDistances.length) 
		{
			var disti:Int = 0;
			if (_eDistances[i] < 0) 
				disti = 1000;
			else
				disti = Std.int(999 * (_eDistances[i] / maxDistance));

			distmap.setTileByIndex(i, disti, true);
		}
		//
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