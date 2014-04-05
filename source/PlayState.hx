package;

import flash.geom.Rectangle;
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
	//private var _hudAlpha:Float = 0;
	private var _sillyLoadings:Array<String>;
	private var _whichSilly:Int = 0;
	private var _hasFocus:Bool = true;
	
	
	public var m:GameMap;
	private var _player:Player;
	public var grpDisplay:ZGroup<Dynamic>;
	private var _grpSmokes:FlxTypedGroup<SmokeSpawner>;
	private var _boundRect:FlxSprite;
	private var _grpHUD:FlxTypedGroup<Dynamic>;
	private var _barEnergy:FlxBar;
	private var _grpTanks:ZGroup<Tank>;
	private var _grpCopters:ZGroup<Copter>;
	private var _eDistances:Array<Int>;
	private var _grpExplosions:ZGroup<Explosion>;
	private var _grpBullets:ZGroup<Bullet>;
	private var _bounds:FlxRect;
	public var _grpWorldWalls:FlxGroup;
	private var _txtScore:GameFont;
	private var _grpPowerups:ZGroup<PowerUp>;
	private var _roarMarkers:Array<RoarMarker>;
	private var _sndFoot:FlxSound;
	private var _pauseScreen:PauseGroup;
	public var barLoadLeft:FlxSprite;
	public var barLoadRight:FlxSprite;
	private var _txtSillyLoad:GameFont;
	private var _sndRoar:FlxSound;
	private var _sprLightning:FlxSprite;
	
	private var sprTest:FlxSprite;
	private var _sprLoad:FlxSprite;
	private var _barLoad:FlxBar;
	
	private var _playerGlow:FlxSprite;
	
	private var _keysHint:FlxSprite;
	private var _spaceHint:SpaceHint;
	private var _roaring:Bool = false;
	private var _walking:Bool = false;
	private var _wasRoaring:Bool = false;
	private var _wasFacing:Int = -1;
	private var _wasWalking:Bool = false;
	private var _swimming:Bool = false;
	private var _wasSwimming:Bool = false;
	
	private var _txtPlayTime:GameFont;

	override public function create():Void
	{
		FlxG.autoPause = false;
		Reg.playState = this;
		//FlxG.fixedTimestep = false;
		
		Reg.score = 0;
		
		_sndFoot = FlxG.sound.load("sounds/Foot.wav", 1);
		_sndRoar = FlxG.sound.load("sounds/roar.wav", 1);
		
		
		grpDisplay = new ZGroup<Dynamic>();
		_grpSmokes = new FlxTypedGroup<SmokeSpawner>();
		_grpTanks = new ZGroup<Tank>();
		_grpCopters = new ZGroup<Copter>();
		_grpExplosions = new ZGroup<Explosion>();
		_grpBullets = new ZGroup<Bullet>();
		_grpWorldWalls = new FlxGroup(4);
		_grpPowerups = new ZGroup<PowerUp>();
		
		m = new GameMap(77, 77);
		//_trailArea = new FlxTrailArea(0, 0, Std.int(m.mapTerrain.width), Std.int(m.mapTerrain.height), .6, 1, true);

		/*for (i in 0...40)
		{
			if (i < 10)
			{
				_grpPowerups.add(new PowerUp());
				_grpPowerups.members[_grpPowerups.members.length -1].kill();
				_grpBullets.add(new Bullet());
				_grpBullets.members[_grpBullets.members.length - 1].kill();
				_grpCopters.add(new Copter(0, 0));
				_grpCopters.members[_grpCopters.members.length - 1].kill();
			}
			_grpTanks.add(new Tank(0, 0));
			_grpTanks.members[_grpTanks.members.length - 1].kill();
			_grpSmokes.add(new SmokeSpawner(0, 0, 1, 1));
			_grpSmokes.members[_grpSmokes.members.length - 1].kill();
			_grpExplosions.add(new Explosion(0, 0));
			_grpExplosions.members[_grpExplosions.members.length - 1].kill();
		}*/
		
		
		
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

		
		_player = new Player();
		_playerGlow = new FlxSprite();
		_playerGlow.loadGraphic("images/player-glow.png", true, true, 74, 74);
		_playerGlow.width = _player.width;
		_playerGlow.height = _player.height;
		_playerGlow.offset.x = _player.offset.x+5;
		_playerGlow.offset.y = _player.offset.y+5;
		_playerGlow.animation.copyFrom(_player.animation);
		updateGlow();
		
		add(_playerGlow);
		
		_grpHUD = new FlxTypedGroup<Dynamic>();
		add(_grpHUD);
		
		
		FlxG.worldBounds.set(-8, -8, m.mapTerrain.width+16, m.mapTerrain.height+16);
		
		
		
		_player.facing = FlxObject.DOWN;
		
		_barEnergy = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, 300, 18, _player, "energy", 0, 100, true);
		_barEnergy.scrollFactor.x = _barEnergy.scrollFactor.y = 0;
		_barEnergy.createImageBar("images/energy_bar_empty.png", "images/energy_bar_full.png");
		FlxSpriteUtil.screenCenter(_barEnergy, true, false);
		_barEnergy.y = 15;
		_grpHUD.add(_barEnergy);
		
		_roarMarkers = new Array<RoarMarker>();
		var r:RoarMarker;
		for (i in 0...3)
		{
			r = new RoarMarker(_barEnergy.x + _barEnergy.width + 32 + (24 * i), _barEnergy.y);
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
		
		_txtScore = new GameFont(16, 13, "000000000", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "left",25);
		
		_txtScore.scrollFactor.x = _txtScore.scrollFactor.y  = 0;
		_grpHUD.add(_txtScore);
		
		_txtPlayTime = new GameFont(16, 13, "00:00", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 25);
		_txtPlayTime.x = FlxG.width - _txtPlayTime.width - 16;
		_txtPlayTime.scrollFactor.x = _txtPlayTime.scrollFactor.y  = 0;
		_grpHUD.add(_txtPlayTime);
		
		_spawnTimer = _spawnTimerSet = 12;
		_spawnTimer = 1;
		_tankCount = 2;
		_copterCount = 0;
		
		windDir = FlxRandom.floatRanged(1, 360);
		windSpeed = FlxRandom.floatRanged(0, 1);
		
		
		
		Reg.score = 0;
		Reg.scores = [0, 0, 0];
		
		_pauseScreen = new PauseGroup();
		add(_pauseScreen);
		
		_sprLightning = new FlxSprite(0, -10, "images/lightning.png");
		FlxSpriteUtil.screenCenter(_sprLightning, true, false);
		_sprLightning.x += 16;
		_sprLightning.alpha = 0;
		_sprLightning.visible = false;
		_sprLightning.scrollFactor.set();
		add(_sprLightning);
		
		
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
		
		updateHUDAlpha(0);
		
		GameControls.newState([]);
		
		super.create();
	}
	
	private function updateGlow():Void
	{
		//_playerGlow.animation.play(_player.animation.curAnim.name, true, _player.animation.frameIndex);
		_playerGlow.animation.frameIndex = _player.animation.frameIndex;
		_playerGlow.facing = _player.facing;
		_playerGlow.x = _player.x;
		_playerGlow.y = _player.y;
		_playerGlow.alpha = _player.alpha;
	}
	
	public function shootBullet(Origin:FlxPoint, Angle:Float, Style:Int = 0):Void
	{
		var b:Bullet = _grpBullets.recycle(Bullet);
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
		_txtPlayTime = null;
		_sndFoot = FlxDestroyUtil.destroy(_sndFoot);
		_pauseScreen = null;

	}

	override public function draw():Void 
	{
		buildDrawGroup();
		
		
		if (_player != null && _playerGlow != null)
		{
			updateGlow();
		}
		super.draw();
	}
	
	private function addSort(O:IFlxZ):Void
	{
		var first:Int = 0;
		var last:Int = grpDisplay.zMembers.length;
		var i:Int = last;
		
		var value:Float = O.z;
		
		while ((i > first) && (value < grpDisplay.zMembers[i - 1].z))
		{
			i = i - 1;
		}
		grpDisplay.zMembers.insert(i, O);
		grpDisplay.length++;
		
	}
	
	private function rectsIntersect(a:Rectangle, b:Rectangle):Bool
	{
		return (Math.abs(a.x - b.x) * 2 < (a.width + b.width)) && (Math.abs(a.y - b.y) * 2 < (a.height + b.height));
	}
	
	private function buildDrawGroup():Void
	{
		if (!_allowDraw)
			return;
		
		FlxG.worldBounds.x = FlxG.camera.scroll.x -8;
		FlxG.worldBounds.y = FlxG.camera.scroll.y -8;
		
		grpDisplay.clear();
		grpDisplay.add(_player);

		for (c in m.cityTiles.members)
		{
			if (c.alive && c.exists && c.visible)
			{
				
				//if(_boundRect.overlaps(c,true))
				if(rectsIntersect(_boundRect.pixels.rect,c.pixels.rect))
				{
					c.onScreen = true;
					addSort(c);
				}
			}
		}

		for (s in _grpSmokes.members)
		{
			if (s.alive && s.exists && s.visible)
			{
				//if (_boundRect.overlaps(s.bounds,true))
				if(rectsIntersect(_boundRect.pixels.rect,s.bounds.pixels.rect))
				{
					addSort(s);
				}
				else
				{
					s.markForDeath();
				}
			}
		}
		
		for (c in _grpTanks.members)
		{
			if (c.alive && c.exists && c.visible)
			{
				addSort(c);
			}
		}

		for (c in _grpCopters.members)
		{
			if (c.alive && c.exists && c.visible)
			{
				addSort(c);
			}
			
		}
		
		for (c in _grpExplosions.members)
		{
			if (c.alive && c.exists && c.visible)
			{
				if (rectsIntersect(_boundRect.pixels.rect, c.pixels.rect))
				{
					c.onScreen = true;
					addSort(c);
				}
				else
					c.onScreen = false;
			}
		}

		for (c in _grpBullets.members)
		{
			if (c.exists && c.visible)
			{
				if (rectsIntersect(_boundRect.pixels.rect, c.pixels.rect))
				{
					c.onScreen = true;
					addSort(c);
				}
				else
				{
					c.onScreen = false;
					c.alive = false;
					c.exists = false;
				}
			}
		}
		
		for (c in _grpPowerups.members)
		{
			if (c.exists && c.visible && c.alive)
			{
				if (rectsIntersect(_boundRect.pixels.rect, c.pixels.rect))
				{
					c.onScreen = true;
					addSort(c);
				}
				else
				{
					c.onScreen = false;
				}
			}
		}
		
		grpDisplay.updateMembers();

	}
	
	
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
				
				var unpause:Bool = false;
				#if !FLX_NO_KEYBOARD
				if (FlxG.keys.anyJustReleased(GameControls.keys[GameControls.PAUSE])||FlxG.keys.anyJustReleased(GameControls.keys[GameControls.BACK]))
				{
					unpause = true;
				}
				#end
				#if !FLX_NO_GAMEPAD
				if (GameControls.hasGamepad)
				{
					if (GameControls.gamepad.anyJustReleased(GameControls.buttons[GameControls.PAUSE]) || GameControls.gamepad.anyJustReleased(GameControls.buttons[GameControls.BACK]))
					{
						unpause = true;
					}
				}
				#end
				
				if (unpause)
				{
					_pauseScreen.hide();					
				}
				
				GameControls.checkScreenControls();
				
				if (!_pauseScreen.shown)
				{
					_paused = false;
				}
				_pauseScreen.update();
				return;
			}
			else
			{
			
				
				
				if (!_hasFocus)
				{
					_pauseScreen.show();
					_paused = true;
				}
				
				Reg.playTime += FlxG.elapsed;
				
				_txtPlayTime.text = Reg.formatPlayTime();
				
				_player.energy -= FlxG.elapsed * 6;
				
				
				var isDebug = false;
				#if debug
				//isDebug = true;
				#end
				
				if (_player.energy <= 0 && !isDebug)
				{
					
					_leaving = true;						
					FlxG.camera.follow(null);
					FlxG.sound.music.fadeOut(Reg.FADE_DUR * 4);
					_player.velocity.set();
					_player.acceleration.set();
					FlxTween.num(0, 0, .33, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut }, updateHUDAlpha );
					FlxTween.num(FlxG.camera.zoom, 4, 1.2, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneGOZoomIn }, updateCameraZoom );
					
				}
				else
				{
					
					var showpause:Bool = false;
					
					#if !FLX_NO_KEYBOARD
					if (FlxG.keys.anyJustReleased(GameControls.keys[GameControls.PAUSE]))
					{
						showpause = true;
					}
					#end
					#if !FLX_NO_GAMEPAD
					if (GameControls.hasGamepad)
					{
						if (GameControls.gamepad.anyJustReleased(GameControls.buttons[GameControls.PAUSE]))
						{
							showpause = true;
						}
					}
					#end
					
					if (showpause)
					{
						_pauseScreen.show();
						_paused = true;
					}
					
					changeWind();
					checkEnemySpawn();
					FlxG.collide(_player, _grpWorldWalls);
					FlxG.collide(_player, m.cityTiles, playerTouchCityTile);
					//FlxG.overlap(grpDisplay, grpDisplay, checkOverlap);
					
					FlxG.overlap(_player, _grpBullets, bulletHitPlayer);
					FlxG.overlap(_player, _grpTanks, playerHitTank);
					FlxG.overlap(_player, _grpCopters, playerHitCopter);
					FlxG.overlap(_player, _grpPowerups, playerGetPowerup);
					FlxG.overlap(_grpBullets, m.cityTiles, bulletHitCityTile);
					
					
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
		if (_player != null)
		{
			updatePlayerAnimation();
			
			
		}
		super.update();
	}
	
	private function updatePlayerAnimation():Void
	{
		if (_player.facing == _wasFacing && _walking == _wasWalking && _roaring == _wasRoaring && _swimming == _wasSwimming)
			return;
			
		var anim:String="";
		switch(_player.facing)
		{
			case FlxObject.RIGHT, FlxObject.LEFT:
				anim = "lr";
			case FlxObject.UP:
				anim = "u";
			case FlxObject.DOWN:
				anim = "d";
		}
		if (_walking)
			anim += "-w";
		if (_roaring)
			anim += "-r";
		if (_swimming)
			anim += "-s";
		
		var frame:Int = 0;
		if ((_roaring != _wasRoaring || _swimming != _wasSwimming) && _player.facing == _wasFacing && _walking == _wasWalking)
		{
			frame = _player.animation.frameIndex;
		}
			
		_player.animation.play(anim, true, frame);
		_wasRoaring = _roaring;
		_wasFacing = _player.facing;
		_wasWalking = _walking;
		_wasSwimming = _swimming;
	}
	
	private function doneGOZoomIn(T:FlxTween):Void
	{
		roar();
		FlxTween.num(1,0, 1.8, { type:FlxTween.ONESHOT, ease:FlxEase.bounceInOut, complete:doneGOFadeOut }, updatePlayerAlpha );
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
				sprTest = new FlxSprite().makeGraphic(30, 30, 0xcc000000);
				
				sprTest.moves = false;
				sprTest.immovable = true;
				sprTest.x = (m.mapTerrain.width / 2) - (sprTest.width / 2)-31;
				sprTest.y = (m.mapTerrain.height / 2) - (sprTest.height / 2)-31;
				sprTest.draw();
				sprTest.update();
				_player.x = sprTest.x + (sprTest.width / 2) - (_player.width / 2)-16;// - FlxG.camera.scroll.x - 16;
				_player.y = sprTest.y + (sprTest.height / 2) - (_player.height / 2)-16;// - FlxG.camera.scroll.y - 16;
				_allowDraw = true;
				_player.alpha = 0;
				for (c in m.cityTiles.members)
				{
					if (sprTest.overlaps(c, true))
					{						
						c.animation.frameIndex = 21;
					}
				}
				
				FlxG.camera.followLead.x = 2;
				FlxG.camera.followLead.y = 2;
				FlxG.camera.follow(_player, FlxCamera.STYLE_NO_DEAD_ZONE, null, 8);
				FlxTween.num(1, 0, Reg.FADE_DUR * 2, { type:FlxTween.ONESHOT, ease:FlxEase.quintInOut, complete:doneFadeIn }, updateLoadAlpha );
				
				
			}
		}
	}
	
	private function updateLoadAlpha(Value:Float):Void
	{
		if (_sprLoad!=null)
			_barLoad.alpha = _sprLoad.alpha = _txtSillyLoad.alpha = barLoadLeft.alpha = barLoadRight.alpha =  Value;
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
		_sprLightning.visible = true;
		_sprLightning.alpha = 0;
		FlxTween.tween(_sprLightning, { alpha:1 }, .2, { type:FlxTween.ONESHOT, ease:FlxEase.bounceIn } );
	}
	
	private function doneZoomIn(T:FlxTween):Void
	{
		roar();
		FlxTimer.start(.66, doneStartRoar);
	}
	
	private function doneFlashOne():Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxG.camera.flash(0x99ffffff, .6, doneFlashTwo);
		_sprLightning.alpha = .66;
		
	}
	
	private function doneLightningShow(T:FlxTween):Void
	{
		_sprLightning.kill();
		_sprLightning = FlxDestroyUtil.destroy(_sprLightning);
	}
	
	private function doneFlashTwo():Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxTimer.start(.66, doneShortWait);
		_sprLightning.alpha = 1;
		FlxTween.tween(_sprLightning, { alpha:0 }, .2, { type:FlxTween.ONESHOT, ease:FlxEase.bounceOut } );
		
	}
	
	private function doneShortWait(T:FlxTimer):Void
	{
		FlxTween.num(FlxG.camera.zoom, 4, 1, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneZoomIn }, updateCameraZoom );
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
		FlxTween.num(0, 1, 1.6, { type:FlxTween.ONESHOT, ease:FlxEase.bounceInOut, complete:donePlayerIn }, updatePlayerAlpha );
	}
	
	private function updatePlayerAlpha(Value:Float):Void
	{
		_player.alpha = Value;
	}
	
	private function donePlayerIn(T:FlxTween):Void
	{
		FlxTween.num(FlxG.camera.zoom, 1, 1.66, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneZoomOut }, updateCameraZoom );
	}
	
	private function updateCameraZoom(Value:Float):Void
	{
		FlxG.camera.zoom = Value;
		// do the other stuff to fix pos?
		FlxG.camera.width = Std.int(FlxG.width / FlxG.camera.zoom);
		FlxG.camera.height = Std.int(FlxG.height / FlxG.camera.zoom);
		FlxG.camera.follow(_player, FlxCamera.STYLE_NO_DEAD_ZONE, null, 8);
		
	}
	
	private function doneZoomOut(T:FlxTween):Void
	{
		FlxTween.num(0, 1, .66, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:doneLoad }, updateHUDAlpha );
	}
	
	private function updateHUDAlpha(Value:Float):Void
	{
		if (_keysHint!=null) 
		{
			_keysHint.alpha = _spaceHint.alpha = Value;
		}
		_txtPlayTime.alpha = _barEnergy.alpha = _txtScore.alpha = _roarMarkers[0].alpha  = _roarMarkers[1].alpha = _roarMarkers[2].alpha= Value;
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
		var t:Tank;
		var c:Copter;
		var side:Int;
		var xPos:Float=0;
		var yPos:Float = 0;
		var locOk:Bool = false;
		var rect:FlxRect;
		var _coptersSpawned:Int = 0;
		var _tanksSpawned:Int = 0;
		
		var pM:FlxPoint = FlxPoint.get(_player.x + (_player.width / 2), _player.y + (_player.height / 2));
		
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
					c =  _grpCopters.recycle(Copter);
					if (c != null)
					{
						c.init(xPos, yPos, pM.x, pM.y - 16);
						_coptersSpawned++;
					}
					
				}
				else if (_tanksSpawned < _tankCount)
				{
				
					t =  _grpTanks.recycle(Tank);
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
			_player.energy += c.tier * 1.8;
			giveScore(c.tier * 22);
			Reg.scores[Reg.SCORE_BUILDINGS]++;
			if (FlxRandom.chanceRoll(2 * c.tier))
			{
				var p:PowerUp =  _grpPowerups.recycle(PowerUp);
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
	
	
	
	private function doneLoad(T:FlxTween):Void
	{
		_finished = true;
		FlxG.camera.follow(_player, FlxCamera.STYLE_TOPDOWN_TIGHT, null, 10);
		FlxG.sound.playMusic("game-music", 1, true);
		calculateDistances();
		updateHUDAlpha(1);
		FlxTimer.start(5, hideHints);
		Reg.playTime = 0;
		GameControls.canInteract = true;
	}
	
	private function hideHints(T:FlxTimer):Void
	{
		FlxTween.num(1, 0, Reg.FADE_DUR * 4, { type:FlxTween.ONESHOT, ease:FlxEase.circInOut, complete:destroyHints }, updateHintAlpha);
	}
	
	private function updateHintAlpha(Value:Float):Void
	{
		_spaceHint.alpha = _keysHint.alpha = Value;
	}
	
	private function destroyHints(T:FlxTween):Void
	{
		_spaceHint = FlxDestroyUtil.destroy(_spaceHint);
		_keysHint = FlxDestroyUtil.destroy(_keysHint);
	}
	
	private function addSmoke(X:Float, Y:Float, Width:Float, Height:Float):Void
	{
		var s:SmokeSpawner = _grpSmokes.recycle(SmokeSpawner);
		if (s != null)
		{
			s.init(X, Y, Width, Height);
		}
	}
	
	public function createCitySmoke(X:Float, Y:Float, C:CityTile):Void
	{
		addSmoke(X, Y, 64, 64);
		m.mapPathing.setTile(Math.floor(X/32), Math.floor(Y/32), 0);
		m.mapPathing.setTile(Math.floor(X/32)+1, Math.floor(Y/32), 0);
		m.mapPathing.setTile(Math.floor(X/32)+1, Math.floor(Y/32)+1, 0);
		m.mapPathing.setTile(Math.floor(X/32), Math.floor(Y/32)+1, 0);
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
			e =  _grpExplosions.recycle(Explosion);
			if (e != null)
			{
				e.reset(FlxRandom.floatRanged(Xmin, Xmax ), FlxRandom.floatRanged(Ymin, Ymax));
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
		
		var pM:FlxPoint = _player.getMidpoint();//FlxPoint.get(_player.x + (_player.width / 2), _player.y + (_player.height/2));
		var tank:Tank;
		var ePos:FlxPoint;
		for (tank in _grpTanks.members)
		{
			if (tank.alive && tank.exists && tank.visible)
			{
				tank.setTarget(pM.x, pM.y);
				ePos = FlxPoint.get(tank.x + (tank.width / 2), tank.y + (tank.height / 2));
				if (Math.abs(FlxMath.getDistance(ePos, pM)) >= 128)
				{
					if (!tank.moving)
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
					
					
				}
				else if (tank.moving)
				{
					tank.stopMoving();
				}
				ePos = FlxDestroyUtil.put(ePos);
			}
			
		}
		
		
		for (copter in _grpCopters.members)
		{		
			if (copter.alive && copter.exists && copter.visible && !copter.isDead)
			{
				copter.setTarget(pM.x, pM.y);
			}
		}
		
		pM = FlxDestroyUtil.put(pM);
		
	}
	
	private function calculateDistances():Void
	{
		var pM:FlxPoint = _player.getMidpoint();// FlxPoint.get(_player.x + (_player.width / 2), _player.y + _player.height);
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
		_pressingUp = FlxG.keys.anyPressed(GameControls.keys[GameControls.UP]);
		_pressingDown = FlxG.keys.anyPressed(GameControls.keys[GameControls.DOWN]);
		_pressingLeft = FlxG.keys.anyPressed(GameControls.keys[GameControls.LEFT]);
		_pressingRight = FlxG.keys.anyPressed(GameControls.keys[GameControls.RIGHT]);
		_pressingShoot = FlxG.keys.anyPressed(GameControls.keys[GameControls.FIRE]);
		#end
		#if !FLX_NO_GAMEPAD
		if (GameControls.hasGamepad)
		{
			
			#if !flash
			_pressingUp =  GameControls.gamepad.dpadUp;
			_pressingDown =  GameControls.gamepad.dpadDown;
			_pressingLeft =  GameControls.gamepad.dpadLeft;
			_pressingRight =  GameControls.gamepad.dpadRight;
			#else
			_pressingUp = GameControls.gamepad.anyPressed(GameControls.buttons[GameControls.UP]);
			_pressingDown = GameControls.gamepad.anyPressed(GameControls.buttons[GameControls.DOWN]);
			_pressingLeft = GameControls.gamepad.anyPressed(GameControls.buttons[GameControls.LEFT]);
			_pressingRight = GameControls.gamepad.anyPressed(GameControls.buttons[GameControls.RIGHT]);
			#end
			_pressingShoot = GameControls.gamepad.anyPressed(GameControls.buttons[GameControls.FIRE]);
		}
		#end
		
		if (_pressingDown && _pressingUp)
			_pressingDown = _pressingUp = false;
		if (_pressingLeft && _pressingRight)
			_pressingLeft = _pressingRight = false;
		
		_walking = _pressingDown || _pressingLeft || _pressingRight || _pressingUp;
		
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
			if (!_player.overlaps(m.mapWater))
			{
				_swimming = true;
				v = FlxAngle.rotatePoint(SPEED*.4, 0, 0, 0, mA);
			}
			else
			{
				_swimming = false;
				v = FlxAngle.rotatePoint(SPEED, 0, 0, 0, mA);
			}
				
			_player.velocity.x = v.x;
			_player.velocity.y = v.y;
			v = FlxDestroyUtil.put(v);
			
			if (_walking)
			{
				
				if (_player.velocity.x > 0 && Math.abs(_player.velocity.x) > Math.abs(_player.velocity.y))
				{
					_player.facing = FlxObject.RIGHT;
				}
				else if (_player.velocity.x < 0 && Math.abs(_player.velocity.x) > Math.abs(_player.velocity.y))
				{
					_player.facing = FlxObject.LEFT;
				}
				else if (_player.velocity.y > 0)
				{
					_player.facing = FlxObject.DOWN;
				}
				else if (_player.velocity.y < 0)
				{
					_player.facing = FlxObject.UP;
				}
			}
			
		}
		
		if (!_pressingDown && !_pressingUp)
			if (Math.abs(_player.velocity.y) > 1)
				_player.velocity.y *= FRICTION;
		if (!_pressingLeft && !_pressingRight)
			if (Math.abs(_player.velocity.x) > 1)
				_player.velocity.x *= FRICTION;
		
		if (_walking)
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
					
					roar();
					
					
					for (c in _grpCopters.members)
					{
						//c = _grpCopters.members[i];
						if (c.alive && c.exists && !c.isDead && c.onScreen)
						{
							giveScore(8);
							Reg.scores[Reg.SCORE_COPTERS]++;
							c.kill();
						}
					}
					
					for (t in _grpTanks.members)
					{
						
						if (t.onScreen && t.alive && t.exists)
						{
							giveScore(6);
							Reg.scores[Reg.SCORE_TANKS]++;
							t.kill();
						}
					}
					
					for (b in _grpBullets.members)
					{
						
						if (b.onScreen && b.alive && b.exists)
						{
							b.kill();
						}
					}
				}
			}
		}
	}
	
	private function roar():Void
	{
		_sndRoar.play();
		_roaring = true;
		FlxG.camera.shake(.005, 2.3,doneRoar);
	}
	
	private function doneRoar():Void
	{
		_roaring = false;
	}
	
	override public function onFocusLost():Void 
	{
		//super.onFocusLost();
		
		_hasFocus = false;
	}
	
	override public function onFocus():Void 
	{
		
		//super.onFocus();
		_hasFocus = true;
	}
	
	
}
