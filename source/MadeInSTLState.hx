package ;

import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class MadeInSTLState extends FlxState
{

	private var _sprArch:FlxSprite;
	private var _txtText:GameFont;
	private var _txtWave:FlxWaveSprite;
	private var _sprArchWave:FlxWaveSprite;
	private var _startYA:Float;
	private var _startYB:Float;
	
	override public function create():Void 
	{
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		FlxG.autoPause = false;
		
		bgColor = FlxColor.BLACK;
		
		_sprArch = new FlxSprite(0, 0, "images/arch.png");
		FlxSpriteUtil.screenCenter(_sprArch);
		_sprArchWave = new FlxWaveSprite(_sprArch, FlxWaveSprite.MODE_ALL, 500);
		_sprArchWave.alpha = 0;
		add(_sprArchWave);
		
		_txtText = new GameFont(0, 0, "Made in Saint Louis", GameFont.STYLE_HUGE_TITLE, GameFont.COLOR_CYAN, "center",100);
		FlxSpriteUtil.screenCenter(_txtText, true, false);
		_txtText.y = _sprArch.y - (_txtText.height *.25) + _sprArch.height - _txtText.height;
		_txtWave = new FlxWaveSprite(_txtText, FlxWaveSprite.MODE_BOTTOM, 500,0);
		_txtWave.alpha = 0;
		add(_txtWave);
		
		_startYA = _sprArchWave.y;
		_sprArchWave.y += 40;
		_startYB = _txtWave.y;
		_txtWave.y += 40;
		
		FlxTimer.start(1, doFirstFlash);
		
		super.create();
	}
	
	private function doFirstFlash(T:FlxTimer):Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxG.camera.flash(FlxColor.WHITE, .66, doneFirstFlash);
	}
	
	private function doneFirstFlash():Void
	{
		FlxG.sound.play("sounds/thunder.wav");
		FlxG.camera.flash(FlxColor.WHITE, 1.33, doneSecondFlash);
	}
	
	private function doneSecondFlash():Void
	{
		
		FlxTween.tween(_sprArchWave, { alpha:1, strength:0, y:_startYA }, 1, { type:FlxTween.ONESHOT, ease:FlxEase.sineInOut } );
		FlxTimer.start(.66, doTextIn);
	}
	
	private function doTextIn(T:FlxTimer):Void
	{
		FlxG.sound.play("sounds/madeinstl.wav", 1, false, true,doneMadeInSound);
		FlxTween.tween(_txtWave, { alpha:.8, strength:20, center:_txtText.height * .33, y:_startYB }, 1, { type:FlxTween.ONESHOT, ease:FlxEase.sineInOut } );
	}
	
	private function doneMadeInSound():Void
	{
		FlxTimer.start(1, goFadeOut);
	}
	
	private function goFadeOut(T:FlxTimer):Void
	{
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR * 2, false, doneFadeOut);
	}
	
	private function doneFadeOut():Void
	{
		FlxG.switchState(new MenuState());
	}
	
}