package ;

import flash.display.BitmapData;
import flash.geom.Point;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUITypedButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

class GameButton extends FlxUITypedButton<GameFont> implements IUIElement
{
	
	public static inline var STYLE_GREEN:Int = 0;
	public static inline var STYLE_BLUE:Int = 1;
	public static inline var STYLE_YELLOW:Int = 3;
	public static inline var STYLE_RED:Int = 4;
	
	private static var  _slices:Array<Array<Int>> = [[7, 7, 41, 38], [7, 7, 41, 38], [7, 7, 41, 38]];
	
	public var selected:Bool = false;
	
	
	private var _sprSelected:FlxSprite;
	
	
	
	public function new(X:Float=0, Y:Float=0, ?Label:String, ?OnClick:Void -> Void, Style:Int = 0, FitText:Bool = true, Width:Int = 0, Height:Int =0, LabelFontSize:Int = -1) 
	{
		super(X, Y, Label, OnClick);
		
		var col:Int=0;
		var img:String="";
		
		switch(Style)
		{
			case STYLE_GREEN:
				col = GameFont.COLOR_WHITE;
				img = "images/green_button.png";
			case STYLE_BLUE:
				col = GameFont.COLOR_GREEN;
				img = "images/blue_button.png";
			case STYLE_YELLOW:
				col = GameFont.COLOR_BLUE;
				img = "images/yellow_button.png";
			case STYLE_RED:
				col = GameFont.COLOR_WHITE;
				img = "images/red_button.png";
			default:
				col = GameFont.COLOR_WHITE;
				img = "images/red_button.png";
		}
		
		var l:GameFont = new GameFont(0, 0, Label, GameFont.STYLE_GLOSSY, col,"left", LabelFontSize);
		var w:Int;
		var h:Int;
		
		if (FitText)
		{
			w = Std.int(l.width + 24);
			h = Std.int(l.height + 16);
		}
		else
		{
			w = Width;
			h = Height;
		}
		
		loadGraphicSlice9([img], w, h,_slices, FlxUI9SliceSprite.TILE_NONE, -1, false, 49, 49);
		label = l;
		
		_sprSelected = new FlxSprite(0, 0);
		var b:BitmapData = new BitmapData(w, h, true, FlxColor.WHITE);
		updateFrameData();
		var b2:BitmapData = new BitmapData(w + 4, h + 4, true, 0x0);
		
		for (sx in 0...5)
		{
			for (sy in 0...5)
			{
				b2.copyPixels(b, b.rect,new Point(sx,sy),framePixels, new Point(0, 0), true);
			}
		}
		_sprSelected.pixels = b2;
		_sprSelected.updateFrameData();
		_sprSelected.dirty = true;
		
		_sprSelected.x = x - 2;
		_sprSelected.y = y - 2;
		b = FlxDestroyUtil.dispose(b);
		//spr = FlxDestroyUtil.destroy(spr);
		
		up_toggle_color = over_toggle_color = over_color = down_color = down_toggle_color = up_color = 0xffffff;
		
		labelOffsets[FlxButton.HIGHLIGHT].y = -2;
		labelOffsets[FlxButton.NORMAL].y = -2;
		
		autoCenterLabel();
		
		broadcastToFlxUI = false;

		var _sound:FlxSound;
		_sound = FlxG.sound.load("sounds/Button.wav");
		onUp.sound = _sound;
		
		
		
		
	}

	override public function destroy():Void
	{
		_sprSelected = FlxDestroyUtil.destroy(_sprSelected);
		super.destroy();
	}
	override public function draw():Void
	{
		
		label.alpha = alpha;
		
		if (selected)
		{
			_sprSelected.alpha = alpha*.8;
			_sprSelected.scrollFactor = scrollFactor;
			_sprSelected.x = x - 2;
			_sprSelected.y = y - 2;
			_sprSelected.cameras = cameras;
			_sprSelected.draw();
		}
		
		super.draw();
	}	
}