package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	private static inline var ROAR_RECHARGE:Int = 30;
	
	private static inline var SPEED:Int = 200;
	private static inline var FRICTION:Float = .8;
	
	private var _finished:Bool = false;
	private var _startedTween:Bool = false;
	private var _calcTmr:Float;
	private var _spawnTimer:Float;
	private var _spawnTimerSet:Float;
	private var _tankCount:Float;
	private var _copterCount:Float;
	public var windSpeed(default, null):Float;
	public var windDir(default, null):Float;
	private var _allowDraw:Bool = false;
	private var _roarTimer:Float = 0;
	private var _roarsAvailable:Int = 3;
	private var _lastRoar:Float = 1;
	private var _leaving:Bool = false;
	private var _paused:Bool = false;
	private var _sortTimer:Float = 0;
	private var _hudAlpha:Float = 0;
	private var _sillyLoadings:Array<String>;
	private var _whichSilly:Int = 0;
	
	
	public var m:GameMap;
	private var _player:Player;
	public var grpDisplay:ZGroup;
	private var _grpSmokes:FlxTypedGroup<SmokeSpawner>;
	private var _boundRect:FlxSprite;
	private var _grpHUD:FlxGroup;
	private var _barEnergy:FlxBar;
	private var _grpTanks:ZGroup;
	private var _grpCopters:ZGroup;
	private var _eDistances:Array<Int>;
	private var _grpExplosions:ZGroup;
	private var _grpBullets:ZGroup;
	private var _bounds:FlxRect;
	public var _grpWorldWalls:FlxGroup;
	private var _txtScore:GameFont;
	private var _grpPowerups:ZGroup;
	private var _roarMarkers:Array<RoarMarker>;
	private var _sndFoot:FlxSound;
	private var _pauseScreen:PauseGroup;
	public var barLoadLeft:FlxSprite;
	public var barLoadRight:FlxSprite;
	private var _txtSillyLoad:GameFont;
	
	
	private var sprTest:FlxSprite;
	private var _sprLoad:FlxSprite;
	private var _barLoad:FlxBar;
	
	private var _keysHint:FlxSprite;
	private var _spaceHint:SpaceHint;
	
	
	override public function create():Void
	{
		Reg.playState = this;
		
		//FlxG.fixedTimestep = false;
		
		Reg.score = 0;
		
		_sndFoot = FlxG.sound.load("sounds/Foot.wav", 1);
		
		grpDisplay = new ZGroup();
		_grpSmokes = new FlxTypedGroup<SmokeSpawner>();
		_grpTanks = new ZGroup();
		_grpCopters = new ZGroup();
		_grpExplosions = new ZGroup();
		_grpBullets = new ZGroup();
		_grpWorldWalls = new FlxGroup(4);
		_grpPowerups = new ZGroup();
		
		m = new GameMap(82, 82);
		//_trailArea = new FlxTrailArea(0, 0, Std.int(m.mapTerrain.width), Std.int(m.mapTerrain.height), .6, 1, true);
		
		
		for (i in 0...10)
		{
			_grpPowerups.add(new PowerUp());
			_grpPowerups.members[_grpPowerups.members.length -1].kill();
		}
		
		for (i in 0...20)
		{
			_grpTanks.add(new Tank(0, 0));
			_grpTanks.members[_grpTanks.members.length - 1].kill();
			_grpBullets.add(new Bullet());
			//_trailArea.add(_grpBullets.members[_grpBullets.members.length - 1]);
			_grpBullets.members[_grpBullets.members.length - 1].kill();
			
		}
		
		for (i in 0...100)
		{
			_grpExplosions.add(new Explosion(0, 0));
			_grpExplosions.members[_grpExplosions.members.length - 1].kill();
		}
		
		
		add(m.mapTerrain);
		//add(m.cityStreets);
		add(grpDisplay);
		
		//add(_trailArea);
		
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
		_barEnergy.createImageBar("images/energy_bar_empty.png", "images/energy_bar_full.png");
		FlxSpriteUtil.screenCenter(_barEnergy, true, false);
		_barEnergy.y = 16;
		_grpHUD.add(_barEnergy);
		
		_roarMarkers = new Array<RoarMarker>();
		var r:RoarMarker;
		for (i in 0...3)
		{
			r = new RoarMarker(_barEnergy.x + _barEnergy.width + 32 + (24 * i), _barEnergy.height);
			_roarMarkers.push(r);
			_grpHUD.add(r);
		}
		_lastRoar = 1;
		
		
		FlxG.camera.setBounds(0, 0, m.mapTerrain.width, m.mapTerrain.height);
		
		_sprLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_sprLoad.scrollFactor.x = _sprLoad.scrollFactor.y = 0;
		add(_sprLoad);
		
		_sillyLoadings = ["Starting Universe", "Igniting Sun", "Initializing Gravity", "Forming Earth", "Plate Tectonics", "Stirring Primordial Ooze", "Evolving Legs", "Advancing Time", "Discovering Fire", "Building Cities", "Inventing Nail Clippers", "Birthing Science", "Beginning Game"];
		
		
		_barLoad = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 520, 48, m, "loopCounter", 0, m.loopMax, false);
		_barLoad.scrollFactor.x = _barLoad.scrollFactor.y = 0;
		_barLoad.createImageBar("images/big_loader_empty_center.png", "images/big_loader_full_center.png");
		FlxSpriteUtil.screenCenter(_barLoad);
		add(_barLoad);
		
		barLoadLeft  = new FlxSprite(_barLoad.x - 24, _barLoad.y);
		barLoadLeft.loadGraphic("images/big_loader_left.png", true, false, 24, 48);
		barLoadLeft.animation.frameIndex = 0;
		barLoadLeft.scrollFactor.set();
		add(barLoadLeft);
		barLoadRight  = new FlxSprite(_barLoad.x +_barLoad.width, _barLoad.y);
		barLoadRight.loadGraphic("images/big_loader_right.png", true, false, 24, 48);
		barLoadRight.animation.frameIndex = 0;
		barLoadRight.scrollFactor.set();
		add(barLoadRight);
		
		_whichSilly = 0;
		_txtSillyLoad = new GameFont(0, 0, "..."+_sillyLoadings[_whichSilly]+"...", GameFont.STYLE_GLOSSY, GameFont.COLOR_WHITE, "center", 30);
		FlxSpriteUtil.screenCenter(_txtSillyLoad, true, true);
		add(_txtSillyLoad);
		
		_boundRect = new FlxSprite( -64,-64).makeGraphic(FlxG.width + 128, FlxG.height + 128, 0x33000000);
		_boundRect.scrollFactor.x = _boundRect.scrollFactor.y = 0;
		_bounds = FlxRect.get( -64, -64, FlxG.width + 128, FlxG.height + 128);
		
		_calcTmr = .33;
		
		_txtScore = new GameFont(0, 16, "000000000", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right");
		_txtScore.x = FlxG.width - _txtScore.width - 16;
		_txtScore.scrollFactor.x = _txtScore.scrollFactor.y  = 0;
		_grpHUD.add(_txtScore);
		
		
		_spawnTimer = _spawnTimerSet = 12;
		_spawnTimer = 1;
		_tankCount = 2;
		_copterCount = 0;
		
		windDir = FlxRandom.floatRanged(1, 360);
		windSpeed = FlxRandom.floatRanged(0, 1);
		
		
		for (h in 0..._grpHUD.members.length)
		{
			cast(_grpHUD.members[h], FlxSprite).alpha = _hudAlpha;
		}
		
		Reg.score = 0;
		Reg.scores = [0, 0, 0];
		
		_pauseScreen = new PauseGroup();
		add(_pauseScreen);
		
		_paused = false;

		_spaceHint = new SpaceHint();
		_spaceHint.x = (FlxG.width / 2) + 93;
		_spaceHint.y = FlxG.height - _spaceHint.height - 8;
		_spaceHint.scrollFactor.set();
		_spaceHint.alpha = 0;
		_grpHUD.add(_spaceHint);
		
		_keysHint = new FlxSprite(0, 0, "images/keyboard-controls.png");
		_keysHint.x = (FlxG.width/2) - 300;
		_keysHint.y = _spaceHint.y + (_spaceHint.height / 2) - (_keysHint.height / 2);
		_keysHint.scrollFactor.set();
		_keysHint.alpha = 0;
		_grpHUD.add(_keysHint);
		
		super.create();
	}
	
	
	public function shootBullet(Origin:FlxPoint, Angle:Float, Style:Int = 0):Void
	{
		var b:Bullet = cast _grpBullets.recycle(Bullet);
		b.launch(Origin, Angle, Style);
		//_trailArea.add(b);
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
		
		_grpSmokes = FlxDestroyUtil.destroy(_grpSmokes);
		_grpTanks = FlxDestroyUtil.destroy(_grpTanks);
		_grpCopters = FlxDestroyUtil.destroy(_grpCopters);
		_grpExplosions = FlxDestroyUtil.destroy(_grpExplosions);
		_grpBullets = FlxDestroyUtil.destroy(_grpBullets);
		_grpWorldWalls = FlxDestroyUtil.destroy(_grpWorldWalls);
		_grpPowerups = FlxDestroyUtil.destroy(_grpPowerups);
		m.destroy();
		m = null;
		
		super.destroy();
		
		_player = null;
		grpDisplay = null;
		_boundRect = FlxDestroyUtil.destroy(_boundRect);
		_grpHUD = null;
		_barEnergy = null;
		_bounds = FlxDestroyUtil.put(_bounds);
		_txtScore = null;
		_roarMarkers = null;
		_sndFoot = FlxDestroyUtil.destroy(_sndFoot);
		_pauseScreen = null;

	}

	override public function draw():Void 
	{
		buildDrawGroup();

		super.draw();
	}
	
	/*private function getZ(O:Dynamic):Float
	{
		var aName:String = Type.getClassName(Type.getClass(O));
		var zA:Float = 0;
		switch (aName)
		{
			case "ZEmitterExt":
				zA = cast(O, ZEmitterExt).z;
			case "SmokeSpawner":
				zA = cast(O, SmokeSpawner).z;
			default:
				zA = cast(O, DisplaySprite).z;
		}
		return zA;
		
	}*/
	
	private function addSort(O:IFlxZ):Void
	{
		var first:Int = 0;
		var last:Int = grpDisplay.zMembers.length;
		var i:Int = last;
		
		var value:Float = O.z;
		
		while ((i > first) && (value < grpDisplay.zMembers[i - 1].z))
		{
			grpDisplay.zMembers[i] = grpDisplay.zMembers[i - 1];
			i = i - 1;
		}
		grpDisplay.zMembers[i] = O;
		grpDisplay.length++;
	}
	
	private function buildDrawGroup():Void
	{
		if (!_allowDraw)
			return;
		
		FlxG.worldBounds.x = FlxG.camera.scroll.x -8;
		FlxG.worldBounds.y = FlxG.camera.scroll.y -8;
		
		grpDisplay.clear();
		grpDisplay.add(_player, true);
		
		var c:FlxBasic;
		for (i in 0...m.cityTiles.members.length)
		{
			c = m.cityTiles.members[i];
			if (c.alive && c.exists && c.visible)
			{
				if(_boundRect.overlaps(c,true))
				{
					m.cityTiles.zMembers[i].onScreen = true;
					addSort(m.cityTiles.zMembers[i]);
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
					addSort(smk);
				}
			}
		}
		
		for (i in 0..._grpTanks.members.length)
		{
			c = _grpTanks.members[i]; 
			if (c.alive && c.exists && c.visible && _boundRect.overlaps(c,true))
			{
				_grpTanks.zMembers[i].onScreen = true;
			}
			else
			{
				_grpTanks.zMembers[i].onScreen = false;
			}
			addSort(_grpTanks.zMembers[i]);
		}

		for (i in 0..._grpCopters.members.length)
		{
			c = _grpCopters.members[i]; 
			if (c.alive && c.exists && c.visible && _boundRect.overlaps(c,true))
			{
				_grpCopters.zMembers[i].onScreen = true;
			}
			else
			{
				_grpCopters.zMembers[i].onScreen = false;
			}
			addSort(_grpCopters.zMembers[i]);
		}
		
		for (i in 0..._grpExplosions.members.length)
		{
			c = _grpExplosions.members[i]; 
			if (c.alive && c.exists && c.visible && _boundRect.overlaps(c,true))
			{
				_grpExplosions.zMembers[i].onScreen = true;
				addSort(_grpExplosions.zMembers[i]);
			}
			else
				_grpExplosions.zMembers[i].onScreen = false;
		}

		for (i in 0..._grpBullets.members.length)
		{
			c = _grpBullets.members[i]; 
			if (c.exists && c.visible)
			{
				if (_boundRect.overlaps(c, true))
				{
					_grpBullets.zMembers[i].onScreen = false;
					addSort(_grpBullets.zMembers[i]);
				}
				else
				{
					_grpBullets.zMembers[i].onScreen = false;
					c.kill();
				}
			}
		}
		
		for (i in 0..._grpPowerups.members.length)
		{
			c = _grpPowerups.members[i]; 
			if (c.exists && c.visible && c.alive)
			{
				if (_boundRect.overlaps(c, true))
				{
					_grpPowerups.zMembers[i].onScreen = true;
					addSort(_grpPowerups.zMembers[i]);
				}
				else
				{
					_grpPowerups.zMembers[i].onScreen = false;
				}
			}
		}

	}
	
	/*private function quickZSort(arrayInput:Array<FlxBasic>,left:Int, right:Int):Void
	{
		var i:Int = left;
		var j:Int = right;
		var pivotPoint:Float = arrayInput[Math.round((left + right) * .5)].z;
		var temp:Dynamic;
		while (i <= j)
		{
			while (getZ(arrayInput[i]) < pivotPoint)
			{
				i++;
			}
			while (getZ(arrayInput[j]) > pivotPoint)
			{
				j--;
			}
			if (i <= j)
			{
				temp = arrayInput[i];
				arrayInput[i] = arrayInput[j];
				i++;
				arrayInput[j] = temp;
				j--;
			}
		}
		if (left < j)
		{
			quickZSort(arrayInput, left, j);
		}
		if (i < right)
		{
			quickZSort(arrayInput, i, right);
		}
		
	}*/
	
	private function goScoreState():Void
	{
		FlxG.camera.zoom = 1;
		FlxG.switchState(new ScoreState());
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		if (!_finished)
		{
			preGameSetup();
			
		}
		else if (!_leaving)
		{
			if (_paused)
			{
				#if !FLX_NO_KEYBOARD
				if (FlxG.keys.anyJustReleased(["P", "ESCAPE"]))
				{
					_pauseScreen.hide();					
				}
				#end
				if (!_pauseScreen.shown)
				{
					_paused = false;
				}
				_pauseScreen.update();
				return;
			}
			else
			{
			
				
				
				_player.energy -= FlxG.elapsed * 6;
				if (_player.energy <= 0 )
				{
					_leaving = true;						
					FlxG.camera.follow(null);
					FlxG.sound.music.fadeOut(Reg.FADE_DUR*4);
					FlxTween.tween(FlxG.camera, { zoom:4 }, .8, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneGOZoomIn } );
					
				}
				else
				{
					
					#if !FLX_NO_KEYBOARD
					if (FlxG.keys.anyJustReleased(["P", "ESCAPE"]))
					{
						_pauseScreen.show();
						_paused = true;
					}
					#end
					
					changeWind();
					checkEnemySpawn();
					FlxG.collide(_player, _grpWorldWalls);
					FlxG.collide(_player, m.cityTiles, playerTouchCityTile);
					FlxG.overlap(grpDisplay, grpDisplay, checkOverlap);
					
					
					if (_roarsAvailable < 3)
					{
						if (_roarTimer < ROAR_RECHARGE)
						{
							_roarTimer += FlxG.elapsed;
						}
						else
						{
							_roarsAvailable++;
							_roarTimer = 0;
						}
					}
					if (_lastRoar > 0)
						_lastRoar -= FlxG.elapsed;
					
					for (i in 0..._roarsAvailable)
					{
						_roarMarkers[i].available = true;
					}
					for (i in _roarsAvailable...3)
					{
						_roarMarkers[i].available = false;
					}
					
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
			}
			
		}
		else
		{
			FlxG.camera.width = Std.int(FlxG.width / FlxG.camera.zoom);
			FlxG.camera.height = Std.int(FlxG.height / FlxG.camera.zoom);
			FlxG.camera.focusOn(_player.getMidpoint());
		}
		
		super.update();
	}
	
	private function doneGOZoomIn(T:FlxTween):Void
	{
		FlxG.sound.play("sounds/roar.wav");
		
		FlxTween.tween(_player, { alpha:0 }, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneGOFadeOut } );
	}
	
	private function doneGOFadeOut(T:FlxTween):Void
	{
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, false, goScoreState);
	}
	
	private function preGameSetup():Void
	{
		if (!m.finished)
		{
			m.update();
			if (m.loopCounter > ((_whichSilly+1) * m.loopMax / _sillyLoadings.length))
			{
				_whichSilly++;
				_txtSillyLoad.text = "..." + _sillyLoadings[_whichSilly] + "...";
				FlxSpriteUtil.screenCenter(_txtSillyLoad);
			}
		}
		else
		{
			if (!_startedTween)
			{
				_startedTween = true;
				sprTest = new FlxSprite().makeGraphic(96, 96, 0xcc000000);
				
				sprTest.moves = false;
				sprTest.immovable = true;
				sprTest.x = (m.mapTerrain.width / 2) - (sprTest.width / 2);
				sprTest.y = (m.mapTerrain.height / 2) - (sprTest.height / 2);
				sprTest.draw();
				sprTest.update();
				_player.x = sprTest.x + (sprTest.width / 2) - (_player.width / 2) - FlxG.camera.scroll.x;
				_player.y = sprTest.y + (sprTest.height / 2) - (_player.height / 2) - FlxG.camera.scroll.y;
				_allowDraw = true;
				_player.alpha = 0;
				
				FlxTween.tween(_sprLoad, {alpha:0}, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneFadeIn } );
			}
			if (_sprLoad!=null)
				_txtSillyLoad.alpha = barLoadLeft.alpha = barLoadRight.alpha = _barLoad.alpha = _sprLoad.alpha;
			
			FlxG.camera.width = Std.int(FlxG.width / FlxG.camera.zoom);
			FlxG.camera.height = Std.int(FlxG.height / FlxG.camera.zoom);
			FlxG.camera.focusOn(_player.getMidpoint());
			for (h in 0..._grpHUD.members.length)
			{
				cast(_grpHUD.members[h], FlxSprite).alpha = _hudAlpha;
			}
		}
	}
	
	private function doneFadeIn(T:FlxTween):Void
	{
		remove(_barLoad);
		remove(_sprLoad);
		remove(barLoadLeft);
		remove(barLoadRight);
		remove(_txtSillyLoad);
		_barLoad = FlxDestroyUtil.destroy(_barLoad);
		_sprLoad = FlxDestroyUtil.destroy(_sprLoad);
		barLoadLeft = FlxDestroyUtil.destroy(barLoadLeft);
		barLoadRight = FlxDestroyUtil.destroy(barLoadRight);
		_txtSillyLoad = FlxDestroyUtil.destroy(_txtSillyLoad);
		FlxTimer.start(1, doneFirstWait);
		
	}
	
	private function doneFirstWait(T:FlxTimer):Void
	{
		FlxG.camera.flash(0x99ffffff, .2, doneFlashOne);
	}
	
	private function doneZoomIn(T:FlxTween):Void
	{
		
		FlxG.camera.shake(.005, 2);
		FlxG.sound.play("sounds/roar.wav");
		FlxTimer.start(.66, doneStartRoar);
	}
	
	private function doneFlashOne():Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxG.camera.flash(0x99ffffff, .6, doneFlashTwo);
	}
	
	private function doneFlashTwo():Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxTimer.start(.66, doneShortWait);
	}
	
	private function doneShortWait(T:FlxTimer):Void
	{
		FlxTween.tween(FlxG.camera, { zoom:4 }, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circIn, complete:doneZoomIn } );
		
	}
	
	private function doneStartRoar(T:FlxTimer):Void
	{
		for (c in m.cityTiles.members)
		{
			if (sprTest.overlaps(c, true))
			{						
				c.kill();
			}
		}
		sprTest.kill();
		FlxTween.tween(_player, { alpha:1 }, 1, { type:FlxTween.ONESHOT, ease:FlxEase.bounceOut, complete:donePlayerIn } );
	}
	
	private function donePlayerIn(T:FlxTween):Void
	{
		FlxTween.tween(FlxG.camera, { zoom:1 }, 1, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneZoomOut } );
	}
	
	private function doneZoomOut(T:FlxTween):Void
	{
		FlxTween.tween(this, { _hudAlpha:1 }, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneLoad } );
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
						if (cast(A, Bullet).style == Bullet.STANDARD)
						{
							bulletHitCityTile(cast A, cast B);
						}
					case "Player":
						bulletHitPlayer(cast B, cast A);
				}
			case "CityTile":
				if (bName == "Bullet")
				{
					if (cast(B, Bullet).style == Bullet.STANDARD)
					{
						bulletHitCityTile(cast B, cast A);
					}
				}
			case "Player":
				switch(bName)
				{
					case "Bullet":
						bulletHitPlayer(cast A, cast B);
					case "Tank":
						playerHitTank(cast A, cast B);
					case "Copter":
						playerHitCopter(cast A, cast B);
					case "PowerUp":
						playerGetPowerup(cast A, cast B);
				}
			case "Tank":
				if (bName == "Player")
				{
					playerHitTank(cast B, cast A);
				}
			case "Copter":
				if (bName == "Player")
				{
					playerHitCopter(cast B, cast A);
				}
			case "PowerUp":
				if (bName == "Player")
				{
					playerGetPowerup(cast B, cast A);
				}
		}
	}
	
	private function playerGetPowerup(P:Player, O:PowerUp):Void
	{
		if (O.alive && O.exists)
		{
			O.kill();
			_player.energy += 25;
			FlxG.sound.play("sounds/Powerup 1.wav", .8);
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
			
			_player.hurt(5 * (B.style + 1));
			B.kill();
		}
	}
	
	private function playerHitCopter(P:Player, C:Copter):Void
	{
		if (C.alive && C.exists && !C.isDead)
		{
			C.hurt(1);
			if (C.isDead)
			{
				giveScore(8);
				Reg.scores[Reg.SCORE_COPTERS]++;
			}
		}
	}
	
	private function playerHitTank(P:Player, T:Tank):Void
	{
		if (T.alive && T.exists)
		{
			T.hurt(1);
			if (!T.alive)
			{
				giveScore(6);
				Reg.scores[Reg.SCORE_TANKS]++;
			}
		}
	}
	
	private function spawnEnemies():Void
	{
		//var eCount:Int =  Std.int((12 - Math.floor(_spawnTimerSet)) * 2);
		
		var t:Tank;
		var c:Copter;
		var side:Int;
		var xPos:Float=0;
		var yPos:Float = 0;
		var locOk:Bool = false;
		var rect:FlxRect;
		var _coptersSpawned:Int = 0;
		var _tanksSpawned:Int = 0;
		
		var pM:FlxPoint = FlxPoint.get(_player.x + (_player.width / 2), _player.y + (_player.height/2));
		
		
		for (i in 0...Std.int((_copterCount+_tankCount)))
		{
			if (_grpTanks.countLiving() + _grpCopters.countLiving() < 40)
			{
				locOk = false;
				while (!locOk)
				{
					side = FlxRandom.intRanged(0, 3);
					
					switch (side)
					{
						case 0:
							xPos = FlxRandom.intRanged(Std.int(_bounds.left + FlxG.camera.scroll.x+80),Std.int( _bounds.bottom + FlxG.camera.scroll.x-80));
							yPos = _bounds.top + FlxG.camera.scroll.y + 60;
						case 1:
							xPos = FlxRandom.intRanged(Std.int(_bounds.left + FlxG.camera.scroll.x+80), Std.int(_bounds.bottom + FlxG.camera.scroll.x-80));
							yPos = _bounds.bottom + FlxG.camera.scroll.y-60;
						case 2:
							xPos = _bounds.left + FlxG.camera.scroll.x+60;
							yPos = FlxRandom.intRanged(Std.int(_bounds.top + FlxG.camera.scroll.y)+80, Std.int(_bounds.bottom + FlxG.camera.scroll.y-80));
						case 3:
							xPos = _bounds.right + FlxG.camera.scroll.x-60;
							yPos = FlxRandom.intRanged(Std.int(_bounds.top + FlxG.camera.scroll.y+80), Std.int(_bounds.bottom + FlxG.camera.scroll.y-80));
					}
					
					if (_coptersSpawned < _copterCount)
					{
						locOk = true;
					}
					else
					{
					
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
				}
				
				
				if (_coptersSpawned < _copterCount)
				{
					c = cast _grpCopters.recycle(Copter);
					if (c != null)
					{
						c.init(xPos, yPos, pM.x, pM.y - 16);
						_coptersSpawned++;
					}
					
				}
				else if (_tanksSpawned < _tankCount)
				{
				
					t = cast _grpTanks.recycle(Tank);
					if (t != null)
					{
						t.init(xPos, yPos);
						_tanksSpawned++;
					}
					
				}
			}
		}
		pM = FlxDestroyUtil.put(pM);
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
			else if (_spawnTimerSet < 1)
				_spawnTimerSet = 1;
			
			_spawnTimer = _spawnTimerSet;
			_tankCount += 2.02;
			_copterCount += .02;
			
		}
	}
	
	private function playerTouchCityTile(p:Player, c:CityTile):Void
	{
		if(!c.isDead)
			c.hurt(1);
		if (c.isDead)
		{
			_player.energy += c.tier * 2;
			giveScore(c.tier * 22);
			Reg.scores[Reg.SCORE_BUILDINGS]++;
			if (FlxRandom.chanceRoll(2 * c.tier))
			{
				var p:PowerUp = cast _grpPowerups.recycle(PowerUp);
				if (p != null)
				{
					p.reset(c.x + (c.width / 2) - (p.width / 2), c.y + (c.height / 2) - (p.height / 2));
				}
			}
		}
	}
	
	private function giveScore(Value:Int):Void
	{
		Reg.score += Value*12;
		_txtScore.text = StringTools.lpad( Std.string(Reg.score),"0",9);
	}
	
	/*private function zSort(Order:Int, A:FlxBasic, B:FlxBasic):Int
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
	}*/
	
	private function doneLoad(T:FlxTween):Void
	{
		_finished = true;
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN_TIGHT, null, 4);
		FlxG.camera.followLead.x = 2;
		FlxG.camera.followLead.y = 2;
		FlxG.sound.playMusic("game-music", 1, true);
		calculateDistances();
		for (h in 0..._grpHUD.members.length)
		{
			cast(_grpHUD.members[h], FlxSprite).alpha = _hudAlpha;
		}
		FlxTimer.start(5, hideHints);
		
	}
	
	private function hideHints(T:FlxTimer):Void
	{
		FlxTween.tween(_spaceHint, { alpha:0 }, Reg.FADE_DUR * 2, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:destroySpaceHint } );
		FlxTween.tween(_keysHint, { alpha:0 }, Reg.FADE_DUR * 2, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:destroyKeysHint } );
	}
	
	private function destroySpaceHint(T:FlxTween):Void
	{
		_spaceHint = FlxDestroyUtil.destroy(_spaceHint);
	}
	
	private function destroyKeysHint(T:FlxTween):Void
	{
		_keysHint = FlxDestroyUtil.destroy(_keysHint);
	}
	
	private function addSmoke(X:Float, Y:Float, Width:Float, Height:Float):Void
	{
		var s:SmokeSpawner = _grpSmokes.recycle(SmokeSpawner);
		if (s != null)
		{
			s.init(X, Y, Width, Height);
		}
		
		//_grpSmokes.add(new SmokeSpawner(X,Y, Width, Height));
	}
	
	public function createCitySmoke(X:Float, Y:Float, C:CityTile):Void
	{
		addSmoke(X, Y, 64, 64);
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
		var minCount:Int = Std.int(xRange * yRange / 4);
		var maxCount:Int = Std.int(xRange * yRange / 2);
		if (minCount < 1)
			minCount = 1;
		if (maxCount < 2)
			maxCount = 2;
		
		for (i in 0...FlxRandom.intRanged(minCount,maxCount ))
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
		addSmoke(X, Y, Width, Height);
		spawnExplosion(X - 2, X + Width + 2, Y - 2, Y + Height + 2);
	}
	
	private function enemyMovement():Void
	{
		
		var pM:FlxPoint = FlxPoint.get(_player.x + (_player.width / 2), _player.y + (_player.height/2));
		var tank:Tank;
		var ePos:FlxPoint;
		for (basic in _grpTanks.members)
		{
			tank = cast basic;
			
			if (tank.alive && tank.exists && tank.visible)
			{

				tank.setTarget(pM.x, pM.y);
				
				if (!tank.moving)
				{
					
					ePos = FlxPoint.get(tank.x + (tank.width / 2), tank.y + (tank.height / 2));
					if (Math.abs(FlxMath.getDistance(ePos, pM)) >= 48)
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
					ePos = FlxDestroyUtil.put(ePos);
				}
			}
			
		}
		
		var copter:Copter;
		for (basic in _grpCopters.members)
		{
			copter = cast basic;
			
			if (copter.alive && copter.exists && copter.visible && !copter.isDead)
			{
				copter.setTarget(pM.x, pM.y-16);
			}
		}
		
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
		
		pM = FlxDestroyUtil.put(pM);
		
		var tmpDistances = m.mapPathing.computePathDistance(startX, startX, true, false);
		if (tmpDistances != null)
			_eDistances = tmpDistances;
		
		
	}
	
	private function playerMovement():Void
	{
		var _pressingUp:Bool = false;
		var _pressingDown:Bool = false;
		var _pressingLeft:Bool = false;
		var _pressingRight:Bool = false;
		var _pressingShoot:Bool = false;
		
		#if (!FLX_NO_KEYBOARD)
		_pressingUp = FlxG.keys.anyPressed(["W", "UP"]);
		_pressingDown = FlxG.keys.anyPressed(["S", "DOWN"]);
		_pressingLeft = FlxG.keys.anyPressed(["A", "LEFT"]);
		_pressingRight = FlxG.keys.anyPressed(["D", "RIGHT"]);
		if (_pressingDown && _pressingUp)
			_pressingDown = _pressingUp = false;
		if (_pressingLeft && _pressingRight)
			_pressingLeft = _pressingRight = false;
			
		_pressingShoot = FlxG.keys.anyPressed(["SPACE", "X"]);
		#end
		
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
			var v:FlxPoint;
			if (_player.overlaps(m.mapWater))
			{
				
				v = FlxAngle.rotatePoint(SPEED*.4, 0, 0, 0, mA);
			}
			else
			{
				v = FlxAngle.rotatePoint(SPEED, 0, 0, 0, mA);
			}
				
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
		
		if (_pressingDown || _pressingLeft || _pressingRight || _pressingUp)
		{
			if (!_sndFoot.playing)
				_sndFoot.play();
		}
				
		if (_pressingShoot)
		{
			if (_roarsAvailable > 0)
			{
				if (_lastRoar <= 0)
				{
					_roarsAvailable--;
					_lastRoar = 4;
					FlxG.sound.play("sounds/roar.wav", .9);
					FlxG.camera.shake(.005, 2);
					var c:Copter;
					for (cop in _grpCopters.members)
					{
						c = cast cop;
						if (c.onScreen && c.alive && c.exists && !c.isDead)
						{
							giveScore(8);
							Reg.scores[Reg.SCORE_COPTERS]++;
							c.kill();
						}
					}
					var t:Tank;
					for (tan in _grpTanks.members)
					{
						t = cast tan;
						if (t.onScreen && t.alive && t.exists)
						{
							giveScore(6);
							Reg.scores[Reg.SCORE_TANKS]++;
							t.kill();
						}
					}
					var b:Bullet;
					for (bul in _grpBullets.members)
					{
						b = cast bul;
						if (b.onScreen && b.alive && b.exists)
						{
							b.kill();
						}
					}
				}
			}
		}
	}
	
	
}
