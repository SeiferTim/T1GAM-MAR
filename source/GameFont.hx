package ;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.Font;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxGradient;
import flixel.util.FlxSpriteUtil;

class GameFont extends FlxSprite
{

	public static inline var STYLE_BIG_TITLE:Int = 0;
	public static inline var STYLE_HUGE_TITLE:Int = 1;
	public static inline var STYLE_TINY:Int = 2;
	
	public static inline var COLOR_RED:Int = 0;
	public static inline var COLOR_CYAN:Int = 1;
	public static inline var COLOR_YELLOW:Int = 2;
	
	private static var COLORS_RED:Array<Int> = [0xffff0000, 0xff660000, 0xffff6666, 0xff110000];
	private static var COLORS_CYAN:Array<Int> = [0xff00ffff,0xff006666,0xff66ffff,0xff001111];
	private static var COLORS_YELLOW:Array<Int> = [0xffffff00,0xff999900,0xffffff99,0xff333300];
	
	private var _text:String = "";
	private var _style:Int = 0;
	private var _textColor:Int = 0;
	private var _hasShadow:Bool = false;
	private var _hasInnerGlow:Bool = false;
	private var _hasOutline:Bool = false;
	
	
	public function new(X:Float=0, Y:Float=0, Text:String = "", Style:Int = 0, Color:Int = 0) 
	{
		super(X, Y);
		_style = Style;
		_text = Text;
		_textColor = Color;
		drawText();
		
	}
	
	private function drawText():Void
	{
		var size:Int = 8;
		var colors:Array <Int> = [];
		var font:String = Reg.FONT_SCARY;
		
		switch(_style)
		{
			case STYLE_HUGE_TITLE:
				size = 96;
				font = Reg.FONT_BIG;
				_hasShadow = true;
				_hasInnerGlow = true;
				_hasOutline = true;
			case STYLE_BIG_TITLE:
				size = 64;
				font = Reg.FONT_SCARY;
				_hasShadow = true;
				_hasInnerGlow = true;
				_hasOutline = true;
			case STYLE_TINY:
				size = 16;
				font = Reg.FONT_PIXEL;
				_hasShadow = true;
		}
		
		switch (_textColor)
		{
			case COLOR_RED:
				colors = COLORS_RED;
			
			case COLOR_CYAN:
				colors = COLORS_CYAN;
				
			case COLOR_YELLOW:
				colors = COLORS_YELLOW;
		}
		
		var tmpText:FlxText = new FlxText(0, 0, FlxG.width, _text);
		tmpText.setFormat(font, size, 0x000000, "left");
		tmpText.update();
		tmpText.draw();
		
		var r:Rectangle = tmpText.pixels.getColorBoundsRect(0xff000000, 0x00000000, false);
		var b1:BitmapData = new BitmapData(Std.int(r.width), Std.int(r.height), true, 0x0);
		b1.copyPixels(tmpText.pixels, r, new Point());
		
		var b2:BitmapData = FlxGradient.createGradientBitmapData(Std.int(r.width), Std.int(r.height), [colors[0], colors[1]]);
		
		//var s2:FlxSprite = new FlxSprite().makeGraphic(Std.int(r.width), Std.int(r.height), 0x33ffffff);
		//s1.stamp(s2, 0, 0);
		
		var spr:FlxSprite = new FlxSprite();
		
		FlxSpriteUtil.alphaMask(spr, b2, b1);
		makeGraphic(Std.int(spr.width + 4), Std.int(spr.height + 14), 0x0, true);
		pixels.copyPixels(spr.pixels, spr.pixels.rect, new Point(2, 2));
		
		if (_hasInnerGlow)
		{			
			var inglow:GlowFilter = new GlowFilter(colors[2], 1, 2, 2, 4, 1, true);
			pixels.applyFilter(pixels, pixels.rect, new Point(), inglow);
		}
		if (_hasOutline)
		{
			var outline:DropShadowFilter = new DropShadowFilter(0, 90, colors[3], 1, 2, 2, 20);
			pixels.applyFilter(pixels, pixels.rect, new Point(), outline);
		}
		if (_hasShadow)
		{
			var dropShad:DropShadowFilter = new DropShadowFilter(1, 90, colors[3], .8, 4, 4, 2);
			pixels.applyFilter(pixels, pixels.rect, new Point(), dropShad);
		}
		
		dirty = true;
		updateFrameData();
		
		
		
	}
	
	function get_text():String 
	{
		return _text;
	}
	
	function set_text(value:String):String 
	{
		if (_text != value)
		{
			_text = value;
			drawText();
		}
		return _text;
	}
	
	public var text(get_text, set_text):String;
	
	function get_style():Int 
	{
		return _style;
	}
	
	function set_style(value:Int):Int 
	{
		if (_style != value)
		{
			_style = value;
			drawText();
		}
		return _style;
	}
	
	public var style(get_style, set_style):Int;
	
	function get_textColor():Int 
	{
		return _textColor;
	}
	
	function set_textColor(value:Int):Int 
	{
		if (_textColor != value)
		{
			_textColor = value;
			drawText();
		}
		return _textColor;
	}
	
	public var textColor(get_textColor, set_textColor):Int;
	
}