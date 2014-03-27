package;

import flash.display.BlendMode;
import flash.filters.GlowFilter;
import flixel.addons.effects.FlxWaveSprite;
import flixel.effects.FlxSpriteFilter;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _sprBones:FlxSprite;
	private var _sprBonesLight:FlxSprite;
	private var _sprGhost01:FlxSprite;
	private var _sprGhost02:FlxSprite;
	private var _sprGhost03:FlxSprite;
	
	private var _textMain:GameFont;
	private var _textSub:GameFont;
	private var _textMainWave:FlxWaveSprite;
	private var _text1Glow:GlowFilter;
	private var _text2Glow:GlowFilter;
	private var _text1Filter:FlxSpriteFilter;
	private var _text2Filter:FlxSpriteFilter;
	
	private var _btnPlay:GameButton;
	private var _btnCredits:GameButton;
	private var _shownText:Bool = false;
	private var _leaving:Bool = false;
	private var _loading:Bool = true;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.autoPause = false;
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		add( new FlxSprite(0, 0, "images/title-back.png"));
		
		add(FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x0, 0x0, 0xff000000], 1, 90));
		
		
		_textMain = new GameFont(0, 24, "Dinosaur-Ghost", GameFont.STYLE_HUGE_TITLE, GameFont.COLOR_CYAN, "center");
		_text1Glow = new GlowFilter(0xff66ffff, .9, 50, 50, 1, 1);
		FlxTween.tween(_text1Glow, {alpha:.6 }, 2, { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut,  loopDelay:.6 } );
		
		_text1Filter = new FlxSpriteFilter(_textMain, 60, 60);
		_text1Filter.addFilter(_text1Glow);
		FlxSpriteUtil.screenCenter(_textMain, true, false);
		_textMainWave = new FlxWaveSprite(_textMain,FlxWaveSprite.MODE_BOTTOM,400,0);
		_textMainWave.alpha = 0;
		_textMainWave.blend = BlendMode.SCREEN;
		_textMainWave.y = 124;
		add(_textMainWave);
		
		_textSub = new GameFont(0, _textMain.y+_textMain.height-68,  "RAMPAGE", GameFont.STYLE_BIG_TITLE, GameFont.COLOR_RED, "center");
		FlxSpriteUtil.screenCenter(_textSub, true, false);
		_textSub.alpha = 0;
		_textSub.angle = -3;
		_textSub.blend  = BlendMode.HARDLIGHT;
		add(_textSub);

		_text2Glow = new GlowFilter(0xffff0000, .8, 50, 50, 1.5, 1);
		FlxTween.tween(_text2Glow, { blurX:10, blurY:10 }, 2, { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut,  loopDelay:.6 } );
		
		_text2Filter = new FlxSpriteFilter(_textSub, 50, 50);
		_text2Filter.addFilter(_text2Glow);
		
		_sprBones = new FlxSprite(0, 0, "images/title-bones.png");
		add(_sprBones);
		
		_sprBonesLight = new FlxSprite(0, 0, "images/title-bones-lightning.png");
		_sprBonesLight.alpha = 0;
		add(_sprBonesLight);
		
		
		_sprGhost01 = new FlxSprite(0, 0, "images/title-ghost-01.png");
		_sprGhost01.alpha = 0;
		add(_sprGhost01);
		_sprGhost02 = new FlxSprite(0, 0, "images/title-ghost-02.png");
		_sprGhost02.alpha = 0;
		add(_sprGhost02);
		_sprGhost03 = new FlxSprite(0, 0, "images/title-ghost-03.png");
		_sprGhost03.alpha = 0;
		add(_sprGhost03);

		_btnPlay = new GameButton(0, 0, "Play", goPlay, GameButton.STYLE_BLUE, false, 160,40); //new FlxButton(0, 0, "Play", goPlay);
		_btnPlay.x = (FlxG.width/2)-192;
		_btnPlay.y = FlxG.height - _btnPlay.height - 16;
		_btnPlay.alpha = 0;
		_btnPlay.active = false;
		add(_btnPlay);
		
		_btnCredits = new GameButton(0, 0, "Credits", goCredits, GameButton.STYLE_BLUE, false, 160,40); //new FlxButton(0, 0, "Play", goPlay);
		_btnCredits.x = (FlxG.width/2)+32;
		_btnCredits.y = FlxG.height - _btnCredits.height - 16;
		_btnCredits.alpha = 0;
		_btnCredits.active = false;
		add(_btnCredits);
		
		FlxG.sound.playMusic("title-a", 1, false);
		FlxG.sound.music.onComplete = musicFirstDone;
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR*2, true, doneFadeIn);
		_loading = false;
		super.create();
	}
	
	private function musicFirstDone():Void
	{
		if(!_leaving)
			FlxG.sound.playMusic("title-b", 1, true);
	}
	
	private function doneFadeIn():Void
	{
		FlxTimer.start(1, doneStartWait);
	}
	
	private function doneStartWait(T:FlxTimer):Void
	{
		var _lTween:FlxTween = FlxTween.tween(_sprBonesLight, {alpha:1}, .1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneLightOne } );
	}
	
	private function goPlay():Void
	{
		if (_btnPlay.alpha >= 1 && !_leaving && !_loading)
		{
			_leaving = true;
			FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR*4, false, doneGoPlay);
			FlxG.sound.music.fadeOut(Reg.FADE_DUR*4);
		}
	}
	
	private function goCredits():Void
	{
		if (_btnCredits.alpha >= 1 && !_leaving && !_loading)
		{
			_leaving = true;
			FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR*4, false, doneGoCredits);
			FlxG.sound.music.fadeOut(Reg.FADE_DUR*4);
		}
	}
	
	private function doneGoCredits():Void
	{
		FlxG.switchState(new CreditState());
	}
	
	private function doneGoPlay():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function doneLightOne(T:FlxTween):Void
	{
		
		var _lTween:FlxTween = FlxTween.tween(_sprBonesLight, {alpha:0}, .1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneLightTwo } );
	}
	
	
	private function doneLightTwo(T:FlxTween):Void
	{
		if (_shownText)
			FlxG.sound.play("sounds/thunder.wav",.66);
		var _lTween:FlxTween = FlxTween.tween(_sprBonesLight, {alpha:1}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneLightThree } );
	}
	
	
	private function doneLightThree(T:FlxTween):Void
	{
		
		var _lTween:FlxTween = FlxTween.tween(_sprBonesLight, {alpha:0}, 2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneLightFour } );
	}
	
	private function doneLightFour(T:FlxTween):Void 
	{
		var gTween:FlxTween = FlxTween.tween(_sprGhost01,{alpha:.8}, 1, { type:FlxTween.ONESHOT, ease:FlxEase.bounceIn, complete:doneGhostIn } );
	}
	
	private function doneGhostIn(T:FlxTween):Void
	{
		var gTween:FlxTween = FlxTween.tween(_sprGhost01, {alpha:0}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostOneOut } );
	}
	
	private function doneGhostOneOut(T:FlxTween):Void
	{
		var gTween:FlxTween = FlxTween.tween(_sprGhost02, {alpha:.8}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostTwoIn } );
	}
	
	private function doneGhostTwoIn(T:FlxTween):Void
	{

		var gTween:FlxTween = FlxTween.tween(_sprGhost02, {alpha:0}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostTwoOut } );
		if (!_shownText)
		{
			_shownText = true;
			var tTween:FlxTween = FlxTween.tween(_textMainWave, { alpha:.9, center:_textMainWave.height*.33, strength: 40, y:-16}, 4, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:textMainBob } );
			
			FlxTimer.start(.33, startSubTextIn);
			FlxTimer.start(.66, startButtonIn);
		}
	}
	
	private function textMainBob(T:FlxTween):Void
	{
		FlxTween.tween(_textMainWave, { alpha:.66 }, 3, { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
		FlxTween.tween(_textMainWave, { y:0 }, 2, { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
		FlxTween.tween(_textMainWave, {center:_textMain.height*.5}, 4,{ type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
		FlxTween.tween(_textMainWave, {strength:20}, 3,{ type:FlxTween.PINGPONG, ease:FlxEase.backInOut } );
	}
	
	
	private function doneGhostTwoOut(T:FlxTween):Void
	{

		var gTween:FlxTween = FlxTween.tween(_sprGhost03, {alpha:.8}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostThreeIn } );
		
	}
	
	private function startSubTextIn(T:FlxTimer):Void
	{
		var tTween:FlxTween = FlxTween.tween(_textSub, {alpha:.98}, 4, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:textSubBob } );
	}
	
	private function textSubBob(T:FlxTween):Void
	{
		FlxTween.tween(_textSub.scale, { x:.9, y:.9 }, 1.66, { type:FlxTween.PINGPONG, ease:FlxEase.backInOut } );
		FlxTween.tween(_textSub, { alpha:.8 }, 3, { type:FlxTween.PINGPONG, ease:FlxEase.sineInOut } );
		
	}
	
	private function startButtonIn(T:FlxTimer):Void
	{
		_btnPlay.autoCenterLabel();
		_btnCredits.autoCenterLabel();
		_btnPlay.update();
		_btnCredits.update();
		FlxTween.tween(_btnPlay, {alpha:1}, 2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut } );
		FlxTween.tween(_btnCredits, { alpha:1 }, 2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut } );
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
	}
	
	
	private function doneGhostThreeIn(T:FlxTween):Void
	{
		if (_shownText)
		{
			FlxG.sound.play("sounds/roar.wav", .66, false, true, doneRoar);
			FlxG.camera.shake(0.005, 2,null,true,FlxCamera.SHAKE_VERTICAL_ONLY);
		}
		else
		{
			FlxG.camera.shake(0.02, 2,null,true,FlxCamera.SHAKE_VERTICAL_ONLY);
		}
		FlxTimer.start(1.3, doneGhostFinalIn);
		
		
	}
	
	private function doneRoar():Void
	{
		FlxG.camera.shake(0, 0);
		
	}
	
	private function doneGhostFinalIn(T:FlxTimer):Void
	{
		var gTween:FlxTween = FlxTween.tween(_sprGhost03, {alpha:0},2,{ type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostOut } );
	}
	
	private function doneGhostOut(T:FlxTween):Void
	{
		FlxTimer.start(6, doneStartWait);
	}
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_textMain = FlxDestroyUtil.destroy(_textMain);
		_sprBones = null;
		_sprBonesLight = null;
		_sprGhost01 = null;
		_sprGhost02 = null;
		_sprGhost03 = null;
		
		_textSub = null;
		_textMainWave = null;
		_text1Glow = null;
		_text2Glow = null;
		_text1Filter = null;
		_text2Filter = null;

		_btnPlay = null;
		_btnCredits = null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (!_btnCredits.active)
			if (_btnCredits.alpha >= 1)
				_btnCredits.active = true;
		if (!_btnPlay.active)
			if (_btnPlay.alpha >= 1)
				_btnPlay.active = true;
		super.update();
		_text1Filter.applyFilters();
		_text2Filter.applyFilters();
	}	
}