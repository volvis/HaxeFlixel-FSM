package ;

import flixel.addons.util.FlxFSM;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.FlxG;

/**
 * ...
 * @author Pekka Heikkinen
 */
class PowerPellet extends FlxSprite
{

	public var fsm:FlxFSM<PowerPellet>;
	
	public var player:SlimePink;
	
	public function new(Player:SlimePink, X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		player = Player;
		loadGraphic("assets/Star.png", true, 8, 8);
		
		fsm = new FlxFSM<PowerPellet>(this);
		fsm.transitions.addGlobal(PickedUp, isTouchingPlayer);
	}

	override public function update():Void
	{
		super.update();
		fsm.update();
	}
	
	private function isTouchingPlayer(Owner:FlxSprite):Bool
	{
		return Owner.overlaps(player);
	}
	
}

class PickedUp extends FlxFSMState<PowerPellet>
{
	override public function enter(Owner:PowerPellet, FSM:FlxFSM<PowerPellet>):Void
	{
		Owner.player.fsm.transitions.replace(SlimePink.Jump, SlimePink.SuperJump);
		FSM.destroy();
	}
	
	override public function exit(Owner:PowerPellet):Void
	{
		Owner.destroy();
	}
}