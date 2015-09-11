package flixel.addons.effects;

import flixel.addons.effects.FlxGlitchSprite.FlxGlitchView;
import flixel.FlxBaseSprite;
import flixel.FlxSprite;
import flixel.graphics.FlxTexture;
import flixel.graphics.views.FlxGraphic;
import flixel.graphics.views.FlxImage;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRandom;
import openfl.display.BitmapData;

/**
 * This creates a FlxSprite which copies a target FlxSprite and applies a non-destructive wave-distortion effect.
 * Usage: Create a FlxSprite object, position it where you want (don't add it), and then create a new FlxGlitchSprite, 
 * passing the Target object to it, and then add the sprite to your state/group.
 * Based, in part, from PhotonStorm's GlitchFX Class in Flixel Power Tools.
 * @author Tim Hely / tims-world.com
 */
class FlxGlitchSprite extends FlxSprite
{
	public var glitchView(default, null):FlxGlitchView;
	/**
	 * How thick each glitch segment should be.
	 */
	public var size(get, set):Int;
	/**
	 * Time, in seconds, between glitch updates
	 */
	public var delay(get, set):Float;
	/**
	 * The target FlxSprite that the glitch effect copies from.
	 */
	public var target(get, set):FlxBaseSprite;
	/**
	 * Which direction the glitch effect should be applied.
	 */
	public var direction(get, set):FlxGlitchDirection;
	/**
	 * How strong the glitch effect should be (how much it should move from the center)
	 */
	public var strength(get, set):Int;
	
	/**
	 * Creates a new FlxGlitchSprite, which clones a target FlxSprite and applies a Glitch-distortion effect to the clone.
	 * This effect is non-destructive to the target's pixels, and can be used on animated FlxSprites.
	 * 
	 * @param	Target		The target FlxSprite you want to clone.
	 * @param	Strength	How strong you want the effect
	 * @param	Size		How 'thick' you want each piece of the glitch
	 * @param	Delay		How long (in seconds) between each glitch update
	 * @param	Direction	Which Direction you want the effect to be applied (HORIZONTAL or VERTICAL)
	 */
	public function new(Target:FlxSprite, Strength:Int = 4, Size:Int = 1, Delay:Float = 0.05, ?Direction:FlxGlitchDirection) 
	{
		super();
		graphic = glitchView = new FlxGlitchView(this, Target, Strength, Size, Delay, Direction);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		glitchView = null;
	}
	
	private function get_size():Int
	{
		return glitchView.size;
	}
	
	private function set_size(Value:Int):Int
	{
		return glitchView.size = Value;
	}
	
	private function get_delay():Float
	{
		return glitchView.delay;
	}
	
	private function set_delay(Value:Float):Float
	{
		return glitchView.delay = Value;
	}
	
	private function get_target():FlxBaseSprite
	{
		return glitchView.target;
	}
	
	private function set_target(Value:FlxBaseSprite):FlxBaseSprite
	{
		return glitchView.target = Value;
	}
	
	private function get_direction():FlxGlitchDirection
	{
		return glitchView.direction;
	}
	
	private function set_direction(Value:FlxGlitchDirection):FlxGlitchDirection
	{
		return glitchView.direction = Value;
	}
	
	private function get_strength():Int
	{
		return glitchView.strength;
	}
	
	private function set_strength(Value:Int):Int
	{
		return glitchView.strength = Value;
	}
}

enum FlxGlitchDirection
{
	HORIZONTAL;
	VERTICAL;
}

class FlxGlitchView extends FlxImage
{
	/**
	 * How thick each glitch segment should be.
	 */
	public var size(default, set):Int = 1;
	/**
	 * Time, in seconds, between glitch updates
	 */
	public var delay:Float = 0.05;
	/**
	 * The target FlxSprite that the glitch effect copies from.
	 */
	public var target(default, set):FlxBaseSprite;
	/**
	 * Which direction the glitch effect should be applied.
	 */
	public var direction(default, set):FlxGlitchDirection;
	/**
	 * How strong the glitch effect should be (how much it should move from the center)
	 */
	public var strength(default, set):Int = 2;
	
	private var _time:Float = 0;
	
	private var _regen:Bool = true;
	private var _update:Bool = true;
	
	/**
	 * Creates a new FlxGlitchSprite, which clones a target FlxSprite and applies a Glitch-distortion effect to the clone.
	 * This effect is non-destructive to the target's pixels, and can be used on animated FlxSprites.
	 * 
	 * @param	Target		The target FlxSprite you want to clone.
	 * @param	Strength	How strong you want the effect
	 * @param	Size		How 'thick' you want each piece of the glitch
	 * @param	Delay		How long (in seconds) between each glitch update
	 * @param	Direction	Which Direction you want the effect to be applied (HORIZONTAL or VERTICAL)
	 */
	public function new(Parent:FlxBaseSprite, Target:FlxBaseSprite, Strength:Int = 4, Size:Int = 1, Delay:Float = 0.05, ?Direction:FlxGlitchDirection) 
	{
		super(Parent);
		target = Target;
		strength = Strength;
		size = Size;
		direction = (Direction != null) ? Direction : HORIZONTAL;
		initPixels();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		target = null;
		direction = null;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_time > delay)
		{
			_time = 0;
		}
		else
		{
			_time += elapsed;
		}
	}
	
	override public function draw():Void
	{
		if (alpha == 0 || target == null)
			return;
		
		if (_regen)
			initPixels();
		
		if (_time == 0 || _update)
			updatePixels();
		
		super.draw();
	}
	
	private function updatePixels():Void
	{
		_time = 0;
		pixels.lock();
		_flashRect2.setTo(0, 0, texture.width, texture.height);
		pixels.fillRect(_flashRect2, FlxColor.TRANSPARENT);
		var targetPixels:BitmapData = target.graphic.getFlxFrameBitmapData();
		var p:Int = 0;
		
		if (direction == HORIZONTAL)
		{
			while (p < target.frameHeight) 
			{
				_flashRect2.setTo(0, p, target.frameWidth, size);
				if (_flashRect2.bottom > target.frameHeight)
					_flashRect2.bottom = target.frameHeight;
				
				_flashPoint.setTo(FlxG.random.int( -strength, strength) + strength, p);
				p += Std.int(_flashRect2.height);
				pixels.copyPixels(targetPixels, _flashRect2, _flashPoint);
			}
		}
		else
		{
			while (p < target.frameWidth) 
			{
				_flashRect2.setTo(p, 0, size, target.frameHeight);
				if (_flashRect2.right > target.frameWidth)
					_flashRect2.right = target.frameWidth;
				
				_flashPoint.setTo(p, FlxG.random.int( -strength, strength) + strength);
				p += Std.int(_flashRect2.width);
				pixels.copyPixels(targetPixels, _flashRect2, _flashPoint);
			}
		}
		
		pixels.unlock();
		dirty = true;
	}
	
	private function initPixels():Void
	{
		if (!_regen)	return;
		
		var oldTexture:FlxTexture = texture;
		var oldWidth:Int = 0;
		var oldHeight:Int = 0;
		
		if (oldTexture != null)
		{
			oldWidth = oldTexture.width;
			oldHeight = oldTexture.height;
		}
		
		parent.setPosition(target.x - (direction == HORIZONTAL ? strength : 0), target.y - (direction == VERTICAL ? strength : 0));
		
		var targetPixels:BitmapData = target.graphic.getFlxFrameBitmapData();
		var newWidth:Int = target.frameWidth + (direction == HORIZONTAL ? strength * 2 : 0);
		var newHeight:Int = target.frameHeight + (direction == VERTICAL ? strength * 2 : 0 );
		
		if (newWidth != oldWidth || newHeight != oldHeight)
		{
			makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, true);
		}
		else
		{
			_flashRect2.setTo(0, 0, texture.width, texture.height);
			texture.bitmap.fillRect(_flashRect2, FlxColor.TRANSPARENT);
		}
		
		_flashPoint.setTo((direction == HORIZONTAL ? strength : 0), (direction == VERTICAL ? strength : 0));
		_flashRect2.setTo(0, 0, targetPixels.width, targetPixels.height);
		pixels.copyPixels(targetPixels, _flashRect2, _flashPoint);
		_flashRect2.setTo(0, 0, texture.width, texture.height);
		dirty = true;
		_regen = false;
		FlxG.bitmap.removeIfNoUse(oldTexture);
	}
	
	private function set_direction(Value:FlxGlitchDirection):FlxGlitchDirection
	{
		if (direction != Value)
		{
			direction = Value;
			_regen = true;
		}
		return direction;
	}
	
	private function set_strength(Value:Int):Int
	{
		if (strength != Value)
		{
			strength = Value;
			_regen = true;
		}
		return strength;
	}
	
	private function set_target(Value:FlxBaseSprite):FlxBaseSprite
	{
		if (target != Value)
		{
			target = Value;
			_regen = true;
		}
		
		return Value;
	}
	
	private function set_size(Value:Int):Int
	{
		if (size != Value)
		{
			size = Value;
			_update = true;
		}
		
		return Value;
	}
	
	override public function getFlxFrameBitmapData():BitmapData 
	{
		if (_regen)
			initPixels();
		
		if (_time == 0 || _update)
			updatePixels();
		
		return super.getFlxFrameBitmapData();
	}
}