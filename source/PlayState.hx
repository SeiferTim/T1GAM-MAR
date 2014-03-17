package;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.util.FlxAsyncLoop;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitterExt;
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
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
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
	private var _boundRect:FlxSprite;
	
	private var _grpHUD:FlxGroup;
	private var _barEnergy:FlxBar;
	
	private var _grpTanks:FlxTypedGroup<Tank>;
	private var _eDistances:Array<Int>;
	private var _grpExplosions:FlxTypedGroup<Explosion>;

	private var _calcTmr:Float;
	
	private var _grpBullets:FlxTypedGroup<Bullet>;
	
	private var _spawnTimer:Float;
	private var _spawnTimerSet:Float;
	private var _bounds:FlxRect;
	
	//private var _gibs:ZEmitterExt;
	
	public var windSpeed(default, null):Float;
	public var windDir(default, null):Float;
	public var _grpWorldWalls:FlxGroup;
	
	private var _txtScore:GameFont;
	private var _allowDraw:Bool = false;
	
	
	
	override public function create():Void
	{
		Reg.playState = this;
		
		FlxG.fixedTimestep = false;
		
		Reg.score = 0;
		
		grpDisplay = new FlxGroup();
		_grpSmokes = new FlxGroup();
		_grpTanks = new FlxTypedGroup<Tank>();
		_grpExplosions = new FlxTypedGroup<Explosion>();
		_grpBullets = new FlxTypedGroup<Bullet>();
		_grpWorldWalls = new FlxGroup(4);
		
		for (i in 0...20)
		{
			_grpTanks.add(new Tank(0, 0));
			_grpTanks.members[_grpTanks.members.length - 1].kill();
			_grpBullets.add(new Bullet());
			_grpBullets.members[_grpBullets.members.length - 1].kill();
		}
		
		for (i in 0...100)
		{
			_grpExplosions.add(new Explosion(0, 0));
			_grpExplosions.members[_grpExplosions.members.length - 1].kill();
		}
		
		m = new GameMap(79, 80);
		add(m.mapTerrain);
		//add(m.cityStreets);
		add(grpDisplay);
		
		var wall:FlxSprite = new FlxSprite(0, 0);
		wall.makeGraphic(48, Std.int(m.mapTerrain.height), FlxColor.BLACK);
		wall.moves = false;
		wall.immovable = true;
		_grpWorldWalls.add(wall);
		wall = new FlxSprite(0, 0);
		wall.makeGraphic(Std.int(m.mapTerrain.width), 48, FlxColor.BLACK);
		wall.moves = false;
		wall.immovable = true;
		_grpWorldWalls.add(wall);
		wall = new FlxSprite(m.mapTerrain.width - 48, 0);
		wall.makeGraphic(48,Std.int(m.mapTerrain.height), FlxColor.BLACK);
		wall.moves = false;
		wall.immovable = true;
		_grpWorldWalls.add(wall);
		wall = new FlxSprite(0, m.mapTerrain.height-48);
		wall.makeGraphic(Std.int(m.mapTerrain.width), 48, FlxColor.BLACK);
		wall.moves = false;
		wall.immovable = true;
		_grpWorldWalls.add(wall);

		_grpHUD = new FlxGroup();
		add(_grpHUD);
		
		
		FlxG.worldBounds.set(-8, -8, m.mapTerrain.width+16, m.mapTerrain.height+16);
		
		_player = new Player();
		
		_barEnergy = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 300, 16, _player, "energy", 0, 100, true);
		_barEnergy.scrollFactor.x = _barEnergy.scrollFactor.y = 0;
		FlxSpriteUtil.screenCenter(_barEnergy, true, false);
		_barEnergy.y = 16;
		_grpHUD.add(_barEnergy);
		
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN);
		FlxG.camera.setBounds(0, 0, m.mapTerrain.width, m.mapTerrain.height);
		
		_sprLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_sprLoad.scrollFactor.x = _sprLoad.scrollFactor.y = 0;
		add(_sprLoad);
		
		_barLoad = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(FlxG.width / 2), 32, m, "loopCounter", 0, m.loopMax, true);
		_barLoad.scrollFactor.x = _barLoad.scrollFactor.y = 0;
		FlxSpriteUtil.screenCenter(_barLoad);
		add(_barLoad);
		
		_boundRect = new FlxSprite( -64,-64).makeGraphic(FlxG.width + 128, FlxG.height + 128, 0x33000000);
		_boundRect.scrollFactor.x = _boundRect.scrollFactor.y = 0;
		_bounds = FlxRect.get( -64, -64, FlxG.width + 128, FlxG.height + 128);
		
		_calcTmr = .33;
		
		_txtScore = new GameFont(16, 16, "0", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD);
		_txtScore.scrollFactor.x = _txtScore.scrollFactor.y  = 0;
		_grpHUD.add(_txtScore);
		
		
		_spawnTimer = _spawnTimerSet = 10;
/*
		_gibs = new ZEmitterExt(0, 0, 50, Reg.EMITTER_EXPLOSION);
		_gibs.particleClass = ZParticle;
		_gibs.setXSpeed( -200, 200);
		_gibs.setYSpeed( -150, 50);
		_gibs.gravity = 350;
		_gibs.bounce = 0.1;
		_gibs.makeParticles(Reg.TANK_GIBS, 200, 20, true, 0.5);*/
		
		windDir = FlxRandom.floatRanged(1, 360);
		windSpeed = FlxRandom.floatRanged(0, 1);
		
		super.create();
	}
	
	
	public function shootBullet(Origin:FlxPoint, Angle:Float):Void
	{
		var b:Bullet = _grpBullets.recycle(Bullet);
		b.launch(Origin, Angle);
	}
	
	private function changeWind():Void
	{
		windDir += FlxRandom.floatRanged( -4, 4) / 24;
		windSpeed += FlxRandom.floatRanged( -4, 4) / 24;
		if (windSpeed < 0)
		{
			windSpeed *= -1;
			windDir = windDir + 180;
		}
		if (windSpeed > 1)
		{
			windSpeed = 1;
		}
		windDir = FlxAngle.wrapAngle(windDir);
		
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		
		super.destroy();
		//_gibs = null;
	}

	override public function draw():Void 
	{
		buildDrawGroup();
		
		
		super.draw();
	}
	
	private function buildDrawGroup():Void
	{
		if (!_allowDraw)
			return;
		
		FlxG.worldBounds.x = FlxG.camera.scroll.x -8;
		FlxG.worldBounds.y = FlxG.camera.scroll.y -8;
		//trace("Cities: " + m.cityTiles.members.length + " Tanks: " + _grpTanks.members.length + " Bullets: " + _grpBullets.members.length);
		grpDisplay.clear();
		grpDisplay.add(_player);
		var c:CityTile;
		for (o in m.cityTiles.members)
		{
			c = cast(o, CityTile);
			c.onScreen = false;
			if (c.alive && c.exists && c.visible)
			{
				if(_boundRect.overlaps(c,true))
				{
					c.onScreen = true;
					grpDisplay.add(c);
				}
			}
		}
		
		var smk:SmokeSpawner;
		for (s in _grpSmokes.members)
		{
			smk = cast(s, SmokeSpawner);				
			if (smk.alive && smk.exists && smk.visible)
			{
				if (_boundRect.overlaps(smk.bounds,true))
				{
					grpDisplay.add(smk);
				}
			}
		}
		var tank:Tank;
		for (t in _grpTanks.members)
		{
			tank = cast t;
			if (tank.alive && tank.exists && tank.visible && _boundRect.overlaps(tank,true))
			{
				tank.onScreen = true;
				grpDisplay.add(tank);
			}
			else
				tank.onScreen = false;
		}
		var exp:Explosion;
		for (e in _grpExplosions.members)
		{
			exp = cast e;
			if (exp.alive && exp.exists && exp.visible && _boundRect.overlaps(exp,true))
			{
				exp.onScreen = true;
				grpDisplay.add(exp);
			}
			else
				exp.onScreen = false;
		}
		var bul:Bullet;
		for (b in _grpBullets.members)
		{
			bul = cast b;
			if (bul.exists && bul.visible)
			{
				if (_boundRect.overlaps(bul, true))
				{
					bul.onScreen = true;
					grpDisplay.add(bul);	
				}
				else
				{
					bul.onScreen = false;
					bul.kill();
				}
			}
		}
		//grpDisplay.add(_gibs);
		
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
							c.kill();
						}
					}
					
					_player.x = sprTest.x + (sprTest.width / 2) - (_player.width / 2) - FlxG.camera.scroll.x;
					_player.y = sprTest.y + (sprTest.height / 2) - (_player.height / 2) - FlxG.camera.scroll.y;
					sprTest.kill();
					
					FlxG.sound.playMusic("game-music", 1, true);
					
					calculateDistances();
					_allowDraw = true;
					var _t:FlxTween = FlxTween.tween(_sprLoad, {alpha:0}, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneLoad } );
				}
				_barLoad.alpha = _sprLoad.alpha;
			}
			
		}
		else
		{
			_player.energy -= FlxG.elapsed*4;
			changeWind();
			checkEnemySpawn();
			FlxG.collide(_player, _grpWorldWalls);
			FlxG.collide(_player, m.cityTiles, playerTouchCityTile);
			
			
			
			//FlxG.collide(_grpTanks, _grpTanks);
			
			//FlxG.overlap(_grpBullets, m.cityTiles, bulletHitCityTile);
			//FlxG.overlap(_player, _grpBullets, bulletHitPlayer);
			//FlxG.overlap(_player, _grpTanks, playerHitTank);
			
			FlxG.overlap(grpDisplay, grpDisplay, checkOverlap);
			
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
	
	private function checkOverlap(A:FlxBasic, B:FlxBasic):Void
	{
		var aName:String = Type.getClassName(Type.getClass(A));
		var bName:String = Type.getClassName(Type.getClass(B));
		
		switch(aName)
		{
			case "Bullet":
				switch(bName)
				{
					case "CityTile":
						bulletHitCityTile(cast A, cast B);
					case "Player":
						bulletHitPlayer(cast B, cast A);
				}
			case "CityTile":
				if (bName == "Bullet")
				{
					bulletHitCityTile(cast B, cast A);
				}
			case "Player":
				switch(bName)
				{
					case "Bullet":
						bulletHitPlayer(cast A, cast B);
					case "Tank":
						playerHitTank(cast A, cast B);
				}
			case "Tank":
				if (bName == "Player")
				{
					playerHitTank(cast B, cast A);
				}
		}
	}
	
	
	private function bulletHitCityTile(B:Bullet, C:CityTile):Void
	{
		if (B.alive && B.exists && !C.isDead)
		{
			C.hurt(1);
			B.kill();
		}
	}
	
	private function bulletHitPlayer(P:Player, B:Bullet):Void
	{
		if (B.alive && B.exists)
		{
			P.energy -= 5;
			B.kill();
		}
	}
	
	private function playerHitTank(P:Player, T:Tank):Void
	{
		if (T.alive && T.exists)
		{
			T.hurt(1);
			if (!T.alive)
			{
				giveScore(5);
			}
		}
	}
	
	private function spawnEnemies():Void
	{
		var eCount:Int =  Std.int((12 - Math.floor(_spawnTimerSet)) * 2);
		
		var t:Tank;
		var side:Int;
		var xPos:Float=0;
		var yPos:Float = 0;
		var locOk:Bool = false;
		var rect:FlxRect;
		
		for (i in 0...eCount)
		{
			if (_grpTanks.countLiving() < 20)
			{
				locOk = false;
				while (!locOk)
				{
					side = FlxRandom.intRanged(0, 3);
					switch (side)
					{
						case 0:
							xPos = FlxRandom.intRanged(Std.int(_bounds.left + FlxG.camera.scroll.x),Std.int( _bounds.bottom + FlxG.camera.scroll.x));
							yPos = _bounds.top + FlxG.camera.scroll.y;
						case 1:
							xPos = FlxRandom.intRanged(Std.int(_bounds.left + FlxG.camera.scroll.x), Std.int(_bounds.bottom + FlxG.camera.scroll.x));
							yPos = _bounds.bottom + FlxG.camera.scroll.y;
						case 2:
							xPos = _bounds.left + FlxG.camera.scroll.x;
							yPos = FlxRandom.intRanged(Std.int(_bounds.top + FlxG.camera.scroll.y), Std.int(_bounds.bottom + FlxG.camera.scroll.y));
						case 3:
							xPos = _bounds.right + FlxG.camera.scroll.x;
							yPos = FlxRandom.intRanged(Std.int(_bounds.top + FlxG.camera.scroll.y), Std.int(_bounds.bottom + FlxG.camera.scroll.y));
					}
					if (xPos < m.mapPathing.x - 28 || xPos > m.mapPathing.x  +m.mapPathing.height || yPos < m.mapPathing.y - 28 || yPos > m.mapPathing.y  +m.mapPathing.width)
						locOk = true;
					else
					{
						rect = FlxRect.get(xPos, yPos, 28, 28);
						rect.left -= (rect.left % 32);
						rect.left /= 32;
						rect.top -= (rect.top % 32);
						rect.top /= 32;
						rect.right -= (rect.right % 32);
						rect.right /= 32;
						rect.bottom -= (rect.bottom % 32);
						rect.bottom /= 32;
						if (m.mapPathing.getTile(Std.int(rect.left), Std.int(rect.top)) + m.mapPathing.getTile(Std.int(rect.left), Std.int(rect.bottom)) + m.mapPathing.getTile(Std.int(rect.right), Std.int(rect.top)) + m.mapPathing.getTile(Std.int(rect.right), Std.int(rect.bottom)) == 0)
						{
							locOk = true;
						}
						rect = FlxDestroyUtil.put(rect);
					}
				}
				
				
				t = _grpTanks.recycle(Tank);
				if (t != null)
				{
					t.init(xPos, yPos);
				}
			}
		}
	}
	
	private function checkEnemySpawn():Void
	{
		_spawnTimer -= FlxG.elapsed;
		if (_spawnTimer <= 0)
		{
			// spawn !
			spawnEnemies();
			
			if (_spawnTimerSet > 0)
			{
				_spawnTimerSet -= FlxG.elapsed;
			}
			else if (_spawnTimerSet < 0)
				_spawnTimerSet = 0;
			
			_spawnTimer = _spawnTimerSet;
			
		}
	}
	
	private function playerTouchCityTile(p:Player, c:CityTile):Void
	{
		if(!c.isDead)
			c.hurt(1);
		if (c.isDead)
		{
			_player.energy += c.tier * 2;
			giveScore(c.tier * 10);
		}
	}
	
	private function giveScore(Value:Int):Void
	{
		Reg.score += Value;
		_txtScore.text = Std.string(Reg.score);
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
		_barLoad = FlxDestroyUtil.destroy(_barLoad);
		_sprLoad = FlxDestroyUtil.destroy(_sprLoad);
		
		
	}
	
	public function createCitySmoke(X:Float, Y:Float, C:CityTile):Void
	{
		_grpSmokes.add(new SmokeSpawner(X, Y, 64, 64));
		m.mapPathing.setTile(Math.floor(X/32)-1, Math.floor(Y/32)-2, 0);
		m.mapPathing.setTile(Math.floor(X/32), Math.floor(Y/32)-2, 0);
		m.mapPathing.setTile(Math.floor(X/32)-1, Math.floor(Y/32)-1, 0);
		m.mapPathing.setTile(Math.floor(X / 32), Math.floor(Y / 32) - 1, 0);
		spawnExplosion(X , X + 64, Y , Y + 64);
	}
	
	public function spawnExplosion(Xmin:Float, Xmax:Float, Ymin:Float, Ymax:Float ):Void
	{
		var e:Explosion;
		
		var xRange:Float = (Xmax - Xmin)/16;
		var yRange:Float = (Ymax - Ymin)/16;
		
		
		for (i in 0...FlxRandom.intRanged(Std.int(xRange*yRange/4), Std.int(xRange*yRange/2)))
		{
			e = cast _grpExplosions.recycle(Explosion);
			if (e != null)
			{
				e.reset(FlxRandom.floatRanged(Xmin, Xmax ), FlxRandom.floatRanged(Ymin, Ymax));
				//_grpExplosions.add(e);
			}
		}
	}
	
	public function createSmallSmoke(X:Float, Y:Float, Width:Float, Height:Float):Void
	{
		_grpSmokes.add(new SmokeSpawner(X, Y, Width, Height));
		spawnExplosion(X - 2, X + Width + 2, Y - 2, Y + Height + 2);
	}
	
	private function enemyMovement():Void
	{
		
		//FlxG.collide(m.mapPathing, _grpTanks);
		var pM:FlxPoint = FlxPoint.get(_player.x + (_player.width / 2), _player.y + _player.height);
		var tank:Tank;
		var tankPos:FlxPoint;
		for (basic in _grpTanks.members)
		{
			tank = cast basic;
			tank.setTarget(pM.x, pM.y);
			
			if (!tank.moving)
			{
				
				tankPos = FlxPoint.get(tank.x + (tank.width / 2), tank.y + (tank.height / 2));
				if (Math.abs(FlxMath.getDistance(tankPos, pM)) >= 64)
				{
					var tx:Int = Std.int((tank.x - tank.offset.x) / 32);
					var ty:Int = Std.int((tank.y - tank.offset.y) / 32);
					
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
							
							
							if (theX >= 0 && theY <	m.mapPathing.widthInTiles)
							{
								if (theY >= 0 && theY < m.mapPathing.heightInTiles)
								{
									if (xx == 0 || yy == 0)
									{
										if (_eDistances != null)
										{
											var distance:Float = _eDistances[theY * m.mapPathing.widthInTiles + theX];
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
				else
				{
					tank.stopMoving();
				}
				tankPos = FlxDestroyUtil.put(tankPos);
			}
			
		}
		//pM.put();
		
		
		pM = FlxDestroyUtil.put(pM);
		
	}
	
	private function calculateDistances():Void
	{
		var pM:FlxPoint = FlxPoint.get(_player.x + (_player.width / 2), _player.y + _player.height);
		pM.x -= (pM.x % 32);
		pM.y -= (pM.y % 32);
		pM.x /= 32;
		pM.y /= 32;
		var startX:Int = Std.int((pM.y * m.mapPathing.widthInTiles)+ pM.x);
		var endX:Int = startX+1;
		
		//pM.put();
		pM = FlxDestroyUtil.put(pM);
		
		var tmpDistances = m.mapPathing.computePathDistance(startX, startX, true, false);
		if (tmpDistances == null)
		{
			//return;
		}
		else
			_eDistances = tmpDistances;
		
		
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
			//v.put();
			v = FlxDestroyUtil.put(v);
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