package ;
import flixel.FlxObject;
import flixel.system.FlxCollisionType;


class CityStreet extends DisplaySprite
{

	public function new(X:Float=0, Y:Float=0, Frame:Int=0) 
	{
		super(X, Y);
		loadGraphic("images/street.png", true, false, 32, 32);
		animation.frameIndex = Frame;
		allowCollisions = FlxObject.NONE;
		collisionType = FlxCollisionType.NONE;
		moves = false;
		immovable = true;
		calcOnScreen = false;
		onScreen = true;
		solid = false;
		
	}
	override public function update():Void 
	{
		//(super.update();
	}
	
}