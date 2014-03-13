package ;

class Explosion extends DisplaySprite
{
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("images/explosion.png", true, false, 32, 32);
		animation.add("explode", [0, 1, 2, 3, 4, 3, 2, 1, 0], 20, false);
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		animation.play("explode", true);
		calcOnScreen = false;
	}
	
	override public function update():Void 
	{
		if (animation.finished)
			kill();
		super.update();
	}
	
	
}