package ;
import flash.display.BitmapData;
import flash.display.InterpolationMethod;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxBitmapUtil;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;


class GameMap
{

	private var _width:Int;
	private var _height:Int;

	private var _popMap:Array<Int>;
	public var _mapTerrain:FlxTilemap;

	public var cityTiles:FlxGroup;
	private var _tileLoop:FlxAsyncLoop;
	public var finished(default, null):Bool = false;
	
	private var _whichTileRow:Int;
	private var _whichTileCol:Int;
	public var loopMax(default, null):Int;

	public function new(Width:Int, Height:Int ) 
	{
		var seed:Int = FlxRandom.int();
		var falseColors:Array<Int> = FlxGradient.createGradientArray(1, 255, [0xff0000ff, 0xff00ff00, 0xffff0000], 1, 90);
		var cur:Int = 0;
		var b:BitmapData;
		var c:Int;
		var bP:Int;
		var _terrainData:BitmapData;
		var _popData:BitmapData;
		var _terrainMap:Array<Int>;
		
		_width = Width;
		_height = Height;
		_terrainData = new BitmapData(_width, _height, true, 0x0);
		_terrainData.perlinNoise(50, 50, 8, seed, false, false, 1, true);
		_popData = new BitmapData(_width, _height, true, 0x0);
		_popMap = new Array<Int>();
		_terrainMap = new Array<Int>();
		_popData.perlinNoise(256, 256, 8, FlxRandom.int(), false, false, 1, true);
		
		for (i in 0...8)
		{
			b = new BitmapData(_width, _height, true, 0x0);
			b.perlinNoise(50, 50,i*2, seed, false, false, 1, true);
			
			FlxBitmapUtil.merge(b, b.rect, _terrainData, new Point(), 100, 100, 100, 100);
		}
		
		for (nX in 0..._terrainData.width)
		{
			for (nY in 0..._terrainData.height)
			{
				cur = FlxColorUtil.getRed(_terrainData.getPixel32(nX, nY));
				if (cur < 35)
				{
					_terrainMap.push(1);
					_popData.setPixel32(nX, nY, 0x0);
				}
				else if (cur < 45)
				{
					_terrainMap.push(2);
					_popData.setPixel32(nX, nY, 0x0);
				}
				else if (cur < 65)
				{
					_terrainMap.push(3);
					_popData.setPixel32(nX, nY,FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.6,1)));
				}
				else if (cur < 150)
				{
					_terrainMap.push(4);
					_popData.setPixel32(nX, nY,FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.2,.4)));
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

		_mapTerrain = new FlxTilemap();
		_mapTerrain.widthInTiles = _width;
		_mapTerrain.heightInTiles = _height;
		_mapTerrain.loadMap(_terrainMap, "images/terrain.png", 64, 64, FlxTilemap.OFF, 0, 1, 1);
		
		cityTiles = new FlxGroup(_width * _height);
		_whichTileRow = 0;
		_whichTileCol = 0;
		loopMax = _width * _height;
	
		var pP:Int;
		for (nX in 0..._popData.width)
		{
			for (nY in 0..._popData.height)
			{
				pP = FlxColorUtil.getRed(_popData.getPixel32(nX, nY));
				_popMap.push(Std.int(pP / 32) - 1);
			}
		}
		_tileLoop = new FlxAsyncLoop(loopMax, addCityTiles, 100);
	}
	
	private function zSort(Order:Int, A:FlxBasic, B:FlxBasic):Int
	{
		var zA:Float = Type.getClassName(Type.getClass(A)) == "ZEmitterExt" ? cast(A, ZEmitterExt).z : cast(A, DisplaySprite).z;
		var zB:Float = Type.getClassName(Type.getClass(B)) == "ZEmitterExt" ? cast(B, ZEmitterExt).z : cast(B, DisplaySprite).z;
		var result:Int = 0;
		if (zA < zB)
			result = Order;
		else if (zA > zB)
			result = -Order;
		return result;
	}
	
	
	public function addCityTiles():Void
	{
		if (_popMap[(_whichTileRow * _width) +_whichTileCol] > 0)		
			cityTiles.add( new CityTile(_whichTileCol * 64, _whichTileRow * 64,_popMap[(_whichTileRow * _width) +_whichTileCol]));
		_whichTileCol++;
		if (_whichTileCol >= _width)
		{
			_whichTileCol = 0;
			_whichTileRow++;
		}
	}
	
	public function update():Void
	{
		if (!_tileLoop.started)
		{
			_tileLoop.start();
		}
		else 
		{
			_tileLoop.update();
			if (_tileLoop.finished)
			{
				cityTiles.sort(zSort, FlxSort.ASCENDING);
				finished = true;
				_tileLoop.kill();
				_tileLoop.destroy();
			}
		}
		
	}
	
	function get_loopCounter():Int 
	{
		return (_whichTileRow * _width) +_whichTileCol;
	}
	
	public var loopCounter(get_loopCounter, null):Int;
	
}