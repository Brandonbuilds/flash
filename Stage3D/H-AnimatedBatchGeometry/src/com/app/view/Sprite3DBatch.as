// com.adam.utils.Sprite3DBatch// Adam Riggs//package com.app.view{	import com.adam.events.MuleEvent;	import com.adam.utils.AppData;	import com.greensock.TweenLite;		import flash.display.Sprite;	import flash.events.*;	import flash.geom.Point;
		public class Sprite3DBatch {				//vars		protected var _spriteCount:uint;		protected var _vpWidth:uint;		protected var _vpHeight:uint;				protected var _vertexStart:uint;		protected var _vertexCount:uint;		protected var _vertexSize:uint;				protected var _uvStart:uint;		protected var _uvCount:uint;		protected var _uvSize:uint;				protected var _indexStart:uint;		protected var _indexCount:uint;				//objects		private var appData:AppData=AppData.instance;		protected var _spriteSheet:SpriteSheet;		protected var _vertices:Vector.<Number>;		protected var _indices:Vector.<uint>;		protected var _uvs:Vector.<Number>;		protected var _sprites:Vector.<Sprite3D>;				//const		public const NAME:String="sprite3DBatch";		public const RETURNTYPE:String=NAME;				public function Sprite3DBatch(ss:SpriteSheet){			_spriteSheet=ss;			init();		}		//*****Initialization Routines				public function init():void{			debug("init()");						initVars();			initEvents();			initObjs();		}				private function initVars():void{			_spriteCount=5000;						_vpWidth=10;			_vpHeight=10;						_vertexStart=0;			_vertexSize=3;			_vertexCount=(_spriteCount*12)/_vertexSize;						_uvStart=0;			_uvSize=2;			_uvCount=(_spriteCount*8)/_uvSize;						_indexStart=0;			_indexCount=_spriteCount*6;		}				private function initEvents():void{			appData.eventManager.listen(NAME, onSprite3DBatch);		}				private function initObjs():void{			_sprites=new Vector.<Sprite3D>;			_vertices=new Vector.<Number>;			_indices=new Vector.<uint>;			_uvs=new Vector.<Number>;						 var i:uint;			 var sp:Sprite3D;			 			 for(i=0;i<_spriteCount;i++){				 sp=new Sprite3D();				 addSprite(sp);				 updateVertexData(sp);			 }		}		//*****Core Functionality				protected function addSprite(sp:Sprite3D):void{			//debug("addSprite()");						sp.id=_sprites.length;			_sprites.push(sp);			sp.texCount=_spriteSheet.texCount;			sp.texSize=_spriteSheet.texSize;						sp.pos=new Point((Math.random()*_vpWidth)-(_vpWidth/2), (Math.random()*_vpHeight)-(_vpHeight/2));			//sp.pos=new Point(100, (Math.random()*_vpHeight)-(_vpHeight/2));			sp.tex=_spriteSheet.getRandomAnimation();			//			sp.speedX=(Math.random()*10)-2;//			sp.speedY=(Math.random()*5)-2.5;//			sp.rotation=15-(Math.random()*30);						_vertices.push(0,0,1,0,0,1,0,0,1,0,0,1);  //placeholders						var spVertexIndex:uint=(sp.id*12)/3;			_indices.push(spVertexIndex,spVertexIndex+1,spVertexIndex+2,spVertexIndex,spVertexIndex+2,spVertexIndex+3);						var uv:Vector.<Number>=new Vector.<Number>();			uv=sp.nextTex;			_uvs.push(uv[0],uv[1],uv[2],uv[3],uv[4],uv[5],uv[6],uv[7]);		}				public function updateAllUVs():void{			for(var i:uint=0;i<_sprites.length;i++){				updateUVData(_sprites[i]);			}		}				protected function updateUVData(sp:Sprite3D):void{			var spUVStart:uint=sp.id*8;	//texCount*texSize			var tex:Vector.<Number>=new Vector.<Number>;			tex=sp.nextTex;						_uvs[spUVStart]   =tex[0];			_uvs[spUVStart+1] =tex[1];			_uvs[spUVStart+2] =tex[2];			_uvs[spUVStart+3] =tex[3];			_uvs[spUVStart+4] =tex[4];			_uvs[spUVStart+5] =tex[5];			_uvs[spUVStart+6] =tex[6];			_uvs[spUVStart+7] =tex[7];					}				public function updateAllVertices():void{			for(var i:uint=0;i<_sprites.length;i++){				updateVertexData(_sprites[i]);			}		}				protected function updateVertexData(sp:Sprite3D):void{			//debug("updateVertexData()");			var spVertexStart:uint=sp.id*12;			//			sp.pos.x+=sp.speedX;//			sp.pos.y+=sp.speedY;						var spW:uint=1;			var spH:uint=1;			var spX:Number=sp.pos.x;			var spY:Number=sp.pos.y;//			var spDX:Number=sp.speedX;//			var spDY:Number=sp.speedY;			var alpha:Number=sp.alpha;						_vertices[spVertexStart]   =spX-(spW/2);			_vertices[spVertexStart+1] =spY-(spH/2);			_vertices[spVertexStart+2] =alpha;						_vertices[spVertexStart+3] =spX-(spW/2);			_vertices[spVertexStart+4] =spY+(spH/2);			_vertices[spVertexStart+5] =alpha;						_vertices[spVertexStart+6] =spX+(spW/2);			_vertices[spVertexStart+7] =spY+(spH/2);			_vertices[spVertexStart+8] =alpha;						_vertices[spVertexStart+9] =spX+(spW/2);			_vertices[spVertexStart+10]=spY-(spH/2);			_vertices[spVertexStart+11]=alpha;					}				//*****Event Handlers				private function onSprite3DBatch(e:MuleEvent):void{			/*debug("onSprite3DBatch()");			debug("e.data.sender=="+e.data.sender);			debug("e.data.type=="+e.data.type);*/			switch(e.data.type){																default:					debug("onSprite3DBatch()");					debug("*type not found");					debug("e.data.sender=="+e.data.sender);					debug("e.data.type=="+e.data.type);				break;							}		}				//*****Gets and Sets				public function get vertices():Vector.<Number>{return _vertices;}		public function get indices():Vector.<uint>{return _indices;}		public function get uvs():Vector.<Number>{return _uvs;}				public function get indexStart():uint{return _indexStart;}		public function get indexCount():uint{return _indexCount;}		public function get vertexStart():uint{return _vertexStart;}		public function get vertexCount():uint{return _vertexCount;}		public function get vertexSize():uint{return _vertexSize;}				public function get uvStart():uint{return _uvStart;}		public function get uvCount():uint{return _uvCount;}		public function get uvSize():uint{return _uvSize;}				//*****Utility Functions				//**debug		private function debug(str:String):void{			appData.debug(NAME,str);		}				}//end class}//end package