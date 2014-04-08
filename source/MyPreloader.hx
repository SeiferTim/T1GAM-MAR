
package ;

import flixel.system.FlxPreloader;

class MyPreloader extends FlxPreloader
{
	#if !debug
	public function new() 
	{
		
		super();
		#if (desktop || mobile)
		allowedURLs.push("local");
		#else
		//allowedURLs.push("http://dinoghost.tims-world.com/");
		#end
		
		
	}
	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int):Void 
	{
		#if !(desktop || mobile)
		//in case there is a problem with reading the bytesTotal (Gzipped swf)
		var bytesTotal:Int = 8700000; 
		_percent = (bytesTotal != 0) ? bytesLoaded / bytesTotal : 0;
		#end
	}
	#end
}
