package;

import flixel.addons.util.FlxFSM.FlxFSM;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.FlxObject;

/**
 * @author Pekka Heikkinen
 */


class SlimePink extends FlxSprite
{
	public var fsm:FlxFSM<FlxSprite>;
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		
		loadGraphic("assets/SlimePink.png", true, true, 16, 16);
		animation.add("standing", [0, 1], 3);
		animation.add("walking", [0, 1], 12);
		animation.add("jumping", [2]);
		animation.add("pound", [0]);
		animation.add("landing", [3, 0, 1, 0], 8, false);
		
		acceleration.y = 400;
		maxVelocity.y = 400;
		maxVelocity.x = 100;
		
		fsm = new FlxFSM<FlxSprite>(this, new Idle());
	}

	override public function update():Void
	{
		fsm.update();
		super.update();
	}

	override public function destroy():Void
	{
		super.destroy();
	}
}

class Idle extends FlxFSMState<FlxSprite>
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("standing");
	}
	
	override public function update(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			Owner.animation.play("walking");
			Owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
		else
		{
			Owner.velocity.x *= 0.9;
			Owner.animation.play("standing");
		}
		
		if (FlxG.keys.pressed.UP)
		{
			FSM.state = new Jump();
			return;
		}
	}
}

class Jump extends FlxFSMState<FlxSprite>
{
	var doubleJumpCounter:Int;
	
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("jumping");
		Owner.velocity.y = -200;
		doubleJumpCounter = 0;
	}
	
	override public function update(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			Owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
		
		if (FlxG.keys.justPressed.UP && doubleJumpCounter == 0)
		{
			Owner.velocity.y = -100;
			doubleJumpCounter++;
		}
		
		if (FlxG.keys.justPressed.DOWN)
		{
			FSM.state = new GroundPound();
			return;
		}
		
		if (Owner.isTouching(FlxObject.DOWN))
		{
			FSM.state = new Idle();
			return;
		}
	}
}

class GroundPound extends FlxFSMState<FlxSprite>
{
	private var ticks:Float;
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("pound");
		Owner.velocity.x = 0;
		ticks = 0;
	}
	
	override public function update(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		ticks++;
		if (ticks < 15)
		{
			Owner.velocity.y = 0;
		}
		else
		{
			Owner.velocity.y = 300;
		}
		if (Owner.isTouching(FlxObject.DOWN))
		{
			FSM.state = new GroundPoundFinish();
			return;
		}
	}
}

class GroundPoundFinish extends FlxFSMState<FlxSprite>
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("landing");
	}
	
	override public function update(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		if (Owner.animation.finished)
		{
			FSM.state = new Idle();
		}
	}
}
