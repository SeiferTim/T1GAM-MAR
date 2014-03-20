package ;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class WaveSprite extends FlxSprite
{

	private var _target:FlxSprite;
	
	private var _time:Float = 0;
	private var _targetOff:Float = -999;
	
	public function new(Target:FlxSprite) 
	{
		_target = Target;
		super(_target.x - 20, _target.y);
		makeGraphic(Std.int(_target.width + 40), Std.int(_target.height), 0x0, true, "main-text");
		//pixels = new BitmapData(Std.int(_target.width + 40), Std.int(_target.height), true, 0x0);
		pixels.copyPixels(_target.pixels, _target.pixels.rect, new Point(20, 0));
		FlxG.watch.add(this, "_time");
		dirty = true;
		
	}
	
	override public function draw():Void 
	{
		pixels.fillRect(pixels.rect, 0x0);
		var _startY:Int = Std.int(_target.height * .33);
		var off:Float = 0;
		for (y in 0...Std.int(_target.height))
		{
			
			
			if (y < _startY)
			{
				pixels.copyPixels(_target.pixels, new Rectangle(0, y, _target.width, 1), new Point(20, y));
			}
			else
			{
				off = ((y - _startY) * 1.2) * .06 * Math.sin((.3 * (y-_startY))+_time);

				pixels.copyPixels(_target.pixels, new Rectangle(0, y, _target.width, 1), new Point(20+off, y));
			}
			
		}
		if (_targetOff == -999)
		{
			_targetOff = off;
		}
		
		if (off==_targetOff)
			_time = 0;
		_time += FlxG.elapsed * 4;
		
		
		resetFrameBitmapDatas();
		dirty = true;
		super.draw();
	}
	
}