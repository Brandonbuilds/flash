﻿// com.app.AppData// Adam Riggs//package com.adam.utils{		import com.adam.apis.Flickr;	import com.adam.db.Database;	import com.adam.debug.DebugWindow;	import com.adam.events.EventManager;	import com.adam.fms.FlashMediaServer;		import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.*;	import flash.xml.*;		public class AppData{				public var mainXML:XML;		public var playerType:String;		public var buildType:String;		public var isLocal:Boolean;				public var flickr:Flickr;		public var flashVars:Object;		public var bandwidth:Object;		public var main:Sprite;		public var shell:Sprite;		public var eventManager:EventManager;		public var database:Database;		public var debugWindow:DebugWindow;				public var mainWidth:int;		public var mainHeight:int;				/** Storage for the singleton instance. */		private static const _instance:AppData = new AppData( AppDataLock );				public function AppData(lock:Class){			trace("AppData()");						// Verify that the lock is the correct class reference.			if ( lock != AppDataLock )			{				throw new Error( "Invalid AppData access.  Use AppData.instance instead." );			}		}		//*****Initialization functions				public function init():void{			trace("AppData.init()");		}		//*****Core functionality				public function listObject(obj:Object):void{			for (var item:Object in obj) {				trace(item+"=="+obj[item]);			}		}				public function makeButton(mc:MovieClip, obj:Object):void{			mc.buttonMode=true;			mc.addEventListener(MouseEvent.CLICK, obj.onClick);		}				public function makeHoverButton(mc:MovieClip, obj:Object):void{			mc.buttonMode=true;			mc.mouseChildren=false;			mc.overBtn.visible=false;			mc.addEventListener(MouseEvent.CLICK, obj.onClick);			mc.addEventListener(MouseEvent.MOUSE_OVER, onOver);			mc.addEventListener(MouseEvent.MOUSE_OUT, onOut);		}				public function debug(objName:String, str:String):void{			trace(objName+": "+str);			eventManager.dispatch("debug", {msg:str, sender:objName});		}		//*****Event Handlers				private function onOver(e:MouseEvent):void{			e.currentTarget.overBtn.visible=true;		}				private function onOut(e:MouseEvent):void{			e.currentTarget.overBtn.visible=false;		}		//*****Gets and sets				public static function get instance():AppData		{			return _instance;		}			}}class AppDataLock{} 