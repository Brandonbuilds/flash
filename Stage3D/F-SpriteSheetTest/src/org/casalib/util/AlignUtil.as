/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2010, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package org.casalib.util {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
		Provides utility functions for aligning.
		
		@author Aaron Clinger
		@author Jon Adams
		@version 03/28/10
	*/
	public class AlignUtil {
		public static const BOTTOM:String        = 'bottom';
		public static const BOTTOM_CENTER:String = 'bottomCenter';
		public static const BOTTOM_LEFT:String   = 'bottomLeft';
		public static const BOTTOM_RIGHT:String  = 'bottomRight';
		public static const CENTER:String        = 'center';
		public static const LEFT:String          = 'left';
		public static const MIDDLE:String        = 'middle';
		public static const MIDDLE_CENTER:String = 'middleCenter';
		public static const MIDDLE_LEFT:String   = 'middleLeft';
		public static const MIDDLE_RIGHT:String  = 'middleRight';
		public static const RIGHT:String         = 'right';
		public static const TOP:String           = 'top';
		public static const TOP_CENTER:String    = 'topCenter';
		public static const TOP_LEFT:String      = 'topLeft';
		public static const TOP_RIGHT:String     = 'topRight';
		
		/**
			Aligns a <code>DisplayObject</code> to the bounding <code>Rectangle</code> acording to the defined alignment.
			
			@param alignment: The alignment type/position.
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function align(alignment:String, displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			
			var rectangle:Rectangle;
			
			if(displayObject.width == 0 && displayObject.height == 0)
			{
				rectangle = new Rectangle(displayObject.x, displayObject.y, 0, 0);
			}
			else
			{
				rectangle = displayObject.getBounds(targetCoordinateSpace != null ? targetCoordinateSpace : displayObject);
			}
			
			rectangle.left *= displayObject.scaleX;
			rectangle.right *= displayObject.scaleX;
			rectangle.top *= displayObject.scaleY;
			rectangle.bottom *= displayObject.scaleY;
			
			var targetPosition:Point = AlignUtil._getPosition(alignment, rectangle, bounds, outside);
			
			switch (alignment) {
				case AlignUtil.BOTTOM_LEFT :
				case AlignUtil.LEFT :
				case AlignUtil.MIDDLE_LEFT :
				case AlignUtil.TOP_LEFT :
				case AlignUtil.BOTTOM_CENTER :
				case AlignUtil.CENTER :
				case AlignUtil.MIDDLE_CENTER :
				case AlignUtil.TOP_CENTER :
				case AlignUtil.BOTTOM_RIGHT:
				case AlignUtil.MIDDLE_RIGHT:
				case AlignUtil.RIGHT:
				case AlignUtil.TOP_RIGHT:
					displayObject.x += targetPosition.x;
					break;
			}
			
			switch (alignment) {
				case AlignUtil.TOP:
				case AlignUtil.TOP_CENTER:
				case AlignUtil.TOP_LEFT:
				case AlignUtil.TOP_RIGHT:
				case AlignUtil.MIDDLE :
				case AlignUtil.MIDDLE_CENTER :
				case AlignUtil.MIDDLE_LEFT :
				case AlignUtil.MIDDLE_RIGHT :
				case AlignUtil.BOTTOM:
				case AlignUtil.BOTTOM_CENTER:
				case AlignUtil.BOTTOM_LEFT:
				case AlignUtil.BOTTOM_RIGHT:
					displayObject.y += targetPosition.y;
					break;
			}
			
			if (snapToPixel)
				AlignUtil.alignToPixel(displayObject);
		}
		
		/**
			Aligns a <code>Rectangle</code> to another <code>Rectangle</code>.
			
			@param align: The alignment type/position.
			@param rectangle: The <code>Rectangle</code> to align.
			@param bounds: The area in which to align the <code>Rectangle</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>Rectangle</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>Rectangle</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@return A new aligned <code>Rectangle</code>.
		*/
		public static function alignRectangle(alignment:String, rectangle:Rectangle, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false):Rectangle {
			const alignedRectangle:Rectangle = rectangle.clone();
			
			var offsetPoint:Point = AlignUtil._getPosition(alignment, rectangle, bounds, outside);
			
			alignedRectangle.offsetPoint(offsetPoint);
			
			if (snapToPixel) {
				alignedRectangle.x = Math.round(alignedRectangle.x);
				alignedRectangle.y = Math.round(alignedRectangle.y);
			}
			
			return alignedRectangle;
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the nearest Pixel.
			
			@param displayObject: The <code>DisplayObject</code> to align.
		*/
		public static function alignToPixel(displayObject:DisplayObject):void {
			displayObject.x = Math.round(displayObject.x);
			displayObject.y = Math.round(displayObject.y);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the bottom of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignBottom(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.BOTTOM, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the bottom left of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignBottomLeft(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.BOTTOM_LEFT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the bottom and horizontal center of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignBottomCenter(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.BOTTOM_CENTER, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the bottom right of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignBottomRight(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.BOTTOM_RIGHT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the horizontal center of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignCenter(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.CENTER, displayObject, bounds, snapToPixel);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the left side of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignLeft(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.LEFT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the vertical middle of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignMiddle(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.MIDDLE, displayObject, bounds, snapToPixel);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the vertical middle and left side of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignMiddleLeft(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.MIDDLE_LEFT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the vertical middle and horizontal center of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignMiddleCenter(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.MIDDLE_CENTER, displayObject, bounds, snapToPixel);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the vertical middle and right side of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignMiddleRight(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.MIDDLE_RIGHT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the right side of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignRight(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.RIGHT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the top of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignTop(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.TOP, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the top left of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignTopLeft(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.TOP_LEFT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the top side and horizontal center of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignTopCenter(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.TOP_CENTER, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		/**
			Aligns a <code>DisplayObject</code> to the top right of the bounding <code>Rectangle</code>.
			
			@param displayObject: The <code>DisplayObject</code> to align.
			@param bounds: The area in which to align the <code>DisplayObject</code>.
			@param snapToPixel: Force the position to whole pixels <code>true</code>, or to let the <code>DisplayObject</code> be positioned on sub-pixels <code>false</code>.
			@param outside: Align the <code>DisplayObject</code> to the outside of the bounds <code>true</code>, or the inside <code>false</code>.
			@param targetCoordinateSpace: The scope for the bounds. Specify if the displayObject is not in the same scope as the desired cordinate space.
		*/
		public static function alignTopRight(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true, outside:Boolean = false, targetCoordinateSpace:DisplayObject = null):void {
			AlignUtil.align(AlignUtil.TOP_RIGHT, displayObject, bounds, snapToPixel, outside, targetCoordinateSpace);
		}
		
		protected static function _getPosition(alignment:String, rectangle:Rectangle, bounds:Rectangle, outside:Boolean):Point {
			const offestPoint:Point = new Point();
			
			switch (alignment) {
				case AlignUtil.BOTTOM_LEFT :
				case AlignUtil.LEFT :
				case AlignUtil.MIDDLE_LEFT :
				case AlignUtil.TOP_LEFT :
					offestPoint.x = (bounds.x - rectangle.x) - (outside ? rectangle.width : 0);
					break;
				case AlignUtil.BOTTOM_CENTER :
				case AlignUtil.CENTER :
				case AlignUtil.MIDDLE_CENTER :
				case AlignUtil.TOP_CENTER :
					offestPoint.x = (bounds.x - rectangle.x) + (bounds.width * .5) - (rectangle.width * .5);
					break;
				case AlignUtil.BOTTOM_RIGHT:
				case AlignUtil.MIDDLE_RIGHT:
				case AlignUtil.RIGHT:
				case AlignUtil.TOP_RIGHT:
					offestPoint.x = ((bounds.x - rectangle.x) + bounds.width) - (outside ? 0 : rectangle.width);
					break;
			}
			
			switch (alignment) {
				case AlignUtil.TOP:
				case AlignUtil.TOP_CENTER:
				case AlignUtil.TOP_LEFT:
				case AlignUtil.TOP_RIGHT:
					offestPoint.y = (bounds.y - rectangle.y) - (outside ? rectangle.height : 0);
					break;
				case AlignUtil.MIDDLE :
				case AlignUtil.MIDDLE_CENTER :
				case AlignUtil.MIDDLE_LEFT :
				case AlignUtil.MIDDLE_RIGHT :
					offestPoint.y = (bounds.y - rectangle.y) + (bounds.height * .5) - (rectangle.height * .5);
					break;
				case AlignUtil.BOTTOM:
				case AlignUtil.BOTTOM_CENTER:
				case AlignUtil.BOTTOM_LEFT:
				case AlignUtil.BOTTOM_RIGHT:
					offestPoint.y = ((bounds.y - rectangle.y) + bounds.height) - (outside ? 0 : rectangle.height);
					;
					break;
			}
			
			return offestPoint;
		}
	}
}