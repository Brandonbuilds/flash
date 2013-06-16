﻿// com.app.view.View3D// Adam Riggs//package com.app.view {	import com.adam.events.MuleEvent;	import com.adam.utils.AppData;	import com.adobe.utils.AGALMiniAssembler;	import com.adobe.utils.PerspectiveMatrix3D;		import flash.display.Bitmap;	import flash.display.Sprite;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.display3D.Context3D;	import flash.display3D.Context3DProgramType;	import flash.display3D.Context3DRenderMode;	import flash.display3D.Context3DTextureFormat;	import flash.display3D.Context3DVertexBufferFormat;	import flash.display3D.IndexBuffer3D;	import flash.display3D.Program3D;	import flash.display3D.VertexBuffer3D;	import flash.display3D.textures.Texture;	import flash.events.*;	import flash.geom.Matrix3D;	import flash.geom.Rectangle;	import flash.geom.Vector3D;	import flash.utils.getTimer;		import mx.controls.Text;
		public class View3D extends Sprite{				//vars				//objects		private var appData:AppData=AppData.instance;		private var _context3D:Context3D;		private var _program:Program3D;		private var _vertices:Vector.<Number>;		private var _indices:Vector.<uint>;		private var _vertexBuffer:VertexBuffer3D;		private var _indexBuffer:IndexBuffer3D;		private var _vertexShader:AGALMiniAssembler;		private var _fragmentShader:AGALMiniAssembler;		private var _bitmap:Bitmap;		private var _texture:Texture;		private var _projectionTransform:PerspectiveMatrix3D;				[Embed( source = "../img/venus.jpg" )]		protected const TextureBitmap:Class;				//const		public const NAME:String="view3D";		public const RETURNTYPE:String=NAME;				/** Storage for the singleton instance. */		private static const _instance:View3D = new View3D(View3DLock);				public function View3D(lock:Class){			// Verify that the lock is the correct class reference.			if (lock != View3DLock)			{				throw new Error("Invalid View3D access.  Use View3D.instance instead.");			} else {				//init();			}		}		//*****Initialization Routines				public function init():void{			debug("init()");						if(stage){onAddedToStage();} else {addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);}		}				private function initVars():void{			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;			}				private function initEvents():void{			appData.eventManager.listen(NAME, onView3D);			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);			stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, onStageError);			addEventListener(Event.ENTER_FRAME, onEnterFrame);		}				private function initObjs():void{			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);		}				private function init3D():void{			//get context			_context3D = stage.stage3Ds[0].context3D;						//back buffer			_context3D.configureBackBuffer(800, 600, 0, false);						//vertex buffer			_vertices=Vector.<Number>([				-0.3,-0.3, 0, 0, 0, // x, y, z, u, v				-0.3, 0.3, 0, 0, 1,				 0.3, 0.3, 0, 1, 1,				 0.3,-0.3, 0, 1, 0			]);			_vertexBuffer=_context3D.createVertexBuffer(4,5);			_vertexBuffer.uploadFromVector(_vertices,0,4);						//index buffer			_indices=Vector.<uint>([0, 1, 2, 2, 3, 0]);			_indexBuffer=_context3D.createIndexBuffer(6);			_indexBuffer.uploadFromVector(_indices,0,6);						//texture			_bitmap=new TextureBitmap();			_texture=_context3D.createTexture(_bitmap.bitmapData.width,_bitmap.bitmapData.height, Context3DTextureFormat.BGRA,false);			_texture.uploadFromBitmapData(_bitmap.bitmapData);									//vertex shader			_vertexShader=new AGALMiniAssembler();			_vertexShader.assemble(Context3DProgramType.VERTEX,				"m44 op, va0, vc0\n" + // pos to clipspace				"mov v0, va1" // copy uv			);							//fragment shader			_fragmentShader=new AGALMiniAssembler();			_fragmentShader.assemble(Context3DProgramType.FRAGMENT,				"tex ft1, v0, fs0 <2d,linear,nomip>\n" +				"mov oc, ft1"			);						//program			_program=_context3D.createProgram();			_program.upload(_vertexShader.agalcode, _fragmentShader.agalcode);						//projection matrix			_projectionTransform = new PerspectiveMatrix3D();			var aspect:Number = 4/3;			var zNear:Number = 0.1;			var zFar:Number = 1000;			var fov:Number = 45*Math.PI/180;			_projectionTransform.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);					}		//*****Core Functionality						//*****Event Handlers				private function onEnterFrame(e:Event):void{			if ( !_context3D ) 				return;						//clear the color buffer and set the background color			_context3D.clear(0,0,0,1);						//set vertex position to register 0			_context3D.setVertexBufferAt(0,_vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);						//set color to register 1			_context3D.setVertexBufferAt(1,_vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_2);						//set the texture			_context3D.setTextureAt(0, _texture);						//set the shader program			_context3D.setProgram(_program);						//set rotation matrix			var m:Matrix3D = new Matrix3D();			m.appendRotation(getTimer()/30, Vector3D.Y_AXIS);			m.appendRotation(getTimer()/10, Vector3D.X_AXIS);			m.appendTranslation(0, 0, 2);			m.append(_projectionTransform);						_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);						//draw the triangles			_context3D.drawTriangles(_indexBuffer);						//display			_context3D.present();		}				private function onAddedToStage(e:Event=null):void{			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			initVars();			initEvents();			initObjs();		}				private function onContext3DCreated(e:Event):void{			removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);			debug("stage.stage3Ds[0].context3D.driverInfo=="+stage.stage3Ds[0].context3D.driverInfo);			init3D();		}				private function onStageError(e:ErrorEvent):void{			debug("e.errorID=="+e.errorID);			debug("e.type=="+e.type);		}				private function onSQL(e:MuleEvent):void{			/*debug("onSQL()");			debug("e.data.sender=="+e.data.sender);			debug("e.data.type=="+e.data.type);*/			switch(e.data.type){								case RETURNTYPE:									break;							}		}				private function onView3D(e:MuleEvent):void{			/*debug("onView3D()");			debug("e.data.sender=="+e.data.sender);			debug("e.data.type=="+e.data.type);*/			switch(e.data.type){								default:					debug("onView3D()");					debug("*type not found");					debug("e.data.sender=="+e.data.sender);					debug("e.data.type=="+e.data.type);					break;							}		}				//*****Gets and Sets				public static function get instance():View3D{return _instance;}		//*****Utility Functions				//**visibility		public function show():void{			this.visible = true;		}				public function hide():void{			this.visible = false;		}				//**debug		private function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end packageclass View3DLock{}