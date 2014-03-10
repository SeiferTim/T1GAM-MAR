package ;
import flash.display.BitmapData;
import flash.display.InterpolationMethod;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
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
	public var cityStreets:FlxGroup;
	private var _tileLoop:FlxAsyncLoop;
	public var finished(default, null):Bool = false;
	
	private var _whichTileRow:Int;
	private var _whichTileCol:Int;
	public var loopMax(default, null):Int;
	private var _parent:PlayState;
	private var _sinceRoadCol:Int = 7;
	private var _sinceRoadRow:Int = 7;
	
	//public var _popData:BitmapData;

	public function new(Width:Int, Height:Int, Parent:PlayState ) 
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
		_parent = Parent;
		
		_width = Width;
		_height = Height;
		_terrainData = new BitmapData(_width, _height, true, 0x0);
		_terrainData.perlinNoise(50, 50, 8, seed, false, false, 1, true);
		_popData = new BitmapData(_width*2, _height*2, true, 0x0);
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
					_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), 0x0);
				}
				else if (cur < 45)
				{
					_terrainMap.push(2);
					_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), 0x0);
				}
				else if (cur < 65)
				{
					_terrainMap.push(3);
					_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), FlxColorUtil.brighten(_popData.getPixel32(nX*2, nY*2),FlxRandom.floatRanged(.6,1)));
				}
				else if (cur < 150)
				{
					_terrainMap.push(4);
					_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), FlxColorUtil.brighten(_popData.getPixel32(nX*2, nY*2),FlxRandom.floatRanged(.2,.4)));
				}
				else if (cur < 210)
				{
					_terrainMap.push(5);
					if (FlxRandom.chanceRoll())
					{
						_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), FlxColorUtil.brighten(_popData.getPixel32(nX*2, nY*2), FlxRandom.floatRanged(0, .1)));
					}
					else
					{
						_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), FlxColorUtil.darken(_popData.getPixel32(nX*2, nY*2), FlxRandom.floatRanged(0, .1)));
					}
				}
				else
				{
					_terrainMap.push(6);
					_popData.fillRect(new Rectangle(nX * 2, nY * 2, 2, 2), FlxColorUtil.darken(_popData.getPixel32(nX*2, nY*2),FlxRandom.floatRanged(.6,1)));
				}
			}
		}

		_mapTerrain = new FlxTilemap();
		_mapTerrain.widthInTiles = _width;
		_mapTerrain.heightInTiles = _height;
		_mapTerrain.loadMap(_terrainMap, "images/terrain.png", 64, 64, FlxTilemap.OFF, 0, 1, 1);
		
		cityTiles = new FlxGroup(_width * _height);
		cityStreets = new FlxGroup();
		
		_whichTileRow = 0;
		_whichTileCol = 0;
		loopMax = _popData.width * _popData.height;
	
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
	

	
	
	public function addCityTiles():Void
	{
				
		if ((_whichTileRow * _width * 2) +_whichTileCol <= _popMap.length)
		{
			if (_sinceRoadCol == 9 && _sinceRoadRow == 9)
			{
				if (_popMap[(_whichTileRow * _width * 2) +_whichTileCol] > 0)
					cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 2));
				_sinceRoadCol = 0;
			}
			else if (_sinceRoadCol == 9)
			{
				if (_popMap[(_whichTileRow * _width * 2) +_whichTileCol] > 0)
					cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 0));
				_sinceRoadCol = 0;
			}
			else if (_sinceRoadRow == 9)
			{
				if (_popMap[(_whichTileRow * _width * 2) +_whichTileCol] > 0)
					cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 1));
				
			}
			else if (_sinceRoadCol % 2 == 1 && _sinceRoadRow % 2 == 1)
			{
				if (_popMap[(_whichTileRow * _width * 2) +_whichTileCol] > 0)
					cityTiles.add( new CityTile(_whichTileCol * 32, _whichTileRow * 32, _popMap[(_whichTileRow * _width * 2) +_whichTileCol]));
			}
			
			_sinceRoadCol++;
			_whichTileCol++;
			if (_whichTileCol >= _width * 2)
			{
				_whichTileCol = 0;
				_whichTileRow++;
				_sinceRoadCol = 7;
				if (_sinceRoadRow == 9)
				{
					_sinceRoadRow = 0;
				}
				//else
				//{
					_sinceRoadRow++;
				//}
			}
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
				//cityTiles.sort(zSort, FlxSort.ASCENDING);
				finished = true;
				_tileLoop.kill();
				_tileLoop.destroy();
			}
		}
		
	}
	
	function get_loopCounter():Int 
	{
		return (_whichTileRow * _width * 2) +_whichTileCol;
	}
	
	public var loopCounter(get_loopCounter, null):Int;
	
}