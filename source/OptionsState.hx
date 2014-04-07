package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;


class OptionsState extends FlxState
{
	private var _loading:Bool = true;
	private var _leaving:Bool = false;
	
	#if desktop
	private var _optScreen:GameButton;
	#end
	
	private var _btnDone:GameButton;
	private var _optSlide1:CustomSlider;
	
	private var _uiElements:Array<IUIElement>;
	
	#if !FLX_NO_KEYBOARD
	private var _txtKeys:Array<GameFont>;
	private var _fakeKeys:Array<FakeUIElement>;
	private var _newKey:Int = -1;
	#end
	#if !FLX_NO_GAMEPAD
	private var _txtBtns:Array<GameFont>;
	private var _fakeBtns:Array<FakeUIElement>;
	private var _newBtn:Int = -1;
	#end
	
	private var _grpModal:FlxGroup;
	private var _txtModal:GameFont;
	private var _txtModal2:GameFont;
	private var _modalAlpha:Float = 0;
	
	private var _resetKeyBindings:GameButton;
	
	
	override public function create():Void 
	{
		FlxG.autoPause = false;
		FlxG.sound.soundTrayEnabled = false;
		add( new FlxSprite(0, 0, "images/title-back.png"));
		add( new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x99000000));
		
		var txtOpts:GameFont = new GameFont(0, 16, "Options", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "center", 32);
		FlxSpriteUtil.screenCenter(txtOpts, true, false);
		add(txtOpts);
		
		var txtVol:GameFont = new GameFont(16, txtOpts.y + txtOpts.height + 32, "Volume", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(txtVol);
		
		_optSlide1 = new CustomSlider(txtVol.x + txtVol.width + 16, txtVol.y + (txtVol.height / 2) - 8, Std.int(FlxG.width - txtVol.width -80), 64, 16, 14, 0, 1, SlideChange);
		_optSlide1.decimals = 1;
		_optSlide1.value = FlxG.sound.volume;
		var _uiVolume:FakeUIElement = new FakeUIElement(_optSlide1.x - 10, _optSlide1.y - 10, Std.int(_optSlide1.width +20), Std.int(_optSlide1.height + 20), null, changeVol);
		add(_uiVolume);
		add(_optSlide1);
		_optSlide1.active = false;
		
		#if desktop
		var txtScreen:GameFont = new GameFont(16, txtVol.y + txtVol.height + 32, "Screen Mode", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(txtScreen);
		
		_optScreen = new GameButton(txtScreen.x + txtScreen.width + 16, txtScreen.y + (txtScreen.height / 2) - 16, FlxG.fullscreen ? "Fullscreen" : "Window", changeScreen,GameButton.STYLE_BLUE , false, 200, 32,24);
		FlxSpriteUtil.screenCenter(_optScreen, true, false);		
		add(_optScreen);
		
		_optScreen.active = false;
		#end
		
		
		var _txtControls:GameFont = new GameFont(0, txtVol.y + txtVol.height + 96, "Controls", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "center", 32);
		FlxSpriteUtil.screenCenter(_txtControls, true, false);
		add(_txtControls);
		
		var _txtLeft:GameFont = new GameFont(64, _txtControls.y + _txtControls.height + 16, "LEFT:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtLeft);
		
		var _txtRight:GameFont = new GameFont(64, _txtLeft.y + _txtLeft.height + 8, "RIGHT:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtRight);
		
		var _txtUp:GameFont = new GameFont(64, _txtRight.y + _txtRight.height + 8, "UP:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtUp);
		
		var _txtDown:GameFont = new GameFont(64, _txtUp.y + _txtUp.height + 8, "DOWN:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtDown);
		
		var _txtFire:GameFont = new GameFont(64, _txtDown.y + _txtDown.height + 8, "FIRE:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtFire);
		
		var _txtPause:GameFont = new GameFont(64, _txtFire.y + _txtFire.height + 8, "PAUSE:", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(_txtPause);
		
		_btnDone = new GameButton(0, 0, "Done", goDone, GameButton.STYLE_GREEN, true);
		_btnDone.y = FlxG.height - _btnDone.height - 16;
		FlxSpriteUtil.screenCenter(_btnDone, true, false);
		_btnDone.active = false;
		
		_uiElements = new Array<IUIElement>();
		_uiElements.push(_btnDone);
		_uiElements.push(_uiVolume);
		#if desktop
		_uiElements.push(_optScreen);
		#end
		
		#if !FLX_NO_KEYBOARD
		_txtKeys = new Array<GameFont>();
		_fakeKeys = new Array<FakeUIElement>();
		#end
		#if !FLX_NO_GAMEPAD
		_txtBtns = new Array<GameFont>();
		_fakeBtns = new Array<FakeUIElement>();
		#end
				
		for (i in 0...6)
		{		
			#if !FLX_NO_KEYBOARD
			_txtKeys.push(new GameFont(164, _txtLeft.y + ((_txtLeft.height + 8)*i), GameControls.getKeyList(i), GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGREEN, "left", 24));
			_fakeKeys.push(new FakeUIElement(_txtKeys[i].x - 4, _txtKeys[i].y - 2, 382, Std.int(_txtKeys[i].height - 4), promptNewKey.bind(i), null, false));
			add(_fakeKeys[i]);
			add(_txtKeys[i]);
			_uiElements.push(_fakeKeys[i]);
			#end
			#if !FLX_NO_GAMEPAD
			
			_txtBtns.push(new GameFont(546, _txtLeft.y + ((_txtLeft.height + 8) * i), GameControls.getButtonList(i), GameFont.STYLE_SMSIMPLE, i > 3 ? GameFont.COLOR_SIMPLEGREEN : GameFont.COLOR_SIMPLEGOLD, "left", 24));
			if (i > 3)
			{
				_fakeBtns.push(new FakeUIElement(_txtBtns[i].x - 4, _txtBtns[i].y - 2, 382, Std.int(_txtBtns[i].height - 4), promptNewButton.bind(i), null, false));
				add(_fakeBtns[_fakeBtns.length-1]);
				_uiElements.push(_fakeBtns[_fakeBtns.length-1]);
			}
			add(_txtBtns[i]);
			#end
		}
		
		add(_btnDone);
		
		_grpModal = new FlxGroup();
		_grpModal.add(new FlxSprite((FlxG.width / 2) - 400, (FlxG.height / 2) - 40).makeGraphic(800, 80, FlxColor.WHITE));
		_grpModal.add(new FlxSprite((FlxG.width / 2) - 398, (FlxG.height / 2) - 38).makeGraphic(796, 76, FlxColor.BLACK));
		_txtModal = new GameFont(0, 0, "Press a key to bind it to LEFT", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "left", 32);
		FlxSpriteUtil.screenCenter(_txtModal);
		_txtModal.y -= 16;
		_grpModal.add(_txtModal);

		_txtModal2 = new GameFont(0, 0, "Press ESCAPE to Cancel", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "left", 16);
		FlxSpriteUtil.screenCenter(_txtModal2, true, true);
		_txtModal2.y += 24;
		_grpModal.add(_txtModal2);
		
		for (o in _grpModal.members)
		{
			cast(o).alpha = _modalAlpha;
		}
		add(_grpModal);
		_grpModal.visible = false;
		
		_resetKeyBindings = new GameButton(0, 0, "Reset Controls", resetControls, GameButton.STYLE_RED, true, 0, 0, 18);
		_resetKeyBindings.x = FlxG.width - _resetKeyBindings.width - 16;
		_resetKeyBindings.y = FlxG.height - _resetKeyBindings.height - 16;
		add(_resetKeyBindings);
		_uiElements.push(_resetKeyBindings);
		
		GameControls.newState(_uiElements);
		
		
		var _txtVer = new FlxText(0,0,0, "DOWN:", 8);
		_txtVer.setFormat(null, 8, 0xffffff, "right", FlxText.BORDER_OUTLINE);
		_txtVer.x = FlxG.width - _txtVer.width;
		_txtVer.y = FlxG.height - _txtVer.height;
		add(_txtVer);
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, true, doneFadeIn);
		
		super.create();
		
	}
	
	private function resetControls():Void
	{
		GameControls.resetBindings();
		rebuildCommandList();
	}
	
	private function promptNewKey(NewKey:Int):Void
	{
		_newKey = NewKey;
		_txtModal.text = "Press a key to bind it to " + GameControls.commandList[NewKey];
		FlxTween.num(0, 1, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
		
	}
	
	private function promptNewButton(NewButton:Int):Void
	{
		_newBtn = NewButton;
		_txtModal.text = "Press a button to bind it to " + GameControls.commandList[_newBtn];
		FlxTween.num(0, 1, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
	}
	
	private function modalAlpha(Value:Float):Void
	{
		_modalAlpha = Value;
	}
	
	private function changeVol(Input:Int = 0):Void
	{
		if (Input == GameControls.SELLEFT)
			FlxG.sound.volume-=.1;
		else if (Input == GameControls.SELRIGHT)
			FlxG.sound.volume+=.1;
	}
	
	#if desktop
	private function changeScreen():Void
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		Reg.IsFullscreen = FlxG.fullscreen;
		Reg.save.bind("flixel");
		Reg.save.data.fullscreen = FlxG.fullscreen;
		Reg.save.flush();
		Reg.save.close();
		if (FlxG.fullscreen)
		{
			_optScreen.label.text = "Fullscreen";
		}
		else
		{
			_optScreen.label.text = "Window";
		}
		_optScreen.autoCenterLabel();
	}
	#end
	
	private function goDone():Void
	{
		_leaving = true;
		_btnDone.active = _optSlide1.active = false;
		#if desktop
		_optScreen.active = false;
		#end
		GameControls.canInteract = false;
		
		//save keybindings
		Reg.save.bind("flixel");
		#if !FLX_NO_KEYBOARD
		Reg.save.data.keys = GameControls.keys;
		#end
		#if !FLX_NO_GAMEPAD
		Reg.save.data.buttons = GameControls.buttons;
		#end
		Reg.save.flush();
		FlxG.sound.soundTrayEnabled = true;
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, false, goDoneDone);
	}
	
	private function goDoneDone():Void
	{
		FlxG.switchState(new MenuState());
	}
	
	private function SlideChange(Value:Float):Void
	{
		
		FlxG.sound.volume = Value;
		//Reg.save.data.volume = FlxG.sound.volume;
		//Reg.save.flush();
		FlxG.sound.play("sounds/blip.wav", .25);
	}
	
	private function doneFadeIn():Void
	{
		_btnDone.active = _optSlide1.active = true;
		#if desktop
		_optScreen.active = true;
		#end
		GameControls.canInteract = true;
	}
	
	override public function update():Void 
	{
		if (FlxG.sound.volume != _optSlide1.value)
			_optSlide1.value = FlxG.sound.volume;
		if (_modalAlpha >= 1)
		{
			var stopCheck:Bool = false;
			#if !FLX_NO_KEYBOARD
			if (FlxG.keys.anyJustReleased(["ESCAPE"]))
			{
				_newKey = -1;
				#if !FLX_NO_GAMEPAD
				_newBtn = -1;
				#end
				FlxTween.num(1, 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
				stopCheck = true;
			}
			#end
			#if !FLX_NO_GAMEPAD
			if (GameControls.gamepad.anyJustReleased([GameControls.BACK]))
			{
				#if !FLX_NO_KEYBOARD
				_newKey = -1;
				#end
				_newBtn = -1;
				FlxTween.num(1, 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
				stopCheck = true;
			}
			#end
			if (!stopCheck)
			{
				#if !FLX_NO_KEYBOARD
				if (_newKey != -1)
				{
					if (FlxG.keys.justReleased.ANY)
					{
						var k:FlxKey = FlxG.keys.getFirstJustReleased();
						if (k != null)
						{
							var keyName:String = k.name;
							GameControls.remapKey(_newKey, keyName);
							rebuildCommandList();
							_newKey = -1;
							FlxTween.num(1, 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
						}
					}
				}
				else 
				{
					#end
					#if !FLX_NO_GAMEPAD
					if (_newBtn != -1)
					{
						var b:Int = GameControls.gamepad.firstJustReleasedButtonID();
						if (b!=-1)
						{
							
							GameControls.gamepad.reset();
							GameControls.remapButton(_newBtn, b);
							_newBtn = -1;
							rebuildCommandList();
							FlxTween.num(1, 0, Reg.FADE_DUR, { type:FlxTween.ONESHOT, ease:FlxEase.quadInOut }, modalAlpha);
						}
					}
					#end
				#if !FLX_NO_KEYBOARD
				}
				#end
			}
		}
		else
		{			
			GameControls.checkScreenControls();
		}
		if (_modalAlpha > 0)
		{
			_grpModal.visible = true;
			for (o in _grpModal.members)
			{
				cast(o,FlxSprite).alpha = _modalAlpha;
			}
		}
		else
			_grpModal.visible = false;
		super.update();
	}
	
	private function rebuildCommandList():Void
	{
		for (i in 0...6)
		{
			#if !FLX_NO_KEYBOARD
			_txtKeys[i].text = GameControls.getKeyList(i);
			#end
			#if !FLX_NO_GAMEPAD
			if (i > 3)
			{
				_txtBtns[i].text = GameControls.getButtonList(i);
			}
			#end
		}
	}
}