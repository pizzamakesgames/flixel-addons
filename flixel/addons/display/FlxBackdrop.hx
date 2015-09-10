package flixel.addons.display;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.addons.display.views.FlxBackdropView;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxTexture;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTilesItem;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint.FlxCallbackPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Used for showing infinitely scrolling backgrounds.
 * @author Chevy Ray
 */
class FlxBackdrop extends FlxSprite
{
	public var backdropView(default, null):FlxBackdropView;
	
	/**
	 * Creates an instance of the FlxBackdrop class, used to create infinitely scrolling backgrounds.
	 * 
	 * @param   Graphic		The image you want to use for the backdrop.
	 * @param   ScrollX 	Scrollrate on the X axis.
	 * @param   ScrollY 	Scrollrate on the Y axis.
	 * @param   RepeatX 	If the backdrop should repeat on the X axis.
	 * @param   RepeatY 	If the backdrop should repeat on the Y axis.
	 * @param	SpaceX		Amount of spacing between tiles on the X axis
	 * @param	SpaceY		Amount of spacing between tiles on the Y axis
	 */
	public function new(Graphic:FlxGraphicAsset, ScrollX:Float = 1, ScrollY:Float = 1, RepeatX:Bool = true, RepeatY:Bool = true, SpaceX:Int = 0, SpaceY:Int = 0) 
	{
		super();
		graphic = backdropView = new FlxBackdropView(this, Graphic, ScrollX, ScrollY, RepeatX, RepeatY, SpaceX, SpaceY);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		backdropView = null;
	}
	
	public function loadFrame(Frame:FlxFrame):FlxBackdrop
	{
		backdropView.loadFrame(Frame);
		return this;
	}
}
