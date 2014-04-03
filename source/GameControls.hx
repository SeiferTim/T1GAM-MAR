package ;
import flixel.addons.tile.FlxTileSpecial.AnimParams;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.LogitechButtonID;
import flixel.util.FlxArrayUtil;

class GameControls
{

	public static inline var LEFT:Int = 0;
	public static inline var RIGHT:Int = 1;
	public static inline var UP:Int = 2;
	public static inline var DOWN:Int = 3;
	
	public static inline var FIRE:Int = 4;
	public static inline var PAUSE:Int = 5;
	public static inline var BACK:Int = 6;
	
	public static inline var SELRIGHT:Int = 7;
	public static inline var SELLEFT:Int = 8;
	
	#if !FLX_NO_KEYBOAD
	public static var keys:Array<Array<String>>;
	#end
	
	#if !FLX_NO_GAMEPAD
	static public var hasGamepad:Bool = false;
	static public var gamepad:FlxGamepad = null;
	public static var buttons:Array<Array<Int>>;
	#end
	
	public static function init() 
	{
		#if !FLX_NO_KEYBOAD
		keys = [];
		keys[LEFT] = ["LEFT", "A"];
		keys[RIGHT] = ["RIGHT", "D"];
		keys[UP] = ["UP", "W"];
		keys[DOWN] = ["DOWN", "S"];
		keys[FIRE] = ["X", "SPACE"];
		keys[PAUSE] = ["P", "ESCAPE"];
		keys[BACK] = ["ESCAPE"];
		keys[SELRIGHT] = keys[RIGHT].concat(keys[DOWN]);
		keys[SELLEFT] = keys[LEFT].concat(keys[UP]);
		#end
		#if !FLX_NO_GAMEPAD
		buttons = [];
		buttons[LEFT] = [LogitechButtonID.DPAD_LEFT];
		buttons[RIGHT] = [LogitechButtonID.DPAD_RIGHT];
		buttons[UP] = [LogitechButtonID.DPAD_UP];
		buttons[DOWN] = [LogitechButtonID.DPAD_DOWN];
		buttons[FIRE] = [LogitechButtonID.ONE, LogitechButtonID.TWO];
		buttons[PAUSE] = [LogitechButtonID.SEVEN];
		buttons[BACK] = [LogitechButtonID.THREE];
		buttons[SELRIGHT] = buttons[RIGHT].concat(buttons[DOWN]);
		buttons[SELLEFT] = buttons[LEFT].concat(buttons[UP]);
		#end
	}
	
}