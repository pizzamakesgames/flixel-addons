package flixel.addons.effects;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.effects.FlxWaveSprite.FlxWaveView;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxTexture;
import flixel.graphics.views.FlxImage;
import flixel.util.FlxColor;
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
	
	public var waveView(default, null):FlxWaveView;
	
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
	public function new(Target:FlxSprite, ?Mode:FlxWaveMode, Strength:Int = 20, Center:Int = -1, Speed:Float = 3) 
	{
		super();
		graphic = waveView = new FlxWaveView(this, Target, Mode, Strength, Center, Speed);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		waveView = null;
	}
	
	private function get_strength():Int
	{
		return waveView.strength;
	}
	
	private function set_strength(value:Int):Int 
	{
		return waveView.strength = value;
	}
	
	private function get_mode():FlxWaveMode
	{
		return waveView.mode;
	}
	
	private function set_mode(value:FlxWaveMode):FlxWaveMode
	{
		return waveView.mode = value;
	}
	
	private function get_speed():Float
	{
		return waveView.speed;
	}
	
	private function set_speed(value:Float):Float
	{
		return waveView.speed = value;
	}
	
	private function get_center():Int
	{
		return waveView.center;
	}
	
	private function set_center(value:Int):Int
	{
		return waveView.center = center;
	}
}

enum FlxWaveMode
{
	ALL;
	TOP;
	BOTTOM;
}

class FlxWaveView extends FlxImage
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
	public function new(Parent:FlxBaseSprite, Target:FlxSprite, ?Mode:FlxWaveMode, Strength:Int = 20, Center:Int = -1, Speed:Float = 3) 
	{
		super(Parent);
		_target = Target;
		strength = Strength;
		mode = (Mode == null) ? ALL : Mode;
		speed = Speed;
		if (Center < 0)
			center = Std.int(_target.height * 0.5);
		dirty = true;
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
		super.update(elapsed);
		_time += elapsed * speed;
	}
	
	override public function draw():Void
	{
		if (!visible || alpha == 0)
			return;
			
		if (_regen)
			initPixels();
		
		pixels.lock();
		_flashRect2.setTo(0, 0, texture.width, texture.height);
		pixels.fillRect(_flashRect2, FlxColor.TRANSPARENT);
		
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
			
			_flashPoint.setTo(strength + offset, oY);
			_flashRect2.setTo(0, oY, _target.frameWidth, 1);
			pixels.copyPixels(targetPixels, _flashRect2, _flashPoint);
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
		
		dirty = true;
		super.draw();
	}
	
	private inline function calculateOffset(p:Float):Float
	{
		return (strength * BASE_STRENGTH) * BASE_STRENGTH * Math.sin((0.3 * p) + _time);
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
		
		parent.setPosition(_target.x - strength, _target.y);
		
		var targetPixels:BitmapData = _target.graphic.getFlxFrameBitmapData();
		var newWidth:Int = _target.frameWidth + (strength * 2);
		var newHeight:Int = _target.frameHeight;
		
		if (newWidth != oldWidth || newHeight != oldHeight)
		{
			makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, true);
		}
		else
		{
			_flashRect2.setTo(0, 0, texture.width, texture.height);
			texture.bitmap.fillRect(_flashRect2, FlxColor.TRANSPARENT);
		}
		
		_flashPoint.setTo(strength, 0);
		_flashRect2.setTo(0, 0, targetPixels.width, targetPixels.height);
		pixels.copyPixels(targetPixels, _flashRect2, _flashPoint);
		_flashRect2.setTo(0, 0, texture.width, texture.height);
		dirty = true;
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