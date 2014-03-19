package ;
import flash.display.BitmapData;
import flash.display.InterpolationMethod;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.system.FlxCollisionType;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.util.FlxBitmapUtil;
import flixel.util.FlxColorUtil;
import flixel.util.FlxGradient;
import flixel.util.FlxRandom;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;


class GameMap
{

	public var mapTerrain:FlxTilemap;
	public var cityTiles:FlxGroup;
	//public var cityStreets:FlxGroup;
	public var finished(default, null):Bool = false;
	public var loopMax(default, null):Int;
	public var mapPathing:FlxTilemap;
	public var mapWater:FlxTilemap;
	
	private var _waterMap:Array<Int>;
	private var _width:Int;
	private var _height:Int;
	private var _popMap:Array<Int>;
	private var _pathMap:Array<Int>;
	private var _roadMap:Array<Int>;
	private var _tileLoop:FlxAsyncLoop;
	private var _whichTileRow:Int;
	private var _whichTileCol:Int;
	private var _sinceRoadCol:Int = 7;
	private var _sinceRoadRow:Int = 7;
	

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
		_terrainData.perlinNoise(_width, _height, 4, seed, false, false, 1, true);
		_popData = new BitmapData(_width, _height, true, 0x0);
		_popMap = new Array<Int>();
		_pathMap = new Array<Int>();
		_terrainMap = new Array<Int>();
		_waterMap = new Array<Int>();
		_popData.perlinNoise(_width, _height, 8, FlxRandom.int(), false, false, 1, true);
		
		for (i in 0...8)
		{
			b = new BitmapData(_width, _height, true, 0x0);
			b.perlinNoise(_width, _height,i*2, seed, false, false, 1, true);
			
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
					_popData.setPixel32(nX, nY, 0xff000000);
					
				}
				else if (cur < 45)
				{
					_terrainMap.push(2);
					_popData.setPixel32(nX, nY, 0xff110000);
				}
				else if (cur < 65)
				{
					_terrainMap.push(3);
					_popData.setPixel32(nX, nY, FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.6,1)));
				}
				else if (cur < 150)
				{
					_terrainMap.push(4);
					_popData.setPixel32(nX, nY, FlxColorUtil.brighten(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.2,.4)));
				}
				else if (cur < 210)
				{
					_terrainMap.push(5);
					if (FlxRandom.chanceRoll())
					{
						_popData.setPixel32(nX, nY, FlxColorUtil.brighten(_popData.getPixel32(nX, nY), FlxRandom.floatRanged(0, .1)));
					}
					else
					{
						_popData.setPixel32(nX, nY, FlxColorUtil.darken(_popData.getPixel32(nX, nY), FlxRandom.floatRanged(0, .1)));
					}
				}
				else
				{
					_terrainMap.push(6);
					_popData.setPixel32(nX, nY, FlxColorUtil.darken(_popData.getPixel32(nX, nY),FlxRandom.floatRanged(.6,1)));
				}
			}
		}

		mapTerrain = new FlxTilemap();
		mapTerrain.widthInTiles = _width;
		mapTerrain.heightInTiles = _height;
		mapTerrain.loadMap(_terrainMap, "images/terrain.png", 32, 32, FlxTilemap.OFF, 0, 1, 1);
		
		for (i in 0..._terrainMap.length)
		{
			if (_terrainMap[i] <= 2)
			{
				_waterMap.push(1);
			}
			else
			{
				_waterMap.push(0);
			}
		}
		
		cityTiles = new FlxGroup(_width * _height);
		//cityStreets = new FlxGroup();
		
		_whichTileRow = 0;
		_whichTileCol = 0;
		// _popData.width * _popData.height;
		_roadMap = new Array<Int>();
		var pP:Int;
		for (nX in 0..._popData.width)
		{
			for (nY in 0..._popData.height)
			{
				pP = FlxColorUtil.getRed(_popData.getPixel32(nX, nY));
				
				_popMap.push(Std.int(pP / 32) - 1);
				if (pP == 0)
				{
					_pathMap.push(1);
				}
				else
				{
					_pathMap.push(0);
				}
				_roadMap.push(0);
				
			}
		}
		
		mapPathing = new FlxTilemap();
		mapPathing.widthInTiles = _width;
		mapPathing.heightInTiles = _height;
		
		mapWater = new FlxTilemap();
		mapWater.widthInTiles = _width;
		mapWater.heightInTiles = _height;
		
		loopMax = _popMap.length;
		
		
		
		mapTerrain.allowCollisions = FlxObject.NONE;
		//mapTerrain.collisionType = FlxCollisionType.NONE;
		mapTerrain.immovable = true;
		mapTerrain.moves = false;
		mapTerrain.solid = false;
		
		
		_tileLoop = new FlxAsyncLoop(loopMax, addCityTiles, 100);
	}
	

	
	
	public function addCityTiles():Void
	{
		var blockAvg:Float;
		var waterCount:Int;
		var touchedWater:Bool = false;
		
		
		if ((_whichTileRow * _width) +_whichTileCol <= _popMap.length)
		{
			
			if (_sinceRoadCol == 9 && _sinceRoadRow == 9)
			{
				if ((_pathMap[(_whichTileRow * _width) +_whichTileCol-1] == 0 || _pathMap[(_whichTileRow * _width) +_whichTileCol+1] == 0) && (_pathMap[((_whichTileRow+1) * _width) +_whichTileCol] ==0 || _pathMap[((_whichTileRow-1) * _width) + _whichTileCol] == 0)) 
				{
					//cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 2));
					mapTerrain.setTile(_whichTileCol, _whichTileRow, 9);
					_pathMap[(_whichTileRow * _width) +_whichTileCol] = 0;
					_roadMap[(_whichTileRow * _width) +_whichTileCol] = 2;
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
				}
				else if (_pathMap[(_whichTileRow * _width) +_whichTileCol - 1] == 0 || _pathMap[(_whichTileRow * _width) +_whichTileCol + 1] == 0)
				{
					//cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 1));
					mapTerrain.setTile(_whichTileCol, _whichTileRow, 8);
					_pathMap[(_whichTileRow * _width) +_whichTileCol] = 0;
					_roadMap[(_whichTileRow * _width) +_whichTileCol] = 1;
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
				}
				else if (_pathMap[((_whichTileRow + 1) * _width) +_whichTileCol] == 0 || _pathMap[((_whichTileRow - 1) * _width) + _whichTileCol] == 0)
				{
					//cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 0));
					mapTerrain.setTile(_whichTileCol, _whichTileRow, 7);
					_pathMap[(_whichTileRow * _width) +_whichTileCol] = 0;
					_roadMap[(_whichTileRow * _width) +_whichTileCol] = 1;
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
				}
				else
				{
					//_roadMap[(_whichTileRow * _width) +_whichTileCol] = 1;
				}
				//touchedWater = false;
				
				_popMap[(_whichTileRow * _width) +_whichTileCol] = 0;
				_sinceRoadCol = 0;
			}
			else if (_sinceRoadCol == 9)
			{
				if (_whichTileRow == 0 || (_roadMap[((_whichTileRow - 1) * _width) + _whichTileCol] != 0 && (_pathMap[(_whichTileRow * _width) + _whichTileCol] == 0 || _roadMap[((_whichTileRow - 1) * _width) + _whichTileCol] == 1))) 
				{
					//cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 0));
					mapTerrain.setTile(_whichTileCol, _whichTileRow, 7);
					_roadMap[(_whichTileRow * _width) +_whichTileCol] = 1;
					_pathMap[(_whichTileRow * _width) + _whichTileCol] = 0;
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
				}
				_popMap[(_whichTileRow * _width) +_whichTileCol] = 0;
			
				_sinceRoadCol = 0;
			}
			else if (_sinceRoadRow == 9)
			{				
				if (_whichTileCol == 0 || (_roadMap[((_whichTileRow) * _width) + _whichTileCol-1] != 0 && (_pathMap[(_whichTileRow * _width) + _whichTileCol] == 0 || _roadMap[((_whichTileRow) * _width) + _whichTileCol-1] == 1))) 
				{
					//cityStreets.add(new CityStreet(_whichTileCol * 32, _whichTileRow * 32, 1));
					mapTerrain.setTile(_whichTileCol, _whichTileRow, 8);
					_roadMap[(_whichTileRow * _width) +_whichTileCol] = 1;
					_pathMap[(_whichTileRow * _width) + _whichTileCol] = 0;
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
				}
				_popMap[(_whichTileRow * _width) +_whichTileCol] = 0;
			}
			else if (_sinceRoadCol % 2 == 1 && _sinceRoadRow % 2 == 1)
			{
				blockAvg = ( _popMap[(_whichTileRow * _width) +_whichTileCol] + _popMap[((_whichTileRow + 1) * _width) +_whichTileCol] + _popMap[(_whichTileRow * _width) +_whichTileCol +1] + _popMap[((_whichTileRow + 1) * _width) +_whichTileCol + 1]) / 4;
				waterCount = _pathMap[(_whichTileRow * _width) +_whichTileCol] + _pathMap[((_whichTileRow + 1) * _width) +_whichTileCol] + _pathMap[(_whichTileRow * _width) +_whichTileCol +1] + _pathMap[((_whichTileRow + 1) * _width) +_whichTileCol + 1];
				if (blockAvg > 0 && waterCount == 0)
				{
					cityTiles.add( new CityTile(_whichTileCol * 32, _whichTileRow * 32, Math.ceil(blockAvg)));
					_popMap[(_whichTileRow * _width) + _whichTileCol] = 1;
					_popMap[((_whichTileRow + 1) * _width) + _whichTileCol] = 1;
					_popMap[(_whichTileRow * _width) + _whichTileCol + 1] = 1;
					_popMap[((_whichTileRow + 1) * _width) + _whichTileCol + 1] = 1;
					_pathMap[(_whichTileRow * _width) + _whichTileCol] = 1;
					_pathMap[((_whichTileRow + 1) * _width) + _whichTileCol] = 1;
					_pathMap[(_whichTileRow * _width) + _whichTileCol + 1] = 1;
					_pathMap[((_whichTileRow + 1) * _width) + _whichTileCol + 1] = 1;
					
					_waterMap[(_whichTileRow * _width) + _whichTileCol] = 0;
					_waterMap[((_whichTileRow + 1) * _width) + _whichTileCol] = 0;
					_waterMap[(_whichTileRow * _width) + _whichTileCol + 1] = 0;
					_waterMap[((_whichTileRow + 1) * _width) + _whichTileCol + 1] = 0;
					
				}
				else
				{
					_popMap[(_whichTileRow * _width) + _whichTileCol] = 0;
					_popMap[((_whichTileRow + 1) * _width) + _whichTileCol] = 0;
					_popMap[(_whichTileRow * _width) + _whichTileCol + 1] = 0;
					_popMap[((_whichTileRow + 1) * _width) + _whichTileCol + 1] = 0;
				}
				
				
			}
			else
			{
				
				//roads.push(0);
			}
			
			_sinceRoadCol++;
			_whichTileCol++;
			if (_whichTileCol >= _width)
			{
				_whichTileCol = 0;
				_whichTileRow++;
				_sinceRoadCol = 7;
				if (_sinceRoadRow == 9)
				{
					_sinceRoadRow = 0;
				}
				_sinceRoadRow++;
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
				
				mapPathing.loadMap(_pathMap, "images/pathing.png", 32, 32, 0, 0, 1, 1);
				mapPathing.setTileProperties(0, FlxObject.NONE);
				mapPathing.setTileProperties(1, FlxObject.ANY);
				
				
				mapWater.loadMap(_waterMap, "images/pathing.png", 32, 32, 0, 0, 1, 1);
				mapWater.setTileProperties(0, FlxObject.NONE);
				mapWater.setTileProperties(1, FlxObject.ANY);
				
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