package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class GameFont extends FlxSprite
{

	public static var STYLE_BIG_RED:Int = 0;
	
	private var _text(default, null):String = "";
	private var _style:Int = 0;
	
	public function new(X:Float=0, Y:Float=0, Text:String = "", Style=0) 
	{
		super(X, Y);
		_style = Style;
		_text = Text;
		drawText();
		
	}
	
	private function drawText():Void
	{
		var size:Int = 8;
		var color:Int = 0xffffffff;
		
		switch(_style)
		{
			case STYLE_BIG_RED:
				size = 20;
		}
		
		var tmpText:FlxText = new FlxText(0, 0, FlxG.width, drawText);
		tmpText.setFormat(Reg.FONT_BIG, size, 0x000000, "left");
		tmpText.update();
		tmpText.draw();
		
		
	}
	
}