package ;
import flixel.addons.tile.FlxTileSpecial.AnimParams;
import flixel.addons.ui.FlxUITypedButton;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.LogitechButtonID;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;

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
	
	private static var _selButton:Int = -1;
	
	private static var _uis:Array<Dynamic>;
	
	public static inline var INPUT_DELAY:Float = .1;
	
	private static var _pressDelay:Float = .5;
	public static var  canInteract:Bool = false;
	
	#if !FLX_NO_KEYBOAD
	public static var keys:Array<Array<String>>;
	#end
	
	#if !FLX_NO_GAMEPAD
	static public var hasGamepad:Bool = false;
	static public var gamepad:FlxGamepad = null;
	public static var buttons:Array<Array<Int>>;
	#end
	
	#if !FLX_NO_MOUSE
	static public inline var MOUSE_SLEEP:Float = 3;
	static public var lastMouseMove:Float=0;
	static public var lastMousePos:FlxPoint;
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
		#if flash
		buttons[LEFT] = [LogitechButtonID.DPAD_LEFT];
		buttons[RIGHT] = [LogitechButtonID.DPAD_RIGHT];
		buttons[UP] = [LogitechButtonID.DPAD_UP];
		buttons[DOWN] = [LogitechButtonID.DPAD_DOWN];
		#else
		buttons[LEFT] = [-1];
		buttons[RIGHT] = [-1];
		buttons[UP] = [-1];
		buttons[DOWN] = [-1];
		#end
		buttons[SELRIGHT] = buttons[RIGHT].concat(buttons[DOWN]);
		buttons[SELLEFT] = buttons[LEFT].concat(buttons[UP]);
		buttons[FIRE] = [LogitechButtonID.ONE, LogitechButtonID.TWO];
		buttons[PAUSE] = [LogitechButtonID.TEN];
		buttons[BACK] = [LogitechButtonID.NINE];
		
		
		#end
		#if !FLX_NO_MOUSE
		lastMouseMove = 0;
		lastMousePos = FlxPoint.get();
		#end
		_uis = new Array<Dynamic>();
	}
	
	public static function newState(Buttons:Array<Dynamic>):Void
	{
		_selButton = -1;
		_uis = Buttons;
		canInteract = false;
	}
	
	public static function changeUIs(UIs:Array<Dynamic>):Void
	{
		if (_uis != null)
		{
			if (_uis.length > 0)
			{
				for (b in _uis)
				{
					b.selected = false;
					b.toggled = false;
				}
			
			}
		}
		
		_uis = UIs;
		_selButton = -1;
	}
	
	public static function checkScreenControls():Void
	{
		#if !FLX_NO_MOUSE
		GameControls.updateMouse();
		#end
		
		var leftPressed:Bool = false;
		var upPressed:Bool = false;
		var rightPressed:Bool = false;
		var downPressed:Bool = false;
		var xPressed:Bool = false;
		
		if (_pressDelay > 0)
			_pressDelay -= FlxG.elapsed;
		if (_pressDelay <= 0 && canInteract)
		{
			#if !FLX_NO_KEYBOARD
			if (FlxG.keys.anyPressed(keys[SELRIGHT]))
			{
				rightPressed = downPressed = true;
				FlxG.keys.reset();
			}
			else if (FlxG.keys.anyPressed(keys[SELLEFT]))
			{
				leftPressed = upPressed = true;
				FlxG.keys.reset();
			}
			if (FlxG.keys.anyPressed(keys[FIRE]))
			{
				xPressed = true;
				FlxG.keys.reset();
			}
			#end
			
			#if !FLX_NO_GAMEPAD
			if (hasGamepad)
			{
				#if !flash
				if (gamepad.dpadRight || gamepad.dpadDown)
				{
					rightPressed = downPressed = true;
					gamepad.reset();
				}
				else if (gamepad.dpadLeft || gamepad.dpadUp)
				{
					leftPressed = upPressed = true;
					gamepad.reset();
				}
				#else
				if (gamepad.anyPressed(buttons[SELRIGHT]))
				{
					rightPressed = downPressed = true;
					gamepad.reset();
				}
				else if (gamepad.anyPressed(buttons[SELLEFT]))
				{
					leftPressed = upPressed = true;
					gamepad.reset();
				}
				#end
				if (gamepad.anyPressed(buttons[FIRE]))
				{
					xPressed = true;
					gamepad.reset();
				}
			}
			else
			{
				gamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
				{
					hasGamepad = true;
					
				}
			}
			#end
			if (_selButton == -1)
			{
				if (xPressed || rightPressed || leftPressed || downPressed || upPressed)
				{
					_pressDelay = INPUT_DELAY;
					_selButton=0;
				}
			}
			else
			{
				if (_uis.length > 0)
				{
					if (xPressed)
					{
						_uis[_selButton].forceStateHandler(FlxUITypedButton.CLICK_EVENT);
						_pressDelay = INPUT_DELAY;
						
					}
					else if (rightPressed || downPressed || leftPressed || upPressed)
					{
						_pressDelay = INPUT_DELAY;
						if (!_uis[_selButton].toggled)
						{
							if (rightPressed || downPressed)
							{
								
								_selButton++;
								if (_selButton >= _uis.length)
									_selButton = 0;
							}
							else if (leftPressed || upPressed)
							{
								_selButton--;
								if (_selButton < 0)
									_selButton = _uis.length-1;
							}
						}
						else
						{
							if (rightPressed || downPressed)
							{
								cast(_uis[_selButton], FakeUIElement).input(SELRIGHT);
							}
							else if (leftPressed || upPressed)
							{
								cast(_uis[_selButton], FakeUIElement).input(SELLEFT);
							}
						}
					}
				}
				
			}
		}
		if (_uis.length > 0)
		{
			for (b in _uis)
				b.selected = false;
			if (_selButton != -1)
			{
				_uis[_selButton].selected = true;
			}
		}
	}
	
	#if !FLX_NO_MOUSE
	public static function updateMouse():Void
	{
		if (FlxG.mouse.x == lastMousePos.x && FlxG.mouse.y == lastMousePos.y)
		{	
			if(lastMouseMove > 0)
				lastMouseMove -= FlxG.elapsed;
		}
		else
		{
			lastMouseMove = MOUSE_SLEEP;
			FlxG.mouse.copyTo(lastMousePos);
			
		}
		if (lastMouseMove > 0)
		{
			if (canInteract)
				FlxG.mouse.visible = true;
		}
		else
		{
			FlxG.mouse.visible = false;
		}
	}
	#end
}