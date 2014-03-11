package;

import flixel.addons.display.FlxGridOverlay;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.Constants.Window;
import openfl.events.JoystickEvent;

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
	
	private var _btnPlay:FlxButton;
	private var _shownText:Bool = false;
	
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		add(FlxGridOverlay.create(32, 32, -1, -1, false, true, 0xff111111, 0xff333333));
		add(FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x0, 0x0, 0xff000000], 1, 90));
		
		
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
		
		_textMain = new GameFont(0, 16, "Dinosaur-Ghost", GameFont.STYLE_HUGE_TITLE, GameFont.COLOR_CYAN);
		FlxSpriteUtil.screenCenter(_textMain, true, false);
		_textMain.alpha = 0;
		add(_textMain);
		
		_textSub = new GameFont(0, _textMain.y+_textMain.height-16,  "RAMPAGE", GameFont.STYLE_BIG_TITLE, GameFont.COLOR_RED);
		FlxSpriteUtil.screenCenter(_textSub, true, false);
		_textSub.alpha = 0;
		add(_textSub);
		
		_btnPlay = new FlxButton(0, 0, "Play", goPlay);
		_btnPlay.y = FlxG.height - _btnPlay.height - 16;
		FlxSpriteUtil.screenCenter(_btnPlay, true, false);
		_btnPlay.alpha = 0;
		add(_btnPlay);
		
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR*2, true, doneFadeIn);
		
		super.create();
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
		FlxG.switchState(new PlayState());
		
	}
	
	private function doneLightOne(T:FlxTween):Void
	{
		
		var _lTween:FlxTween = FlxTween.tween(_sprBonesLight, {alpha:0}, .1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneLightTwo } );
	}
	
	
	private function doneLightTwo(T:FlxTween):Void
	{
		FlxG.sound.play("sounds/thunder.wav");
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
			var tTween:FlxTween = FlxTween.tween(_textMain, {alpha:1}, 1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut } );
			FlxTimer.start(.33, startSubTextIn);
			FlxTimer.start(.66, startButtonIn);
		}
	}
	
	
	private function doneGhostTwoOut(T:FlxTween):Void
	{

		var gTween:FlxTween = FlxTween.tween(_sprGhost03, {alpha:.8}, .2, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut, complete:doneGhostThreeIn } );
		
	}
	
	private function startSubTextIn(T:FlxTimer):Void
	{
		var tTween:FlxTween = FlxTween.tween(_textSub, {alpha:1}, 1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut } );
	}
	private function startButtonIn(T:FlxTimer):Void
	{
		var tTween:FlxTween = FlxTween.tween(_btnPlay, {alpha:1}, 1, { type:FlxTween.ONESHOT, ease:FlxEase.quartInOut } );
	}
	
	
	private function doneGhostThreeIn(T:FlxTween):Void
	{
		FlxG.sound.play("sounds/roar.wav", 1, false, true, doneRoar);
		FlxG.camera.shake(0.025, 2,null,true,FlxCamera.SHAKE_VERTICAL_ONLY);
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
		FlxTimer.start(4, doneStartWait);
	}
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}