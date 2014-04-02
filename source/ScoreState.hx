package ;

import flixel.addons.effects.FlxWaveSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class ScoreState extends FlxState
{
	
	private var _loading:Bool = true;
	private var _leaving:Bool = false;
	private var btnPlayAgain:GameButton;
	private var btnMenu:GameButton;

	override public function create():Void 
	{
		FlxG.autoPause = false;
		
		var margin:Int = 256;
		var buffer:Int = 30;
		
		add( new FlxSprite(0, 0, "images/title-back.png"));
		add( new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x99000000));
		
		var txtGameOver:GameFont = new GameFont(0, 16, "GAME OVER!", GameFont.STYLE_BIG_TITLE, GameFont.COLOR_CYAN, "center");
		FlxSpriteUtil.screenCenter(txtGameOver, true, false);
		var txtGOWave:FlxWaveSprite = new FlxWaveSprite(txtGameOver,WaveMode.BOTTOM);
		add(txtGOWave);
		
		var txtScoreHead:GameFont = new GameFont(0, txtGameOver.y + txtGameOver.height + 16, "Your Score", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEBLUE, "center", 36);
		FlxSpriteUtil.screenCenter(txtScoreHead, true, false);
		add(txtScoreHead);
		
		var txtBuildings1:GameFont = new GameFont(margin, txtScoreHead.y + txtScoreHead.height + 16, "Buildings Smashed ", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(txtBuildings1);
		var txtBuildings2:GameFont = new GameFont(0,txtBuildings1.y, StringTools.lpad(" " + Std.string(Reg.scores[Reg.SCORE_BUILDINGS]), ".", buffer), GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		txtBuildings2.x = FlxG.width - txtBuildings2.width - margin;
		add(txtBuildings2);
		
		var txtTanks1:GameFont = new GameFont(margin, txtBuildings1.y + txtBuildings1.height + 8, "Tanks Stomped ", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(txtTanks1);
		var txtTanks2:GameFont = new GameFont(0,txtTanks1.y, StringTools.lpad(" " + Std.string(Reg.scores[Reg.SCORE_TANKS]), ".", buffer), GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		txtTanks2.x = FlxG.width - txtTanks2.width - margin;
		add(txtTanks2);
		
		var txtCopters1:GameFont = new GameFont(margin, txtTanks1.y + txtTanks1.height + 8, "Copters Swatted ", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		add(txtCopters1);
		var txtCopters2:GameFont = new GameFont(0,txtCopters1.y, StringTools.lpad(" " + Std.string(Reg.scores[Reg.SCORE_COPTERS]), ".", buffer), GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		txtCopters2.x = FlxG.width - txtCopters2.width - margin;
		add(txtCopters2);
		
		var txtTotal1:GameFont = new GameFont(margin, txtCopters1.y + txtCopters1.height + 16, "Total Score ", GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 32);
		add(txtTotal1);
		var txtTotal2:GameFont = new GameFont(0,txtTotal1.y, StringTools.lpad(" " + Std.string(Reg.score), ".", buffer), GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEGOLD, "right", 24);
		txtTotal2.x = FlxG.width - txtTotal2.width - margin;
		add(txtTotal2);
		
		btnPlayAgain = new GameButton(0, 0, "Play Again", goAgain, GameButton.STYLE_GREEN, false, 260,40);
		btnMenu = new GameButton(0, 0, "Main Menu", goMenu, GameButton.STYLE_RED, false, 260,40);
		btnPlayAgain.x = (FlxG.width / 2) - 300;
		btnPlayAgain.y = FlxG.height - 56;
		btnMenu.x = (FlxG.width / 2) + 40;
		btnMenu.y = FlxG.height - 56;
		add(btnPlayAgain);
		add(btnMenu);
		
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, true, doneFadeIn);
		FlxG.sound.playMusic("score");
		super.create();
	}
	
	private function doneFadeIn():Void
	{
		_loading = false;
	}
	
	private function goAgain():Void
	{
		if (_loading || _leaving)
			return;
		_leaving = true;
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, false, doneGoAgain);
		FlxG.sound.music.fadeOut(Reg.FADE_DUR);
	}
	
	private function doneGoAgain():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function goMenu():Void
	{
		if (_loading || _leaving)
			return;
		_leaving = true;
		FlxG.camera.fade(FlxColor.BLACK, Reg.FADE_DUR, false, doneGoMenu);
		FlxG.sound.music.fadeOut(Reg.FADE_DUR);
	}
	
	private function doneGoMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
	override public function update():Void 
	{
		super.update();
		if (_loading || _leaving)
		{
			btnMenu.active = false;
			btnPlayAgain.active = false;
		}
		else if (!btnMenu.active || !btnPlayAgain.active)
		{
			btnPlayAgain.active = true;
			btnMenu.active = true;
		}
	}
	override public function destroy():Void 
	{
		super.destroy();
		btnMenu = null;
		btnPlayAgain = null;
	}
}