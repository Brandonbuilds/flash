// com.adam.utils.Sprite3D// Adam Riggs//package com.app.view{	import away3d.core.base.Vertex;		import com.adam.events.MuleEvent;	import com.adam.utils.AppData;		import flash.events.*;	import flash.geom.Point;
		public class Sprite3D {				//vars		protected var _pos:Point;		protected var _tex:Vector.<Number>;		protected var _id:uint;		protected var _alpha:Number;				protected var _speedX:Number;		protected var _speedY:Number;		protected var _rotation:Number;				protected var _texCount:uint;		protected var _texSize:uint;		protected var _animationCount:uint;				//objects		private var appData:AppData=AppData.instance;				//const		public const NAME:String="sprite3D";		public const RETURNTYPE:String=NAME;				public function Sprite3D(){						init();		}		//*****Initialization Routines				public function init():void{			debug("init()");						initVars();			initEvents();			initObjs();		}				private function initVars():void{			_alpha=1;			_animationCount=0;			_speedX=0;			_speedY=0;		}				private function initEvents():void{		}				private function initObjs():void{			_tex=new Vector.<Number>;		}		//*****Core Functionality				protected function getNextTex():Vector.<Number>{			//debug("getNextTex()");			var idx:uint=_animationCount*_texCount*_texSize;			if(idx>=_tex.length){				_animationCount=0;				idx=0;			}						_animationCount++;			return _tex.slice(idx,idx+(_texCount*_texSize));		}				protected function setTex(tx:Vector.<Number>):void{			for(var i:uint=0;i<tx.length;i++){				//debug("tx[i]=="+tx[i]);				_tex.push(tx[i]);			}		}		//*****Event Handlers				//*****Gets and Sets				public function set pos(value:Point):void{_pos=value;}		public function set tex(value:Vector.<Number>):void{setTex(value);}		public function set id(value:uint):void{_id=value;}		public function set alpha(value:Number):void{_alpha=value;}		public function set speedX(value:Number):void{_speedX=value;}		public function set speedY(value:Number):void{_speedY=value;}		public function set rotation(value:Number):void{_rotation=value;}				public function set texCount(value:uint):void{_texCount=value;}		public function set texSize(value:uint):void{_texSize=value;}				public function get pos():Point{return _pos;}		public function get nextTex():Vector.<Number>{return getNextTex();}		public function get id():uint{return _id;}		public function get alpha():Number{return _alpha;}		public function get speedX():Number{return _speedX;}		public function get speedY():Number{return _speedY;}		public function get rotation():Number{return _rotation;}		//*****Utility Functions				//**debug		private function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end package