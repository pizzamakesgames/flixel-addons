package flixel.addons.effects;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.effects.FlxWaveSprite.FlxWavePlugin;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxTexture;
import flixel.graphics.views.FlxGraphicPlugin;
import flixel.graphics.views.FlxImage;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;

/**
 * This creates a FlxSprite which copies a target FlxSprite and applies a non-destructive wave-distortion effect.
 * Usage: Create a FlxSprite object, position it where you want (don't add it), and then create a new FlxWaveSprite, 
 * passing the Target object to it, and then add the FlxWaveSprite to your state/group.
 * @author Tim Hely / tims-world.com
 */
class FlxWaveSprite extends FlxSprite
{
	private static inline var BASE_STRENGTH:Float = 0.06;
	
	public var wavePlugin(default, null):FlxWavePlugin;
	
	/**
	 * Which mode we're using for the effect
	 */
	public var mode(get, set):FlxWaveMode;
	/**
	 * How fast should the wave effect be (higher = faster)
	 */
	public var speed(get, set):Float;
	/**
	 * The 'center' of our sprite (where the wave effect should start/end)
	 */
	public var center(get, set):Int;
	/**
	 * How strong the wave effect should be
	 */
	public var strength(get, set):Int;
	
	/**
	 * Creates a new FlxWaveSprite, which clones a target FlxSprite and applies a wave-distortion effect to the clone.
	 * 
	 * @param	Target		The target FlxSprite you want to clone.
	 * @param	Mode		Which Mode you would like to use for the effect. ALL = applies a constant distortion throughout the image, BOTTOM = makes the effect get stronger towards the bottom of the image, and TOP = the reverse of BOTTOM
	 * @param	Strength	How strong you want the effect
	 * @param	Center		The 'center' of the effect when using BOTTOM or TOP modes. Anything above(BOTTOM)/below(TOP) this point on the image will have no distortion effect.
	 * @param	Speed		How fast you want the effect to move. Higher values = faster.
	 */
	public function new(Target:FlxBaseSprite, ?Mode:FlxWaveMode, Strength:Int = 20, Center:Int = -1, Speed:Float = 3) 
	{
		super();
		graphic = new FlxImage(this);
		
		addPlugin(wavePlugin = new FlxWavePlugin(this, Target, Mode, Strength, Center, Speed));
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		wavePlugin = null;
	}
	
	private function get_strength():Int
	{
		return wavePlugin.strength;
	}
	
	private function set_strength(value:Int):Int 
	{
		return wavePlugin.strength = value;
	}
	
	private function get_mode():FlxWaveMode
	{
		return wavePlugin.mode;
	}
	
	private function set_mode(value:FlxWaveMode):FlxWaveMode
	{
		return wavePlugin.mode = value;
	}
	
	private function get_speed():Float
	{
		return wavePlugin.speed;
	}
	
	private function set_speed(value:Float):Float
	{
		return wavePlugin.speed = value;
	}
	
	private function get_center():Int
	{
		return wavePlugin.center;
	}
	
	private function set_center(value:Int):Int
	{
		return wavePlugin.center = center;
	}
}

enum FlxWaveMode
{
	ALL;
	TOP;
	BOTTOM;
}

class FlxWavePlugin extends FlxGraphicPlugin
{
	private static inline var BASE_STRENGTH:Float = 0.06;
	
	/**
	 * Which mode we're using for the effect
	 */
	public var mode:FlxWaveMode;
	
	/**
	 * How fast should the wave effect be (higher = faster)
	 */
	public var speed:Float;
	/**
	 * The 'center' of our sprite (where the wave effect should start/end)
	 */
	public var center:Int;
	/**
	 * How strong the wave effect should be
	 */
	public var strength(default, set):Int;
	
	/**
	 * The target FlxSprite we're going to be using
	 */
	private var _target:FlxBaseSprite;
	private var _targetOffset:Float = -999;
	
	private var _time:Float = 0;
	
	private var _regen:Bool = true;
	
	/**
	 * Creates a new FlxWaveSprite, which clones a target FlxSprite and applies a wave-distortion effect to the clone.
	 * 
	 * @param	Target		The target FlxSprite you want to clone.
	 * @param	Mode		Which Mode you would like to use for the effect. ALL = applies a constant distortion throughout the image, BOTTOM = makes the effect get stronger towards the bottom of the image, and TOP = the reverse of BOTTOM
	 * @param	Strength	How strong you want the effect
	 * @param	Center		The 'center' of the effect when using BOTTOM or TOP modes. Anything above(BOTTOM)/below(TOP) this point on the image will have no distortion effect.
	 * @param	Speed		How fast you want the effect to move. Higher values = faster.
	 */
	public function new(Parent:FlxBaseSprite, Target:FlxBaseSprite, ?Mode:FlxWaveMode, Strength:Int = 20, Center:Int = -1, Speed:Float = 3) 
	{
		super(Parent);
		_target = Target;
		strength = Strength;
		mode = (Mode == null) ? ALL : Mode;
		speed = Speed;
		if (Center < 0)
			center = Std.int(_target.height * 0.5);
		graphic.dirty = true;
		initPixels();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		_target = null;
		mode = null;
	}
	
	override public function update(elapsed:Float):Void
	{
		_time += elapsed * speed;
	}
	
	override public function draw():Void
	{
		if (!graphic.visible)
			return;
			
		if (_regen)
			initPixels();
		
		var pixels:BitmapData = graphic.pixels;
		var texture:FlxTexture = graphic.texture;
		var rect:Rectangle = graphic._flashRect2;
		var point:Point = graphic._flashPoint;
		
		pixels.lock();
		rect.setTo(0, 0, texture.width, texture.height);
		pixels.fillRect(rect, FlxColor.TRANSPARENT);
		
		var targetPixels:BitmapData = _target.graphic.getFlxFrameBitmapData();
		
		var offset:Float = 0;
		for (oY in 0..._target.frameHeight)
		{
			var p:Float = 0;
			switch (mode)
			{
				case ALL:
					offset = center * calculateOffset(oY);
					
				case BOTTOM:
					if (oY >= center)
					{
						p = oY - center;
						offset = p * calculateOffset(p);
					}
					
				case TOP:
					if (oY <= center)
					{
						p  = center - oY;
						offset = p * calculateOffset(p);
					}
			}
			
			point.setTo(strength + offset, oY);
			rect.setTo(0, oY, _target.frameWidth, 1);
			pixels.copyPixels(targetPixels, rect, point);
		}
		pixels.unlock();
		
		if (_targetOffset == -999)
		{
			_targetOffset = offset;
		}
		else
		{
			if (offset == _targetOffset)
				_time = 0;
		}
		
		graphic.dirty = true;
	}
	
	private inline function calculateOffset(p:Float):Float
	{
		return (strength * BASE_STRENGTH) * BASE_STRENGTH * Math.sin((0.3 * p) + _time);
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
		
		parent.setPosition(_target.x - strength, _target.y);
		
		var targetPixels:BitmapData = _target.graphic.getFlxFrameBitmapData();
		var newWidth:Int = _target.frameWidth + (strength * 2);
		var newHeight:Int = _target.frameHeight;
		
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
		
		point.setTo(strength, 0);
		rect.setTo(0, 0, targetPixels.width, targetPixels.height);
		graphic.pixels.copyPixels(targetPixels, rect, point);
		rect.setTo(0, 0, texture.width, texture.height);
		graphic.dirty = true;
		_regen = false;
		FlxG.bitmap.removeIfNoUse(oldTexture);
	}
	
	private function set_strength(value:Int):Int 
	{
		if (strength != value)
		{
			strength = value;
			_regen = true;
		}
		
		return strength;
	}
}