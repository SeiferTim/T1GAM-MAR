package ;
import flash.display.BitmapData;
import flash.display.InterpolationMethod;
import flash.geom.Point;
import flixel.tile.FlxTilemap;
import flixel.util.FlxBitmapUtil;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;


class GameMap
{

	private var _width:Int;
	private var _height:Int;
	
	//private var _terrainMap:BitmapData;
	private var _terrainData:BitmapData;
	private var _popData:BitmapData;
	private var _popMap:Array<Int>;
	private var _terrainMap:Array<Int>;
	
	public var _mapTerrain:FlxTilemap;
	public var _mapPop:FlxTilemap;
	
	public function new(Width:Int, Height:Int ) 
	{
		_width = Width;
		_height = Height;
		var seed:Int = FlxRandom.int();
		_terrainData = new BitmapData(_width, _height, true, 0x0);
		_terrainData.perlinNoise(128, 128, 16, seed, false, true, 1, true);
		_popData = new BitmapData(_width, _height, true, 0x0);
		_popMap = new Array<Int>();
		_terrainMap = new Array<Int>();
		_popData.perlinNoise(256, 256, 8, FlxRandom.int(), false, false, 1, true);
		var falseColors:Array<Int> = FlxGradient.createGradientArray(1, 255, [0xff0000ff, 0xff00ff00, 0xffff0000],1,90);
		
		var b:BitmapData;
		var c:Int;
		var bP:Int;
		
		for (i in 0...10)
		{
			b = new BitmapData(_width, _height, true, 0x0);
			b.perlinNoise(128, 128, i, FlxRandom.int(), false, true, 1, true);
			for (nX in 0..._terrainData.width)
			{
				for (nY in 0..._terrainData.height)
				{
					
					c = _terrainData.getPixel32(nX, nY);
					bP = FlxColorUtil.getRed(b.getPixel32(nX, nY));
					
					if (bP >= 128)
						FlxColorUtil.brighten(c, .2);
					else
						FlxColorUtil.darken(c, .2);
					
					
					_terrainData.setPixel32(nX, nY, c);
					
				}
			}
		}

		var cur:Int = 0;
		
		for (nX in 0..._terrainData.width)
		{
			for (nY in 0..._terrainData.height)
			{
				cur = FlxColorUtil.getRed(_terrainData.getPixel32(nX, nY));

				if (cur < 90)
				{
					_terrainMap.push(1);
					_popData.setPixel32(nX, nY, 0x0);
				}
				else if (cur < 100)
				{
					_terrainMap.push(2);
					_popData.setPixel32(nX, nY, 0x0);
				}
				else if (cur < 110)
				{
					_terrainMap.push(3);
					_popData.setPixel32(nX, nY,FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.6,1)));
				}
				else if (cur < 180)
				{
					_terrainMap.push(4);
					_popData.setPixel32(nX, nY,FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.1,.3)));
				}
				else if (cur < 210)
				{
					_terrainMap.push(5);
					if (FlxRandom.chanceRoll())
						_popData.setPixel32(nX, nY, FlxColorUtil.brighten(_popData.getPixel32(nX, nY), FlxRandom.floatRanged(0, .1)));
					else
						_popData.setPixel32(nX, nY, FlxColorUtil.darken(_popData.getPixel32(nX, nY), FlxRandom.floatRanged(0, .1)));
				}
				else
				{
					_terrainMap.push(6);
					_popData.setPixel32(nX, nY,FlxColorUtil.darken(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.6,1)));
				}
			}
		}
		
		var min:Int=255;
		var max:Int=0;
		
		var pP:Int;
		for (nX in 0..._popData.width)
		{
			for (nY in 0..._popData.height)
			{
				pP = FlxColorUtil.getRed(_popData.getPixel32(nX, nY));
				_popMap.push(Std.int(pP / 32)-1);
				if (Std.int(pP / 32) > max)
					max = Std.int(pP / 32);
				if (Std.int(pP / 32) < min)
					min = Std.int(pP / 32);
				//if (pP > 10)
				//{
				//	_popMap.setPixel32(nX, nY, falseColors[pP]);
				//}
			}
		}
		trace("min: " + min + " max: " + max);
		_mapTerrain = new FlxTilemap();
		_mapTerrain.widthInTiles = _width;
		_mapTerrain.heightInTiles = _height;
		_mapTerrain.loadMap(_terrainMap, "images/terrain.png", 64, 64, FlxTilemap.OFF, 0, 1, 1);
		
		
		
		_mapPop = new FlxTilemap();
		_mapPop.widthInTiles = _width;
		_mapPop.heightInTiles = _height;
		_mapPop.loadMap(_popMap, "images/pop.png", 64, 64, FlxTilemap.OFF, 0, 1, 1);
		
	}
	
}