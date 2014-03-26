package ;

import flixel.group.FlxGroup;

class ZGroup extends FlxGroup
{
	public var zMembers:Array<IFlxZ>;
	
	public function new(MaxSize:Int = 0)
	{
		super(MaxSize);
		zMembers = cast members;
	}
	
}