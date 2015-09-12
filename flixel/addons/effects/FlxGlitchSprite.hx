package flixel.addons.effects;

import flixel.addons.effects.FlxGlitchSprite.FlxGlitchPlugin;
import flixel.graphics.views.FlxGraphicPlugin;
import flixel.FlxBaseSprite;
import flixel.FlxSprite;
import flixel.graphics.FlxTexture;
import flixel.graphics.views.FlxGraphic;
import flixel.graphics.views.FlxImage;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRandom;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * This creates a FlxSprite which copies a target FlxSprite and applies a non-destructive wave-distortion effect.
 * Usage: Create a FlxSprite object, position it where you want (don't add it), and then create a new FlxGlitchSprite, 
 * passing the Target object to it, and then add the sprite to your state/group.
 * Based, in part, from PhotonStorm's GlitchFX Class in Flixel Power Tools.
 * @author Tim Hely / tims-world.com
 */
class FlxGlitchSprite extends FlxSprite
{
	public var glitchPlugin(default, null):FlxGlitchPlugin;
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
	public function new(Target:FlxBaseSprite, Strength:Int = 4, Size:Int = 1, Delay:Float = 0.05, ?Direction:FlxGlitchDirection) 
	{
		super();
		graphic = new FlxImage(this);
		addPlugin(glitchPlugin = new FlxGlitchPlugin(this, Target, Strength, Size, Delay, Direction));
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		glitchPlugin = null;
	}
	
	private function get_size():Int
	{
		return glitchPlugin.size;
	}
	
	private function set_size(Value:Int):Int
	{
		return glitchPlugin.size = Value;
	}
	
	private function get_delay():Float
	{
		return glitchPlugin.delay;
	}
	
	private function set_delay(Value:Float):Float
	{
		return glitchPlugin.delay = Value;
	}
	
	private function get_target():FlxBaseSprite
	{
		return glitchPlugin.target;
	}
	
	private function set_target(Value:FlxBaseSprite):FlxBaseSprite
	{
		return glitchPlugin.target = Value;
	}
	
	private function get_direction():FlxGlitchDirection
	{
		return glitchPlugin.direction;
	}
	
	private function set_direction(Value:FlxGlitchDirection):FlxGlitchDirection
	{
		return glitchPlugin.direction = Value;
	}
	
	private function get_strength():Int
	{
		return glitchPlugin.strength;
	}
	
	private function set_strength(Value:Int):Int
	{
		return glitchPlugin.strength = Value;
	}
}

enum FlxGlitchDirection
{
	HORIZONTAL;
	VERTICAL;
}

class FlxGlitchPlugin extends FlxGraphicPlugin
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
		if (!graphic.visible || target == null)
			return;
		
		if (_regen)
			initPixels();
		
		if (_time == 0 || _update)
			updatePixels();
	}
	
	private function updatePixels():Void
	{
		_time = 0;
		
		var pixels:BitmapData = graphic.pixels;
		var texture:FlxTexture = graphic.texture;
		var rect:Rectangle = graphic._flashRect2;
		var point:Point = graphic._flashPoint;
		pixels.lock();
		rect.setTo(0, 0, texture.width, texture.height);
		pixels.fillRect(rect, FlxColor.TRANSPARENT);
		var targetPixels:BitmapData = target.graphic.getFlxFrameBitmapData();
		var p:Int = 0;
		
		if (direction == HORIZONTAL)
		{
			while (p < target.frameHeight) 
			{
				rect.setTo(0, p, target.frameWidth, size);
				if (rect.bottom > target.frameHeight)
					rect.bottom = target.frameHeight;
				
				point.setTo(FlxG.random.int( -strength, strength) + strength, p);
				p += Std.int(rect.height);
				pixels.copyPixels(targetPixels, rect, point);
			}
		}
		else
		{
			while (p < target.frameWidth) 
			{
				rect.setTo(p, 0, size, target.frameHeight);
				if (rect.right > target.frameWidth)
					rect.right = target.frameWidth;
				
				point.setTo(p, FlxG.random.int( -strength, strength) + strength);
				p += Std.int(rect.width);
				pixels.copyPixels(targetPixels, rect, point);
			}
		}
		
		pixels.unlock();
		graphic.dirty = true;
	}
	
	private function initPixels():Void
	{
		if (!_regen)	return;
		
		var oldTexture:FlxTexture = graphic.texture;
		var texture:FlxTexture = graphic.texture;
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
		
		var rect:Rectangle = graphic._flashRect2;
		var point:Point = graphic._flashPoint;
		
		if (newWidth != oldWidth || newHeight != oldHeight)
		{
			graphic.makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, true);
			texture = graphic.texture;
		}
		else
		{
			rect.setTo(0, 0, texture.width, texture.height);
			texture.bitmap.fillRect(rect, FlxColor.TRANSPARENT);
		}
		
		point.setTo((direction == HORIZONTAL ? strength : 0), (direction == VERTICAL ? strength : 0));
		rect.setTo(0, 0, targetPixels.width, targetPixels.height);
		graphic.pixels.copyPixels(targetPixels, rect, point);
		rect.setTo(0, 0, texture.width, texture.height);
		graphic.dirty = true;
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
}