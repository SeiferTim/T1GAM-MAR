package ;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends DisplaySprite
{

	private var _energy:Float;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/player.png", true, true, 64, 64);
		animation.add("lr", [0], 1);
		animation.add("d", [1], 1);
		animation.add("u", [2], 1);
		animation.play("lr");
		height = 22;
		width = 22;
		offset.x = 20;
		offset.y = 28;
		facing = FlxObject.RIGHT;
		calcOnScreen = false;
		onScreen = true;
		energy = 100;
		
		//immovable = true;
		
	}
	
	override public function update():Void 
	{

		energy -= FlxG.elapsed*4;
		super.update();
	}
	
	function get_energy():Float 
	{
		return _energy;
	}
	
	function set_energy(value:Float):Float 
	{
		if (value > 100)
			value = 100;
		return _energy = value;
	}
	
	public var energy(get_energy, set_energy):Float;
	
}