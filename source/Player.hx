package ;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;

class Player extends DisplaySprite
{

	private var _energy:Float;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/player.png", true, true, 64, 64);
		animation.add("lr-w", [1, 0, 2, 0], 4);
		animation.add("d-w", [4, 3, 5, 3], 4);
		animation.add("u-w", [7, 6, 8, 6], 4);
		animation.add("lr", [1], 1);
		animation.add("d", [4], 1);
		animation.add("u", [7], 1);
		
		animation.add("lr-w-r", [10, 9, 11, 9], 4);
		animation.add("d-w-r", [13, 12, 13, 14], 4);
		animation.add("u-w-r", [16, 15, 16, 17], 4);
		animation.add("lr-r", [10], 1);
		animation.add("d-r", [13], 1);
		animation.add("u-r", [16], 1);
		
		animation.add("lr-w-s", [19, 18, 20, 18], 4);
		animation.add("d-w-s", [22, 21, 23, 21], 4);
		animation.add("u-w-s", [25, 24, 26, 24], 4);
		animation.add("lr-s", [19], 1);
		animation.add("d-s", [22], 1);
		animation.add("u-s", [25], 1);
		
		animation.add("lr-w-r-s", [28, 27, 29, 27], 4);
		animation.add("d-w-r-s", [31, 30, 31, 30], 4);
		animation.add("u-w-r-s", [34, 33, 34, 34], 4);
		animation.add("lr-r-s", [28], 1);
		animation.add("d-r-s", [31], 1);
		animation.add("u-r-s", [34], 1);
		
		animation.play("d");
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
	
	override public function hurt(Damage:Float):Void 
	{
		if (FlxFlicker.isFlickering(this))
			return;
		FlxG.sound.play("sounds/Hurt.wav",1);
		FlxFlicker.flicker(this, Reg.FADE_DUR * 2, 0.04, true, true);
		energy -= Damage;
		super.hurt(0);
	}
	
	override public function update():Void 
	{
		
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