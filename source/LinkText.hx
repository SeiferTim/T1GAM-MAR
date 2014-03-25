package ;

import flash.display.BitmapData;
import flash.geom.Point;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxDestroyUtil;

class LinkText extends FlxUIButton
{

	public function new(X:Float=0, Y:Float=0, ?Label:String, ?OnClick:Void -> Void, Alignment:String = "left", Size:Int = -1) 
	{
		super(X, Y, "", OnClick);
		
		var txtUp:GameFont = new GameFont(0, 0, Label, GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEBLUE, Alignment, Size);
		var txtOver:GameFont = new GameFont(0, 0, Label, GameFont.STYLE_SMSIMPLE, GameFont.COLOR_SIMPLEYELLOW, Alignment, Size);
		var bm:BitmapData = new BitmapData(Std.int(txtUp.width), Std.int(txtUp.height * 3), true, 0x0);
		bm.copyPixels(txtUp.pixels, txtUp.pixels.rect, new Point());
		bm.copyPixels(txtOver.pixels, txtOver.pixels.rect, new Point(0,txtOver.height));
		bm.copyPixels(txtOver.pixels, txtOver.pixels.rect, new Point(0, txtOver.height * 2));
		loadGraphicsUpOverDown(bm);
		bm = FlxDestroyUtil.dispose(bm);
		txtUp = FlxDestroyUtil.destroy(txtUp);
		txtOver = FlxDestroyUtil.destroy(txtOver);
	}
	
}