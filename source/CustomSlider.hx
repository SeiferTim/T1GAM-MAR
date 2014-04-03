package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

/**
 * A Slider Element - based on code by Gama11 but simplified and changed to work with Touch as well as Mouse.
 * @author SeiferTim
 */
class CustomSlider extends FlxSpriteGroup
{

	/**
	 * The Bar sprite
	 */
	private var _bar:FlxSprite;
	/**
	 * The Handle sprite
	 */
	private var _handle:FlxSprite;
	/**
	 * The current value of the slider
	 */
	private var _value:Float;
	/**
	 * The minimum Value for the slider
	 */
	private var _minValue:Float;
	/**
	 * The maximum Value for the slider
	 */
	private var _maxValue:Float;
	/**
	 * Number of decimals the value can use
	 */
	private var _decimals:Int = 0;
	/**
	 * Callback function, passess Value
	 */
	private var _onClick:Float->Void = null;
	/**
	 * Bar width
	 */
	private var _barWidth:Int;
	/**
	 * Handle width
	 */
	private var _handleWidth:Int;
	/**
	 * Height of the HANDLE
	 */
	private var _handleThickness:Int;
	/**
	 * Height of the BAR
	 */
	private var _barThickness:Int;
	/**
	 * Bar color
	 */
	private var _barColor:Int;
	/**
	 * Handle color
	 */
	private var _handleColor:Int;
	/**
	 * bounds for mouse click/touch
	 */
	private var _bounds:FlxRect;
	/** 
	 * last Position of the slider
	 */ 
	private var _lastPos:Float;
	
	/**
	 * Creates a new <code>CustomSlider</code>.
	 * 
	 * @param	X					x Position
	 * @param	Y					y Position
	 * @param	BarWidth			width of the bar
	 * @param	HandleWidth			width of the handle
	 * @param	BarThickness		height of the bar
	 * @param	HandleThickness		height of the handle
	 * @param	MinValue			minimum value
	 * @param	MaxValue			maximum value
	 * @param	OnClick				callback function - passes value as float
	 * @param	BarColor			bar color
	 * @param	HandleColor			handle color
	 */
	public function new(X:Float = 0, Y:Float = 0, BarWidth:Int = 100, HandleWidth:Int = 16, BarThickness:Int = 8, HandleThickness:Int = 16, MinValue:Float = 0, MaxValue:Float = 1, OnClick:Float->Void = null, BarColor:Int = 0xff666666, HandleColor:Int = 0xffffffff)
	{
		super();
		
		x = X; 
		y = Y;
		
		if (MinValue == MaxValue)
		{
			FlxG.log.error("FlxSlider: MinValue and MaxValue can't be the same (" + MinValue + ")");
		}
		
		_decimals = FlxMath.getDecimals(MinValue);
		
		if (FlxMath.getDecimals(MaxValue) > _decimals)
		{
			_decimals = FlxMath.getDecimals(MaxValue);
		}
		
		//_decimals++;
		
		_minValue = MinValue;
		_maxValue = MaxValue;
		_barWidth = BarWidth;
		_barThickness = BarThickness;
		_handleWidth = HandleWidth;
		_handleThickness = HandleThickness;
		_barColor = BarColor;
		_handleColor = HandleColor;
		_onClick = OnClick;
		_lastPos = 0;
		_value = 0;
		CreateSlider();
	}
	
	private function CreateSlider():Void
	{
		var barHeight:Int = Std.int(Math.max(_barThickness, _handleThickness));
		var barPos:FlxPoint = FlxPoint.get(0, ((barHeight - _barThickness) / 2));
		var handPos:FlxPoint = FlxPoint.get(0, ((barHeight - _handleThickness) / 2));
		
		_bounds = FlxRect.get(x, y, _barWidth + _handleWidth, barHeight);
		
		_bar = new FlxSprite(0, 0).makeGraphic(_barWidth, barHeight, 0x0);
		FlxSpriteUtil.drawRect(_bar, barPos.x, barPos.y, _barWidth, _barThickness, _barColor);
		
		_handle = new FlxSprite(handPos.x, handPos.y).makeGraphic(_handleWidth, _handleThickness, 0x0);
		FlxSpriteUtil.drawRoundRect(_handle, 0, 0, _handleWidth, _handleThickness, 4, 4, _handleColor);

		add(_bar);
		add(_handle);
	}
	
	/**
	 * This function lets you replace the Bar with your own sprite. 
	 * Note: the NewSprite should probably be the same dimension as the old one, unless you really know what you're doing...
	 * @param	NewSprite	The new sprite to replace the old one with
	 */
	public function replaceBarSprite(NewSprite:FlxSprite):Void
	{
		//_bar.kill();
		NewSprite.animation.add("none", [0]);
		NewSprite.animation.play("none");
		NewSprite.clone(_bar);
	}
	
	/**
	 * This function lets you replace the Handle with your own sprite.
	 * Note: the NewSprite should probably be the same dimension as the old one, unless you really know what you're doing...
	 * @param	NewSprite	The new sprite to replace the old one with 
	 */
	public function replaceHandleSprite(NewSprite:FlxSprite):Void
	{
		//_handle.kill();
		NewSprite.animation.add("none", [0]);
		NewSprite.animation.play("none");
		NewSprite.clone(_handle);
	}
	
	
	override public function update():Void 
	{
		#if !FLX_NO_MOUSE
			if (FlxMath.mouseInFlxRect(false, _bounds))
			{
				if (FlxG.mouse.pressed)
				{
					_handle.x = FlxG.mouse.screenX - (_handle.width / 2);
					updateValue();
				}
			}
		#end
		
		#if !FLX_NO_TOUCH
			for (touch in FlxG.touches.list)
			{
				if (touch.inFlxRect(_bounds))
				{
					if(touch.pressed)
					{
						_handle.x = touch.screenX - (_handle.width / 2);
						updateValue();
					}
				}
			}
		#end
		
		super.update();
	}
	
	private function updateValue():Void
	{
		var pos:Float = relativePos;
		value = FlxMath.roundDecimal(((_maxValue - _minValue ) * pos) + _minValue, _decimals);
		if (pos != _lastPos)
		{
			if (_onClick != null) _onClick(value);
			_lastPos = pos;
			
		}
	}
	
	override public function destroy():Void 
	{
		_bar = null;
		_handle = null;
		_bounds = null;
		_onClick = null;
		
		super.destroy();
	}
	
	function get_value():Float 
	{
		return _value;
	}
	
	function set_value(value:Float):Float 
	{
		setHandlePos(value);
		return _value = value;
	}
	
	public var value(get_value, set_value):Float;
	
	
	/**
	 * The position of the handle relative to the slider / max value.
	 */
	private var relativePos(get, never):Float;
	
	private function set_decimals(value:Int):Int 
	{
		return _decimals = value;
	}
	
	public var decimals(null, set_decimals):Int;
	
	function get_bar():FlxSprite 
	{
		return _bar;
	}
	
	public var bar(get_bar, null):FlxSprite;
	
	function get_handle():FlxSprite 
	{
		return _handle;
	}
	
	public var handle(get_handle, null):FlxSprite;
	
	private function get_relativePos():Float 
	{ 
		var pos:Float = (_handle.x + (_handle.width/2) - x) / (_barWidth);
		// Relative position can't be bigger than 1
		if (pos > 1) 
		{
			pos = 1;
		}
		
		return pos;
	}
	
	private function setHandlePos(Value:Float):Void
	{
		if (Value < _minValue) Value = _minValue;
		if (Value > _maxValue) Value = _maxValue;
		
		var pos:Float = (Value - _minValue) / (_maxValue-_minValue);
		
		_handle.x = x + ((_barWidth-_handleWidth) * pos) ;
	}
}