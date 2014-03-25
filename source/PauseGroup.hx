package ;


import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;


class PauseGroup extends FlxGroup
{

	private var _loading:Bool = false;
	private var _leaving:Bool = false;
	private var _back:FlxSprite;
	private var _backWav:FlxWaveSprite;
	private var _alpha:Float = 0;
	public var shown(default, null):Bool = false;
	
	private var _txt:GameFont;
	private var _txtWave:FlxWaveSprite;
	private var _btnResume:GameButton;
	private var _btnQuit:GameButton;
	
	private var _btnYes:GameButton;
	private var _btnNo:GameButton;
	private var _txtConfirm:GameFont;
	
	public function new() 
	{
		super();
		
		_back = new FlxSprite();
		_back.makeGraphic(FlxG.width+64, FlxG.height+64, 0xff000000);
		
		FlxSpriteUtil.screenCenter(_back);
		
		_backWav = new FlxWaveSprite(_back, FlxWaveSprite.MODE_ALL, 4);

		_txt = new GameFont(0, 16, "PAUSED", GameFont.STYLE_BIG_TITLE, GameFont.COLOR_CYAN, "center");
		FlxSpriteUtil.screenCenter(_txt, true, false);
		_txtWave = new FlxWaveSprite(_txt,FlxWaveSprite.MODE_BOTTOM);

		add(_backWav);
		add(_txtWave);
	
		_back.scrollFactor.set();
		_backWav.scrollFactor.set();
		_txt.scrollFactor.set();
		_txtWave.scrollFactor.set();
		
		_btnResume = new GameButton(0, (FlxG.height/2)- 56, "Resume", goResume, GameButton.STYLE_GREEN, false, 160, 40);
		FlxSpriteUtil.screenCenter(_btnResume, true, false);
		add(_btnResume);
		_btnQuit = new GameButton(0, (FlxG.height/2)+16, "Quit", goQuit, GameButton.STYLE_RED, false, 160, 40);
		FlxSpriteUtil.screenCenter(_btnQuit, true, false);
		add(_btnQuit);
		
		
		_txtConfirm = new GameFont(0, (FlxG.height / 2) - 100, "Are you sure you want to Quit?", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLERED, "center", 30);
		FlxSpriteUtil.screenCenter(_txtConfirm, true, false);
		_txtConfirm.scrollFactor.set();
		add(_txtConfirm);
		
		_btnNo = new GameButton(0, (FlxG.height/2)- 56, "No", goNo, GameButton.STYLE_GREEN, false, 160, 40);
		FlxSpriteUtil.screenCenter(_btnNo, true, false);
		add(_btnNo);
		_btnYes = new GameButton(0, (FlxG.height/2)+16, "Yes", goYes, GameButton.STYLE_RED, false, 160, 40);
		FlxSpriteUtil.screenCenter(_btnYes, true, false);
		add(_btnYes);
		
		_back.alpha = _backWav.alpha = _btnQuit.alpha = _btnResume.alpha = _txt.alpha = _txtWave.alpha = _txtConfirm.alpha = _alpha = 0;
		_btnNo.visible = _btnYes.visible = _txtConfirm.visible = false;
		active = false;
		update();
		
	}
	
	private function goYes():Void
	{
		if (_loading || _leaving)
			return;
		_leaving = true;
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, true, doneFadeQuit);
	}
	
	private function doneFadeQuit():Void
	{
		FlxG.switchState(new MenuState());
	}
	
	private function goNo():Void
	{
		if (_loading || _leaving)
			return;
		_btnNo.visible = _btnYes.visible = _txtConfirm.visible = false;
		_btnQuit.visible = _btnResume.visible = true;
	}
	
	public function show():Void
	{
		//grab image
		#if flash
		_back.pixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point(32, 32));
		#else
		_back.pixels.draw(FlxG.camera.canvas,new Matrix(1,0,0,1,32,32));
		#end
		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		_back.pixels.applyFilter(_back.pixels, _back.pixels.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
		
		_back.resetFrameBitmapDatas();
		_back.dirty = true;
		
		FlxTween.tween(this, {_alpha:1}, Reg.FADE_DUR*2, { type:FlxTween.ONESHOT, ease:FlxEase.circIn, complete:doneFadeIn } );
		active = true;
		_loading = true;
		_leaving = false;
		shown = true;
	}
	
	private function doneFadeIn(T:FlxTween):Void
	{
		
		_loading = false;
	}
	
	public function hide():Void
	{
		if (_loading || _leaving)
		{
			return;
		}
		_leaving = true;
		FlxTween.tween(this, {_alpha:0}, Reg.FADE_DUR*2, { type:FlxTween.ONESHOT, ease:FlxEase.circIn, complete:doneFadeOut } );
	}
	
	private function goResume():Void
	{
		hide();
	}
	
	private function doneFadeOut(T:FlxTween):Void
	{
		shown = false;
		//update();
		active = false;
		
	}
	
	private function goQuit():Void
	{
		if (_loading || _leaving)
			return;
		_btnQuit.visible = _btnResume.visible = false;
		_btnNo.visible = _btnYes.visible = _txtConfirm.visible = true;
	}
	
	override public function update():Void 
	{
		
		if (_back.alpha != _alpha)
			_back.alpha = _backWav.alpha = _btnQuit.alpha = _btnResume.alpha = _txt.alpha = _txtWave.alpha = _txtConfirm.alpha = _alpha;
		
		if (!shown || !active || !visible)
			return;
		super.update();
	}
	
	override public function draw():Void 
	{
		if (!shown || !active || !visible)
			return;
		super.draw();
	}
	
}