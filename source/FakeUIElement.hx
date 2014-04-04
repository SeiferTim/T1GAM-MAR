package ;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Constraints.Function;

class FakeUIElement extends FlxSprite
{

	public var selected:Bool = false;
	public var toggled:Bool = false;
	public var onX:Void->Void;
	public var onInput:Int->Void;
	
	private var _keepToggled:Bool = true;
	
	public static inline var CLICK_EVENT:String = "click_button";
	public static inline var OVER_EVENT:String = "over_button";
	public static inline var DOWN_EVENT:String = "down_button";
	public static inline var OUT_EVENT:String = "out_button";
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 1, Height:Int = 1, OnX:Void->Void, OnInput:Int->Void, KeepToggled:Bool = true )
	{
		super(X, Y);
		onX = OnX;
		onInput = OnInput;
		_keepToggled = KeepToggled;
		makeGraphic(Width, Height, 0x0);
		FlxSpriteUtil.drawRoundRect(this, 0, 0, Width, Height, 10, 10, FlxColor.WHITE);
		alpha = .6;
		visible = false;
		selected = false;
		toggled = false;
	}
	
	public function forceStateHandler(event:String):Void {
		switch(event) {
			case CLICK_EVENT:	onUpHandler();
		}
	}
	
	private function onUpHandler():Void
	{
		if (!toggled)
		{
			if (onX != null)
				onX();
		}
		if(_keepToggled)
			toggled = !toggled;
		
	}
	
	public function input(Input:Int = 0):Void
	{
		if (onInput!=null)
			onInput(Input);
	}
	
	
	override public function update():Void 
	{
		if (selected)
		{
			alpha = .6;
			visible = true;
			if (toggled)
			{
				alpha = .8;
				
			}
		}
		else
		{
			visible = false;
		}
		super.update();
	}
	
}