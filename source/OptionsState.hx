package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
		add(_optScreen);
		
		_optScreen.active = false;
		#end
		
		
		_btnDone = new GameButton(0, 0, "Done", goDone, GameButton.STYLE_GREEN, true);
		_btnDone.y = FlxG.height - _btnDone.height - 16;
		FlxSpriteUtil.screenCenter(_btnDone, true, false);
		add(_btnDone);
		_btnDone.active = false;
		
		
		
		#if desktop
		GameControls.newState([_btnDone, _uiVolume, _optScreen]);
		#else
		GameControls.newState([_btnDone, _uiVolume]);
		#end
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, true, doneFadeIn);
		
		super.create();
		
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
		GameControls.checkScreenControls();
		super.update();
	}
}