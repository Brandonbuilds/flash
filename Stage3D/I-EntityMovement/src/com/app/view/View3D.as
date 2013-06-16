﻿// com.app.view.View3D// Adam Riggs//package com.app.view {	import away3d.core.base.Vertex;		import com.adam.events.MuleEvent;	import com.adam.utils.AppData;	import com.adobe.utils.AGALMiniAssembler;	import com.adobe.utils.PerspectiveMatrix3D;		import flash.display.Bitmap;	import flash.display.Sprite;	import flash.display3D.Context3D;	import flash.display3D.Context3DBlendFactor;	import flash.display3D.Context3DProgramType;	import flash.display3D.Context3DRenderMode;	import flash.display3D.Context3DTextureFormat;	import flash.display3D.Context3DVertexBufferFormat;	import flash.display3D.IndexBuffer3D;	import flash.display3D.Program3D;	import flash.display3D.VertexBuffer3D;	import flash.display3D.textures.Texture;	import flash.events.*;	import flash.geom.Matrix3D;	import flash.geom.Vector3D;	import flash.utils.getTimer;
		public class View3D extends Sprite{				//vars		protected var _vertexVertices:Vector.<Number>;		protected var _indices:Vector.<uint>;				protected var _vertexShaderCode:String;		protected var _fragmentShaderCode:String;				protected var _gvStart:uint;		protected var _gvCount:uint;		protected var _gvSize:uint;		protected var _startIndex:uint;		protected var _numIndices:uint;				protected var _aspect:Number;		protected var _zNear:Number;		protected var _zFar:Number;		protected var _fov:Number;				//protected var _spList:Vector.<uint>;		//protected var _spCount:uint;				//objects		protected var appData:AppData=AppData.instance;		protected var _context3D:Context3D;		protected var _program3D:Program3D;		protected var _vertexBuffer:VertexBuffer3D;		protected var _uvBuffer:VertexBuffer3D;		protected var _indexBuffer:IndexBuffer3D;		protected var _vertexShader:AGALMiniAssembler;		protected var _fragmentShader:AGALMiniAssembler;		protected var _projectionTransform:PerspectiveMatrix3D;		protected var _rotationMatrix:Matrix3D;				protected var _spriteSheet:SpriteSheet;		protected var _sprite3DBatch:Sprite3DBatch;				//protected var _texture:Texture;				[Embed(source="mario.png")]		protected const TextureBitmap:Class;		protected var _textureBitmap:Bitmap;				//const		public const NAME:String="view3D";		public const RETURNTYPE:String=NAME;				/** Storage for the singleton instance. */		private static const _instance:View3D = new View3D(View3DLock);				public function View3D(lock:Class){			// Verify that the lock is the correct class reference.			if (lock != View3DLock)			{				throw new Error("Invalid View3D access.  Use View3D.instance instead.");			} else {				//init();			}		}		//*****Initialization Routines				public function init():void{			debug("init()");						initVars();			initEvents();			initObjs();						if(stage){				debug("stage");				addEventListener(Event.CONTEXT3D_CREATE, onContext3D, false, 0, true);			} else {				debug("!stage");				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage,false,0,true);			}		}				protected function initVars():void{						//vertex vertices			_gvStart=0;			_gvCount=4;			_gvSize=3;			_vertexVertices=Vector.<Number>([				-.3,-.3,  0, // x, y, z				-.3, .3,  0,				 .3, .3,  0,				 .3,-.3,  0			]);						//indices			_startIndex=0;			_numIndices=6;			_indices=Vector.<uint>([0, 1, 2, 0, 2, 3]);						//shader opcode			_vertexShaderCode=//				"m44 op, va0, vc0\n" + // pos to clipspace//				"mov v0, va1.xy\n" + // copy uv//				"mov v0.z, va0.z";				"dp4 op.x, va0, vc0 \n"+ // transform from stream 0 to output clipspace				"dp4 op.y, va0, vc1 \n"+ // do the same for the y coordinate				"mov op.z, vc2.z    \n"+ // we don't need to change the z coordinate				"mov op.w, vc3.w    \n"+ // unused, but we need to output all data				"mov v0, va1.xy     \n"+ // copy UV coords from stream 1 to fragment program				"mov v0.z, va0.z    \n"  // copy alpha from stream 0 to fragment program						//fragment opcode			_fragmentShaderCode=				"tex ft0, v0, fs0 <2d,clamp,linear,mipnearest>\n" +				"mul ft0, ft0, v0.zzzz\n" + // multiply by the alpha transparency				"mov oc, ft0";						//perspective			_aspect=4/3;			_zNear=.1;			_zFar=1000;			_fov=45*Math.PI/180;						//bitmap			_textureBitmap=new TextureBitmap();		}				protected function initEvents():void{			appData.eventManager.listen(NAME, onView3D);			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);		}				protected function initObjs():void{			_vertexShader=new AGALMiniAssembler(false);			_vertexShader.assemble(Context3DProgramType.VERTEX,_vertexShaderCode);			if(_vertexShader.error){				debug("_vertexShader.error=="+_vertexShader.error);			}						_fragmentShader=new AGALMiniAssembler(false);			_fragmentShader.assemble(Context3DProgramType.FRAGMENT,_fragmentShaderCode);			if(_fragmentShader.error){				debug("_fragmentShader.error=="+_fragmentShader.error);			}						_projectionTransform=new PerspectiveMatrix3D();			_projectionTransform.perspectiveFieldOfViewLH(_fov,_aspect,_zNear,_zFar);								}				protected function init3D():void{			debug("init3D()");						_context3D=stage.stage3Ds[0].context3D;			configureBackBuffer();						_spriteSheet=new SpriteSheet(_textureBitmap.bitmapData, 8, 8, _context3D);			_sprite3DBatch=new Sprite3DBatch(_spriteSheet);						_vertexBuffer=_context3D.createVertexBuffer(_sprite3DBatch.vertexCount, _sprite3DBatch.vertexSize);			_vertexBuffer.uploadFromVector(_sprite3DBatch.vertices,_sprite3DBatch.vertexStart,_sprite3DBatch.vertexCount);						_uvBuffer=_context3D.createVertexBuffer(_sprite3DBatch.uvCount, _sprite3DBatch.uvSize);			_uvBuffer.uploadFromVector(_sprite3DBatch.uvs, _sprite3DBatch.uvStart, _sprite3DBatch.uvCount);						_indexBuffer=_context3D.createIndexBuffer(_sprite3DBatch.indexCount);			_indexBuffer.uploadFromVector(_sprite3DBatch.indices,_startIndex,_sprite3DBatch.indexCount);						_program3D=_context3D.createProgram();			_program3D.upload(_vertexShader.agalcode,_fragmentShader.agalcode);					}						//*****Core Functionality				protected function configureBackBuffer(width:int=800,height:int=600):void{			_context3D.configureBackBuffer(width,height,0,false);		}		//*****Event Handlers				protected function onEnterFrame(e:Event):void{			//debug("onEnterFrame()");			if(!_context3D){				return;			}						_rotationMatrix=new Matrix3D();			//_rotationMatrix.appendRotation(getTimer()/10, Vector3D.Y_AXIS);//			_rotationMatrix.appendRotation(getTimer()/40, Vector3D.X_AXIS);//			_rotationMatrix.appendRotation(getTimer()/40, Vector3D.Z_AXIS);			_rotationMatrix.appendTranslation(0,0,12);			_rotationMatrix.append(_projectionTransform);						_context3D.clear(.5,.5,.5,1);						_sprite3DBatch.updateAllUVs();			_sprite3DBatch.updateAllVertices();						_uvBuffer=_context3D.createVertexBuffer(_sprite3DBatch.uvCount, _sprite3DBatch.uvSize);			_uvBuffer.uploadFromVector(_sprite3DBatch.uvs, _sprite3DBatch.uvStart, _sprite3DBatch.uvCount);						_vertexBuffer=_context3D.createVertexBuffer(_sprite3DBatch.vertexCount, _sprite3DBatch.vertexSize);			_vertexBuffer.uploadFromVector(_sprite3DBatch.vertices,_sprite3DBatch.vertexStart,_sprite3DBatch.vertexCount);						_context3D.setProgram(_program3D);			_context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,_rotationMatrix,true);			_context3D.setTextureAt(0,_spriteSheet.texture);						_context3D.setVertexBufferAt(0,_vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);			_context3D.setVertexBufferAt(1,_uvBuffer,0,Context3DVertexBufferFormat.FLOAT_2);						_context3D.drawTriangles(_indexBuffer);			_context3D.present();			//			_spCount++;//			if(_spCount>=_spList.length){//				_spCount=0;//			} 		}				protected function onAddedToStage(e:Event):void{			debug("onAddedToStage()");			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3D, false, 0, true);			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);		}				protected function onContext3D(e:Event):void{			debug("onContext3D()");			stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onContext3D);			debug("stage.stage3Ds[0].context3D.driverInfo=="+stage.stage3Ds[0].context3D.driverInfo);			init3D();		}				protected function onView3D(e:MuleEvent):void{			/*debug("onView3D()");			debug("e.data.sender=="+e.data.sender);			debug("e.data.type=="+e.data.type);*/			switch(e.data.type){								default:					debug("onView3D()");					debug("*type not found");					debug("e.data.sender=="+e.data.sender);					debug("e.data.type=="+e.data.type);					break;							}		}				//*****Gets and Sets				public static function get instance():View3D{return _instance;}		//*****Utility Functions				//**visibility		public function show():void{			this.visible = true;		}				public function hide():void{			this.visible = false;		}				//**debug		protected function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end packageclass View3DLock{}