﻿// com.adam.db.Database// Adam Riggs//package com.adam.db {	import flash.display.Sprite;	import flash.events.*;		//import gs.TweenLite;		import com.adam.utils.AppData;	import com.adam.events.MuleEvent;		public class Database extends Sprite {				private var appData:AppData=AppData.instance;				public var sql:SQLProxy;				public const NAME:String="database";				/** Storage for the singleton instance. */		private static const _instance:Database = new Database(DatabaseLock);				public function Database(lock:Class){			// Verify that the lock is the correct class reference.			if (lock != DatabaseLock)			{				throw new Error("Invalid Database access.  Use Database.instance instead.");			} else {				init();			}		}		//*****Initialization Routines				public function init():void{			//this.visible = false;			debug("init()");						initVars();			initEvents();			initData();		}				private function initVars():void{			//debug("initVars()");			sql=SQLProxy.instance;		}				private function initEvents():void{								}				private function initData():void{			//debug("initData()");					}		//*****Core Functionality												//*****Event Handlers												//*****Gets and Sets				public static function get instance():Database{return _instance;}		//*****Utility Functions						//**debug		private function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end packageclass DatabaseLock{} 