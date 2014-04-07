package ;
import flixel.addons.tile.FlxTileSpecial.AnimParams;
import flixel.addons.ui.FlxUITypedButton;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
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
	
	public static var commandList:Array<String>;
	
	private static var _selButton:Int = -1;
	
	private static var _uis:Array<IUIElement>;
	
	public static inline var INPUT_DELAY:Float = .1;
	
	private static var _pressDelay:Float = .5;
	public static var  canInteract:Bool = false;
	
	#if !FLX_NO_KEYBOAD
	public static var keys:Array<Array<String>>;
	private static var _defaultKeys:Array<Array<String>>;
	#end
	
	#if !FLX_NO_GAMEPAD
	static public var hasGamepad:Bool = false;
	static public var gamepad:FlxGamepad = null;
	public static var buttons:Array<Array<Int>>;
	public static var idStringMap = new Map<Int, String>();
	private static var _defaultBtns:Array<Array<Int>>;
	#end
	
	#if !FLX_NO_MOUSE
	static public inline var MOUSE_SLEEP:Float = 3;
	static public var lastMouseMove:Float=0;
	static public var lastMousePos:FlxPoint;
	#end
	
	public static function init() 
	{
		buildCommandList();
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
		_defaultKeys = keys.copy();
		#end
		#if !FLX_NO_GAMEPAD
		buttons = [];
		buildButtonStrings();
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
		_defaultBtns = buttons.copy();
		#end
		#if !FLX_NO_MOUSE
		lastMouseMove = 0;
		lastMousePos = FlxPoint.get();
		#end
		_uis = new Array<IUIElement>();
		Reg.save.bind("flixel");
		#if !FLX_NO_KEYBOARD
		if (Reg.save.data.keys != null)
			keys = Reg.save.data.keys;
		#end
		#if !FLX_NO_GAMEPAD
		if (Reg.save.data.buttons != null)
			buttons = Reg.save.data.buttons;
		#end
		Reg.save.close;
	}
	
	public static function resetBindings():Void
	{
		#if !FLX_NO_KEYBOARD
		keys = _defaultKeys.copy();
		#end
		#if !FLX_NO_GAMEPAD
		buttons = _defaultBtns.copy();
		#end
	}
	
	private static function buildCommandList():Void
	{
		commandList = new Array<String>();
		commandList.push("LEFT");
		commandList.push("RIGHT");
		commandList.push("UP");
		commandList.push("DOWN");
		commandList.push("FIRE");
		commandList.push("PAUSE");
	}
	#if !FLX_NO_KEYBOARD
	public static function remapKey(CommandNo:Int, NewKey:String):Void
	{
		for (k in keys)
		{
			k.remove(NewKey);
		}
		keys[CommandNo].push(NewKey);
		keys[SELRIGHT] = keys[RIGHT].concat(keys[DOWN]);
		keys[SELLEFT] = keys[LEFT].concat(keys[UP]);
	}
	#end
	#if !FLX_NO_GAMEPAD
	public static function remapButton(CommandNo:Int, NewButton:Int):Void
	{
		for (b in buttons)
		{
			b.remove(NewButton);
		}
		buttons[CommandNo].push(NewButton);
		buttons[SELRIGHT] = buttons[RIGHT].concat(buttons[DOWN]);
		buttons[SELLEFT] = buttons[LEFT].concat(buttons[UP]);
	}
	#end
	
	private static function buildButtonStrings():Void
	{
		var buttons:Array<String> = Type.getClassFields(LogitechButtonID);
		var value:Int;
		for (field in buttons)
		{
			value = cast Reflect.getProperty(LogitechButtonID, field);
			idStringMap.set(value, field);
		}
	}
	
	public static function getKeyList(KeyValue:Int):String
	{
		var strList:String = keys[KeyValue].join(", ");
		return strList;
	}
	
	public static function getButtonList(BtnValue:Int):String
	{
		var isFirst:Bool = true;
		var strList:String = "";
		for (b in buttons[BtnValue])
		{
			strList += (!isFirst ? ', ' : '') + idStringMap[b];
			isFirst = false;
		}
		return strList;
		
	}
	
	public static function newState(Buttons:Array<IUIElement>):Void
	{
		_selButton = -1;
		_uis = Buttons;
		canInteract = false;
	}
	
	public static function changeUIs(UIs:Array<IUIElement>):Void
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
					lastMouseMove = 0;
					FlxG.mouse.visible = false;
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
		if (FlxG.mouse.visible)
		{
			var overAny:Bool = false;
			for (i in 0..._uis.length)
			{
				
				if (_uis[i].overlapsPoint(FlxG.mouse))
				{
					_selButton = i;
					overAny = true;
				}
			}
			if (!overAny)
				_selButton = -1;
		}
	}
	#end
}