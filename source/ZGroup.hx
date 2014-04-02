package ;

import flixel.FlxBasic;
import flixel.group.FlxTypedGroup;

class ZGroup<T:FlxBasic> extends FlxTypedGroup<T>
{
	public var zMembers:Array<IFlxZ>;
	
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
		
		zMembers = cast members;
	}
	
	public function updateMembers():Void
	{
		members = cast zMembers;
	}
	
}