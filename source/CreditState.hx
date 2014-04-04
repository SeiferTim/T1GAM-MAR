package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class CreditState extends FlxState
{
	private var _loading:Bool = true;
	private var _leaving:Bool = false;
	private var _btnBack:GameButton;
	private var _hfLogo:FlxSprite;
	
	override public function create():Void 
	{
		FlxG.autoPause = false;
		
		add( new FlxSprite(0, 0, "images/title-back.png"));
		add( new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x99000000));
		
		
		var _t1:GameFont = new GameFont(0, 8, "This game was made as part of", GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLERED,"center",20);
		FlxSpriteUtil.screenCenter(_t1, true, false);
		add(_t1);
		
		var _t2:GameFont = new GameFont(0, _t1.y + _t1.height + 4, "Tim's 1-Game-a-Month Project", GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLEGOLD,"center",28);
		FlxSpriteUtil.screenCenter(_t2, true, false);
		add(_t2);
		
		var _t3:LinkText = new LinkText(0, _t2.y + _t2.height + 4, "t1gam.tims-world.com", clickT1GamLink,"center", 20);
		FlxSpriteUtil.screenCenter(_t3, true, false);
		var _ui3:FakeUIElement = new FakeUIElement(_t3.x-2,_t3.y-2, Std.int(_t3.width +4), Std.int(_t3.height + 4), clickT1GamLink, null,false);
		add(_ui3);
		add(_t3);
		
		var _t4:GameFont = new GameFont(0,_t3.y + _t3.height + 16,"Concept, Programming, Design",GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLERED,"center", 20);
		FlxSpriteUtil.screenCenter(_t4, true, false);
		add(_t4);
		
		var _t5:GameFont = new GameFont(0,_t4.y + _t4.height + 4, "Tim I Hely",GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLEGOLD,28);
		FlxSpriteUtil.screenCenter(_t5, true, false);
		
		add(_t5);
		
		var _t6:LinkText = new LinkText(0, _t5.y + _t5.height + 4, "tims-world.com", clickTimsLink,"center", 20);
		FlxSpriteUtil.screenCenter(_t6, true, false);
		var _ui6:FakeUIElement = new FakeUIElement(_t6.x-2,_t6.y-2, Std.int(_t6.width +4), Std.int(_t6.height + 4), clickTimsLink, null,false);
		add(_ui6);
		add(_t6);
		
		var _t7:GameFont = new GameFont(0,_t6.y + _t6.height + 16,"Music",GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLERED, "center", 20);
		FlxSpriteUtil.screenCenter(_t7, true, false);
		add(_t7);
		
		var _t8:GameFont = new GameFont(0,_t7.y+_t7.height + 4,"Fat Bard", GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLEGOLD,"center", 28);
		FlxSpriteUtil.screenCenter(_t8, true, false);
		add(_t8);
		
		var _t9:LinkText = new LinkText(0, _t8.y + _t8.height + 4, "fatbard.tumblr.com", clickFBLink, "center", 20);
		FlxSpriteUtil.screenCenter(_t9, true, false);
		var _ui9:FakeUIElement = new FakeUIElement(_t9.x-2,_t9.y-2, Std.int(_t9.width +4), Std.int(_t9.height + 4), clickFBLink, null,false);
		add(_ui9);
		add(_t9);
		
		var _t10:GameFont = new GameFont(0,_t9.y+ _t9.height + 16,"Art",GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLERED,"center", 20);
		FlxSpriteUtil.screenCenter(_t10, true, false);
		add(_t10);
		
		var _t11:GameFont = new GameFont(0,_t10.y + _t10.height + 4, "Vicky Hedgecock", GameFont.STYLE_SMSIMPLE,GameFont.COLOR_SIMPLEGOLD, "center", 28);
		FlxSpriteUtil.screenCenter(_t11, true, false);
		add(_t11);
		
		var _t12:GameFont = new GameFont(0, _t11.y + _t11.height + 16, "Andrew-David Jahchan", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "center", 28);
		FlxSpriteUtil.screenCenter(_t12, true, false);
		add(_t12);
		
		var _t13:LinkText = new LinkText(0, _t12.y + _t12.height + 4, "andrewdavid.net", clickADLink, "center", 20);
		FlxSpriteUtil.screenCenter(_t13, true, false);
		var _ui13:FakeUIElement = new FakeUIElement(_t13.x-2,_t13.y-2, Std.int(_t13.width +4), Std.int(_t13.height + 4), clickADLink, null,false);
		add(_ui13);
		add(_t13);
		
		_btnBack = new GameButton(0, 0, "Main Menu", clickMainMenu, GameButton.STYLE_GREEN, true);
		_btnBack.x = FlxG.width - _btnBack.width - 16;
		_btnBack.y = FlxG.height - _btnBack.height - 16;
		add(_btnBack);
		
		GameControls.newState([_btnBack, _ui3, _ui6, _ui9, _ui13]);
		
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, true, doneFadeIn);
		
		super.create();
	}
	
	private function clickFBLink():Void
	{
		FlxG.openURL("http://FatBard.tumblr.com");
	}
	
	private function clickT1GamLink():Void
	{
		FlxG.openURL("http://t1gam.tims-world.com");
	}
	
	private function clickADLink():Void
	{
		FlxG.openURL("http://andrewdavid.net/");
	}
	
	private function clickTimsLink():Void
	{
		FlxG.openURL("http://tims-world.com");
	}
	
	private function doneFadeIn():Void
	{
		_loading = false;
		_btnBack.active = true;
		GameControls.canInteract = true;
	}
	
	private function clickMainMenu():Void
	{
		if (_loading || _leaving)
			return;
		_leaving = true;
		GameControls.canInteract = false;
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, false, doneFadeOut);
		
	}
	
	private function doneFadeOut():Void
	{
		FlxG.switchState(new MenuState());
	}
	
	override public function update():Void 
	{
		GameControls.checkScreenControls();
		super.update();
		if (_loading)
			_btnBack.active = false;
	}
	
	override public function destroy():Void 
	{
		
		super.destroy();
		_btnBack = null;
	}
	
}