package;

import flash.text.Font;
import flixel.FlxG;
import flixel.util.FlxSave;
@:font("assets/fonts/gomarice_kaiju_monster.ttf") class FontKaiju extends Font { }
@:font("assets/fonts/scary.TTF") class FontScary extends Font { }
@:font("assets/fonts/04B_03__.TTF") class FontPixel extends Font { }
@:font("assets/fonts/kenpixel_mini.ttf") class FontKPixelMini extends Font { }

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	
	
	/**
	 * Assets
	*/
	
	// Fonts
	public static var FONT_BIG:String = "fonts/gomarice_kaiju_monster.ttf";
	public static var FONT_SCARY:String = "fonts/scary.TTF";
	public static var FONT_PIXEL:String = "fonts/04B_03__.TTF";
	public static var FONT_KPIXELMINI:String = "fonts/kenpixel_mini.ttf";
	
	//Images
	public static inline var TANK_GIBS:String = "images/tank-gibs.png";
	
	
	
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	static public var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	static public var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	static public var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	static public var score:Int = 0;
	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	static public var save:FlxSave;// = [];
	
	static public inline var FADE_DUR:Float = 0.3;
	static public var playState:PlayState;
	
	
	
	static public var GameInitialized:Bool = false;
	#if desktop
	static public var IsFullscreen:Bool;
	#end
	
	static public var EMITTER_EXPLOSION:Int = 0;
	
	public static function initGame():Void
	{
		if (GameInitialized)
			return;
		
		Font.registerFont(FontKaiju);
		Font.registerFont(FontScary);
		Font.registerFont(FontPixel);
		Font.registerFont(FontKPixelMini);
		
		loadData();
		
		GameInitialized = true;
	}
	
	public static function loadData():Void
	{
		save = new FlxSave();
		save.bind("flixel");
		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}
		else
			FlxG.sound.volume = 1;
		
		#if desktop
		IsFullscreen = (save.data.fullscreen != null) ? save.data.fullscreen : true;
		//screensize = (save.data.screensize != null) ? save.data.screensize : SIZE_LARGE;
		#end

		save.close();
		
	}
	
}