package ;

class CityTile extends DisplaySprite
{

	public var tier(default, null):Int;
	private var _onScreen:Bool;
	
	public function new(X:Float=0, Y:Float=0, Tier:Int = 1) 
	{
		super(X, Y);
		tier = Tier;
		health = 5 * tier;
		loadGraphic("images/city-tiles.png", true, false, 64, 128);
		width = 64;
		height = 64;
		offset.y = 64;
		animation.frameIndex = tier;
	}
	
	override public function update():Void 
	{
		//_onScreen = isOnScreen();
		if (!_onScreen)
			return;
		super.update();
	}
	
	override public function draw():Void
	{
		_onScreen = isOnScreen();
		if (!_onScreen)
			return;
		super.draw();
	}
	
}