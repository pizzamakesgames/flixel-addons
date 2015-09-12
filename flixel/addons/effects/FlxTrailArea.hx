package flixel.addons.effects;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.effects.FlxTrailArea.FlxTrailPlugin;
import flixel.FlxBaseSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.views.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.views.FlxGraphicPlugin;

/**
 * This provides an area in which the added sprites have a trail effect. Usage: Create the FlxTrailArea and 
 * add it to the display. Then add all sprites that should have a trail effect via the add function.
 * @author KeyMaster
 */
class FlxTrailArea extends FlxSprite 
{
	public var trailPlugin(default, null):FlxTrailPlugin;
	
	/**
	 * How often the trail is updated, in frames. Default value is 2, or "every frame".
	 */
	public var delay(get, set):Int;
	
	/**
	 * If this is true, the render process ignores any color/scale/rotation manipulation of the sprites
	 * with the advantage of being faster
	 */
	public var simpleRender(get, set):Bool;
	
	/**
	 * Specifies the blendMode for the trails.
	 * Ignored in simple render mode. Only works on the flash target.
	 */
	public var blendMode(get, set):BlendMode;
	
	/**
	 * Stores all sprites that have a trail.
	 */
	public var group(get, set):FlxTypedGroup<FlxBaseSprite>;
	
	/**
	 * The bitmap's red value is multiplied by this every update
	 */
	public var redMultiplier(get, set):Float;
	
	/**
	 * The bitmap's green value is multiplied by this every update
	 */
	public var greenMultiplier(get, set):Float;
	
	/**
	 * The bitmap's blue value is multiplied by this every update
	 */
	public var blueMultiplier(get, set):Float;
	
	/**
	 * The bitmap's alpha value is multiplied by this every update
	 */
	public var alphaMultiplier(get, set):Float;
	
	/**
	 * The bitmap's red value is offsettet by this every update
	 */
	public var redOffset(get, set):Float;
	
	/**
	 * The bitmap's green value is offsettet by this every update
	 */
	public var greenOffset(get, set):Float;
	
	/**
	 * The bitmap's blue value is offsettet by this every update
	 */
	public var blueOffset(get, set):Float;
	
	/**
	 * The bitmap's alpha value is offsettet by this every update
	 */
	public var alphaOffset(get, set):Float;
	
	 /**
	  * Creates a new FlxTrailArea, in which all added sprites get a trail effect.
	  * 
	  * @param	X				x position of the trail area
	  * @param	Y				y position of the trail area
	  * @param	Width			The width of the area - defaults to FlxG.width
	  * @param	Height			The height of the area - defaults to FlxG.height
	  * @param	AlphaMultiplier By what the area's alpha is multiplied per update
	  * @param	Delay			How often to update the trail. 1 updates every frame
	  * @param	SimpleRender 	If simple rendering should be used. Ignores all sprite transformations
	  * @param	Antialiasing	If sprites should be smoothed when drawn to the area. Ignored when simple rendering is on
	  * @param	TrailBlendMode 	The blend mode used for the area. Only works in flash
	  */
	public function new(X:Int = 0, Y:Int = 0, Width:Int = 0, Height:Int = 0, AlphaMultiplier:Float = 0.8, Delay:Int = 2, SimpleRender:Bool = false, Antialiasing:Bool = false, ?TrailBlendMode:BlendMode) 
	{
		super(X, Y);
		trailPlugin = new FlxTrailPlugin(this, Width, Height, AlphaMultiplier, Delay, SimpleRender, Antialiasing, TrailBlendMode);
	}
	
	/**
	 * Sets the FlxTrailArea to a new size. Clears the area!
	 * 
	 * @param	Width		The new width
	 * @param	Height		The new height
	 */
	override public function setSize(Width:Float, Height:Float)
	{
		trailPlugin.setSize(Width, Height);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		trailPlugin = FlxDestroyUtil.destroy(trailPlugin);
	}
	
	override public function draw():Void 
	{
		trailPlugin.draw();
		super.draw();
	}
	
	/**
	 * Wipes the trail area
	 */
	public function resetTrail():Void
	{
		trailPlugin.resetTrail();
	}
	
	/**
	 * Adds a FlxSprite to the FlxTrailArea. Not an add() in the traditional sense,
	 * this just enables the trail effect for the sprite. You still need to add it to your state for it to update!
	 * 
	 * @param	Sprite		The sprite to enable the trail effect for
	 * @return 	The FlxSprite, useful for chaining stuff together
	 */
	public function add(Sprite:FlxBaseSprite):FlxBaseSprite
	{
		return trailPlugin.add(Sprite);
	}
	
	/**
	 * Setter for width, defaults to FlxG.width, creates new _rendeBitmap if neccessary
	 */
	override private function set_width(Width:Float):Float 
	{
		if (trailPlugin != null && Width != trailPlugin.width)
			trailPlugin.width = Width;
		
		return super.set_width(Width);
	}
	
	/**
	 * Setter for height, defaults to FlxG.height, creates new _rendeBitmap if neccessary
	 */
	override private function set_height(Height:Float):Float
	{
		if (trailPlugin != null && Height != trailPlugin.height)
			trailPlugin.height = Height;
		
		return super.set_height(Height);
	}
	
	private function get_delay():Int
	{
		return trailPlugin.delay;
	}
	
	private function set_delay(Value:Int):Int
	{
		return trailPlugin.delay = Value;
	}
	
	private function get_simpleRender():Bool
	{
		return trailPlugin.simpleRender;
	}
	
	private function set_simpleRender(Value:Bool):Bool
	{
		return trailPlugin.simpleRender = Value;
	}
	
	private function get_blendMode():BlendMode
	{
		return trailPlugin.blendMode;
	}
	
	private function set_blendMode(Value:BlendMode):BlendMode
	{
		return trailPlugin.blendMode = Value;
	}
	
	private function get_group():FlxTypedGroup<FlxBaseSprite>
	{
		return trailPlugin.group;
	}
	
	private function set_group(Value:FlxTypedGroup<FlxBaseSprite>):FlxTypedGroup<FlxBaseSprite>
	{
		return trailPlugin.group = Value;
	}
	
	private function get_redMultiplier():Float
	{
		return trailPlugin.redMultiplier;
	}
	
	private function set_redMultiplier(Value:Float):Float
	{
		return trailPlugin.redMultiplier = Value;
	}
	
	private function get_greenMultiplier():Float
	{
		return trailPlugin.greenMultiplier;
	}
	
	private function set_greenMultiplier(Value:Float):Float
	{
		return trailPlugin.greenMultiplier = Value;
	}
	
	private function get_blueMultiplier():Float
	{
		return trailPlugin.blueMultiplier;
	}
	
	private function set_blueMultiplier(Value:Float):Float
	{
		return trailPlugin.blueMultiplier = Value;
	}
	
	private function get_alphaMultiplier():Float
	{
		return trailPlugin.alphaMultiplier;
	}
	
	private function set_alphaMultiplier(Value:Float):Float
	{
		return trailPlugin.alphaMultiplier = Value;
	}
	
	private function get_redOffset():Float
	{
		return trailPlugin.redOffset;
	}
	
	private function set_redOffset(Value:Float):Float
	{
		return trailPlugin.redOffset = Value;
	}
	
	private function get_greenOffset():Float
	{
		return trailPlugin.greenOffset;
	}
	
	private function set_greenOffset(Value:Float):Float
	{
		return trailPlugin.greenOffset = Value;
	}
	
	private function get_blueOffset():Float
	{
		return trailPlugin.blueOffset;
	}
	
	private function set_blueOffset(Value:Float):Float
	{
		return trailPlugin.blueOffset = Value;
	}
	
	private function get_alphaOffset():Float
	{
		return trailPlugin.alphaOffset;
	}
	
	private function set_alphaOffset(Value:Float):Float
	{
		return trailPlugin.alphaOffset = Value;
	}
}

class FlxTrailPlugin extends FlxGraphicPlugin
{
	private static var point:Point = new Point();
	
	/**
	 * How often the trail is updated, in frames. Default value is 2, or "every frame".
	 */
	public var delay:Int = 2;
	
	/**
	 * If this is true, the render process ignores any color/scale/rotation manipulation of the sprites
	 * with the advantage of being faster
	 */
	public var simpleRender:Bool = false;
	
	/**
	 * Specifies the blendMode for the trails.
	 * Ignored in simple render mode. Only works on the flash target.
	 */
	public var blendMode:BlendMode = null;
	
	/**
	 * Stores all sprites that have a trail.
	 */
	public var group:FlxTypedGroup<FlxBaseSprite>;
	
	/**
	 * The bitmap's red value is multiplied by this every update
	 */
	public var redMultiplier:Float = 1;
	
	/**
	 * The bitmap's green value is multiplied by this every update
	 */
	public var greenMultiplier:Float = 1;
	
	/**
	 * The bitmap's blue value is multiplied by this every update
	 */
	public var blueMultiplier:Float = 1;
	
	/**
	 * The bitmap's alpha value is multiplied by this every update
	 */
	public var alphaMultiplier:Float;
	
	/**
	 * The bitmap's red value is offsettet by this every update
	 */
	public var redOffset:Float = 0;
	
	/**
	 * The bitmap's green value is offsettet by this every update
	 */
	public var greenOffset:Float = 0;
	
	/**
	 * The bitmap's blue value is offsettet by this every update
	 */
	public var blueOffset:Float = 0;
	
	/**
	 * The bitmap's alpha value is offsettet by this every update
	 */
	public var alphaOffset:Float = 0;
	
	/**
	 * Counts the frames passed.
	 */
	private var _counter:Int = 0;
	
	public var width(get, set):Float;
	
	public var height(get, set):Float;
	
	/**
	 * Internal width variable
	 * Initialized to 1 to prevent invalid bitmapData during construction
	 */
	private var _width:Float = 1;
	
	/**
	 * Internal height variable
	 * Initialized to 1 to prevent invalid bitmapData during construction
	 */
	private var _height:Float = 1;
	
	/**
	 * Internal helper var, linking to area's pixels
	 */
	private var _areaPixels:BitmapData;
	
	public function new(Parent:FlxBaseSprite, Width:Int = 0, Height:Int = 0, AlphaMultiplier:Float = 0.8, Delay:Int = 2, SimpleRender:Bool = false, Antialiasing:Bool = false, ?TrailBlendMode:BlendMode)
	{
		super(Parent);
		
		group = new FlxTypedGroup<FlxBaseSprite>();
		
		//Sync variables
		delay = Delay;
		simpleRender = SimpleRender;
		blendMode = TrailBlendMode;
		graphic.antialiasing = Antialiasing;
		alphaMultiplier = AlphaMultiplier;
		
		setSize(Width, Height);
		graphic.pixels = _areaPixels;
	}
	
	/**
	 * Sets the FlxTrailArea to a new size. Clears the area!
	 * 
	 * @param	Width		The new width
	 * @param	Height		The new height
	 */
	public function setSize(Width:Float, Height:Float)
	{
		Width = (Width <= 0) ? FlxG.width : Width;
		Height = (Height <= 0) ? FlxG.height : Height;
		
		if ((Width != _width) || (Height != _height)) 
		{
			_width = Width;
			_height = Height;
			_areaPixels = new BitmapData(Std.int(_width), Std.int(_height), true, FlxColor.TRANSPARENT);
		}
	}
	
	override public function destroy():Void 
	{
		group = FlxDestroyUtil.destroy(group);
		blendMode = null;
		
		if (graphic.pixels != _areaPixels)
		{
			_areaPixels.dispose();
		}
		_areaPixels = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		//Count the frames
		_counter++;
		
		if (_counter >= delay) 
		{
			_counter = 0;
			_areaPixels.lock();
			//Color transform bitmap
			var cTrans = new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
			_areaPixels.colorTransform(new Rectangle(0, 0, _areaPixels.width, _areaPixels.height), cTrans);
			
			//Copy the graphics of all sprites on the renderBitmap
			for (member in group.members)
			{
				if (member.exists) 
				{
					point.setTo(member.x - parent.x, member.y - parent.y);
					
					if (simpleRender) 
					{
						member.graphic.paintOn(_areaPixels, point, true, false);
					}
					else 
					{
						member.graphic.drawOn(_areaPixels, Std.int(point.x), Std.int(point.y));
					}
					
				}
			}
			
			_areaPixels.unlock();
			graphic.pixels = _areaPixels;
		}
	}
	
	/**
	 * Wipes the trail area
	 */
	public inline function resetTrail():Void
	{
		_areaPixels.fillRect(new Rectangle(0, 0, _areaPixels.width, _areaPixels.height), FlxColor.TRANSPARENT);
	}
	
	/**
	 * Adds a FlxSprite to the FlxTrailArea. Not an add() in the traditional sense,
	 * this just enables the trail effect for the sprite. You still need to add it to your state for it to update!
	 * 
	 * @param	Sprite		The sprite to enable the trail effect for
	 * @return 	The FlxSprite, useful for chaining stuff together
	 */
	public inline function add(Sprite:FlxBaseSprite):FlxBaseSprite
	{
		return group.add(Sprite);
	}
	
	/**
	 * Redirects width to _width
	 */
	private function get_width():Float
	{
		return _width;
	}
	
	/**
	 * Setter for width, defaults to FlxG.width, creates new _rendeBitmap if neccessary
	 */
	private function set_width(Width:Float):Float 
	{
		Width = (Width <= 0) ? FlxG.width : Width;
		
		if (Width != _width) 
		{
			_areaPixels = new BitmapData(Std.int(Width), Std.int(_height), true, FlxColor.TRANSPARENT);
		}
		
		return _width = Width;
	}
	
	/**
	 * Redirects height to _height
	 */
	private function get_height():Float
	{
		return _height;
	}
	
	/**
	 * Setter for height, defaults to FlxG.height, creates new _rendeBitmap if neccessary
	 */
	private function set_height(Height:Float):Float
	{
		Height = (Height <= 0) ? FlxG.height : Height;
		
		if (Height != _height) 
		{
			_areaPixels = new BitmapData(Std.int(_width), Std.int(Height), true, FlxColor.TRANSPARENT);
		}
		
		return _height = Height;
	}
}