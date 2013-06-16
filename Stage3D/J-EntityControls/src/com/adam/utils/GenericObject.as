﻿// com.adam.utils.GenericObject// Adam Riggs//package com.adam.utils {	import com.adam.events.MuleEvent;	import com.adam.utils.AppData;	import com.greensock.TweenLite;		import flash.display.Sprite;	import flash.events.*;		public class GenericObject extends Sprite {				//vars				//objects		private var appData:AppData=AppData.instance;				//const		public const NAME:String="genericObject";		public const RETURNTYPE:String=NAME;				public function GenericObject(){						init();		}		//*****Initialization Routines				public function init():void{			debug("init()");						initVars();			initEvents();			initObjs();		}				private function initVars():void{					}				private function initEvents():void{			appData.eventManager.listen(NAME, onGenericObject);		}				private function initObjs():void{					}		//*****Core Functionality						//*****Event Handlers				private function onGenericObject(e:MuleEvent):void{			/*debug("onGenericObject()");			debug("e.data.sender=="+e.data.sender);			debug("e.data.type=="+e.data.type);*/			switch(e.data.type){																default:					debug("onGenericObject()");					debug("*type not found");					debug("e.data.sender=="+e.data.sender);					debug("e.data.type=="+e.data.type);				break;							}		}				//*****Gets and Sets						//*****Utility Functions				//**visibility		public function show():void{			this.visible = true;		}				public function hide():void{			this.visible = false;		}				//**debug		private function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end package