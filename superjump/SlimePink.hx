package;

import flixel.addons.util.FlxFSM.FlxFSM;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.util.FlxFSM.FlxFSMState;
import flixel.addons.util.FlxFSM.FlxFSMManager;
import flixel.FlxObject;

/**
 * @author Pekka Heikkinen
 */


class SlimePink extends FlxSprite
{
	public var fsm:FlxFSM<FlxSprite>;
	public var fsmManager:FlxFSMManager<FlxSprite>;
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		
		loadGraphic("assets/SlimePink.png", true, 16, 16);
		animation.add("standing", [0, 1], 3);
		animation.add("walking", [0, 1], 12);
		animation.add("jumping", [2]);
		animation.add("pound", [0]);
		animation.add("landing", [3, 0, 1, 0], 8, false);
		
		acceleration.y = 400;
		maxVelocity.y = 400;
		maxVelocity.x = 100;
		
		fsm = new FlxFSM<FlxSprite>(this);
		fsm.transitions
			.add(Idle, Jump, Conditions.jump)
			.add(Jump, Idle, Conditions.grounded)
			.add(Jump, GroundPound, Conditions.groundSlam)
			.add(Jump, DoubleJump, Conditions.doubleJump)
			.add(DoubleJump, Idle, Conditions.grounded)
			.add(DoubleJump, GroundPound, Conditions.groundSlam)
			.add(GroundPound, GroundPoundFinish, Conditions.grounded)
			.add(GroundPoundFinish, Idle, Conditions.animationFinished)
			.start(Idle);
		fsmManager = new FlxFSMManager();
		fsmManager.pushToStack(fsm);
	}

	override public function update():Void
	{
		fsmManager.update();
		super.update();
	}

	override public function destroy():Void
	{
		super.destroy();
	}
}

class Conditions
{
	public static function jump(Owner:FlxSprite)
	{
		return (FlxG.keys.justPressed.UP && Owner.isTouching(FlxObject.DOWN));
	}
	public static function doubleJump(Owner:FlxSprite)
	{
		return (FlxG.keys.justPressed.UP);
	}
	public static function groundSlam(Owner:FlxSprite)
	{
		return (FlxG.keys.justPressed.DOWN && !Owner.isTouching(FlxObject.DOWN));
	}
	public static function grounded(Owner:FlxSprite)
	{
		return (Owner.isTouching(FlxObject.DOWN));
	}
	public static function animationFinished(Owner:FlxSprite)
	{
		return (Owner.animation.finished);
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
	}
}

class Jump extends FlxFSMState<FlxSprite>
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("jumping");
		Owner.velocity.y = -200;
	}
	
	override public function update(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			Owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
	}
}

class SuperJump extends Jump
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("jumping");
		Owner.velocity.y = -300;
	}
}

class DoubleJump extends Jump
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("jumping");
		Owner.velocity.y = -100;
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
	}
}

class GroundPoundFinish extends FlxFSMState<FlxSprite>
{
	override public function enter(Owner:FlxSprite, FSM:FlxFSM<FlxSprite>)
	{
		Owner.animation.play("landing");
	}
}