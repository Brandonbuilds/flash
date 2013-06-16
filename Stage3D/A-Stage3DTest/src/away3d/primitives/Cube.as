﻿package away3d.primitives
{
        import away3d.arcane;
        import away3d.core.base.*;
        import away3d.core.utils.*;
        import away3d.events.*;
        import away3d.materials.*;
        import away3d.primitives.data.*;

        use namespace arcane;

    /**
    * Creates a 3d Cube primitive.
    */
    public class Cube extends AbstractPrimitive
    {
        private var _width:Number;
        private var _height:Number;
        private var _depth:Number;
                private var _segmentsW:int;
        private var _segmentsH:int;
                private var _segmentsD:int;
                private var _flip:Boolean;
        private var _cubeMaterials:CubeMaterialsData;
        private var _leftFaces:Array;
        private var _rightFaces:Array;
        private var _bottomFaces:Array;
        private var _topFaces:Array;
        private var _frontFaces:Array;
        private var _backFaces:Array;
        private var _cubeFaceArray:Array;
                private var _mappingType:String;
                private var _dbv:Array;
                private var _dbu:Array;

                private var _pixelBorder:int = 0;
                private var _varr:Array = [];
                private var _uvarr:Array = [];

        private function onCubeMaterialChange(event:MaterialEvent):void
        {
                switch (event.extra) {
                        case "left":
                                _cubeFaceArray = _leftFaces;
                                break;
                        case "right":
                                _cubeFaceArray = _rightFaces;
                                break;
                        case "bottom":
                                _cubeFaceArray = _bottomFaces;
                                break;
                        case "top":
                                _cubeFaceArray = _topFaces;
                                break;
                        case "front":
                                _cubeFaceArray = _frontFaces;
                                break;
                        case "back":
                                _cubeFaceArray = _backFaces;
                }
                for each (var _cubeFace:Face in _cubeFaceArray)
                        _cubeFace.material = event.material as Material;
        }

                private function makeVertex(x:Number, y:Number, z:Number):Vertex
                {
                        for(var i:int = 0;i<_dbv.length; ++i)
                                if( _dbv[i].x == x && _dbv[i].y == y && _dbv[i].z == z)
                                        return _dbv[i];

                        var v:Vertex = createVertex(x, y, z);
                        _dbv[_dbv.length] = v;

                        return v;
                }

                private function makeUV(u:Number, v:Number):UV
                {
                        for(var i:int = 0;i<_dbu.length; ++i)
                                if( _dbu[i].u == u && _dbu[i].v == v)
                                        return _dbu[i];

                        var uv:UV = createUV(u,v);
                        _dbu[_dbu.length] = uv;

                        return uv;
                }

                private function buildFaces(a:int, b:int, c:int, d:int,
mat:Material, back:Boolean, cubeFace:String):void {
                        var uva:UV = _uvarr[a];
                        var uvb:UV = _uvarr[b];
                        var uvc:UV = _uvarr[c];
                        var uvd:UV = _uvarr[d];

                        var va:Vertex = _varr[a];
                        var vb:Vertex = _varr[b];
                        var vc:Vertex = _varr[c];
                        var vd:Vertex = _varr[d];

                        var faces:Array = [];

                        if(_flip || back) {
                                faces.push(createFace(va,vb,vc, mat, uva, uvb, uvc ));
                                faces.push(createFace(va,vc,vd, mat, uva, uvc, uvd));
                        } else {
                                faces.push(createFace(vb,va,vc, mat, uvb, uva, uvc ));
                                faces.push(createFace(vc,va,vd, mat, uvc, uva, uvd));
                        }
                        for each (var face:Face in faces) {
                switch (cubeFace) {
                    case "left":
                        _leftFaces.push(face);
                        break;
                    case "right":
                        _rightFaces.push(face);
                        break;
                    case "bottom":
                        _bottomFaces.push(face);
                        break;
                    case "top":
                        _topFaces.push(face);
                        break;
                    case "front":
                        _frontFaces.push(face);
                        break;
                    case "back":
                        _backFaces.push(face);
                }
                addFace(face);
            }

                }

                /**
                 * @inheritDoc
                 */
        protected override function buildPrimitive():void
        {
                        super.buildPrimitive();

                        _leftFaces = [];
                        _rightFaces = [];
                        _bottomFaces = [];
                        _topFaces = [];
                        _frontFaces = [];
                        _backFaces = [];

                        var i:int;
                        var j:int;

                        var udelta:Number = _pixelBorder/600;
                        var vdelta:Number = _pixelBorder/400;

                        var a:int;
                        var b:int;
                        var c:int;
                        var d:int;
                        var inc:int = 0;

                        _dbv = [];
                        _dbu = [];
                        _varr = [];
                        _uvarr = [];

                        if (material is BitmapMaterial) {
                                var bMaterial:BitmapMaterial = material as BitmapMaterial;
                                udelta = _pixelBorder/bMaterial.width;
                                vdelta = _pixelBorder/bMaterial.height;
                        }

                        for (i = 0; i <= _segmentsW; i++) {
                                for (j = 0; j <= _segmentsH; j++) {

                                        //create front/back
                                        _varr.push( makeVertex(_width/2 - i*_width/_segmentsW, _height/2
- j*_height/_segmentsH, -_depth/2) );
                                        _varr.push( makeVertex(_width/2 - i*_width/_segmentsW, _height/2
- j*_height/_segmentsH, _depth/2) );
                                        if (_mappingType == CubeMappingType.NORMAL) {
                                                _uvarr.push( makeUV(1 - i/_segmentsW, 1 - j/_segmentsH));
                                                _uvarr.push( makeUV(i/_segmentsW, 1 - j/_segmentsH));
                                        } else {
                                                _uvarr.push( makeUV(2/3 - udelta - i*(1 - 6*udelta)/
(3*_segmentsW), 1 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH)) );
                                                _uvarr.push( makeUV(udelta + i*(1 - 6*udelta)/(3*_segmentsW),
1/2 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH)) );
                                        }

                                        if (i && j) {
                                                a = 2*((_segmentsH+1)*i + j);
                                                b = 2*((_segmentsH+1)*i + j - 1);
                                                c = 2*((_segmentsH+1)*(i - 1) + j - 1);
                                                d = 2*((_segmentsH+1)*(i - 1) + j);

                                                buildFaces(a, b, c, d, _cubeMaterials.front, false, "front");
                                                buildFaces(a+1, b+1, c+1, d+1, _cubeMaterials.back, true,
"back");
                                        }
                                }
                        }

                        inc += 2*(_segmentsW + 1)*(_segmentsH + 1);

                        for (i = 0; i <= _segmentsW; i++) {
                                for (j = 0; j <= _segmentsD; j++) {

                                        //create top/bottom
                                        _varr.push( makeVertex(_width/2 - i*_width/_segmentsW, -_height/
2, -_depth/2 + j*_depth/_segmentsD) );
                                        _varr.push( makeVertex(_width/2 - i*_width/_segmentsW, _height/2,
-_depth/2 + j*_depth/_segmentsD) );

                                        if (_mappingType == CubeMappingType.NORMAL) {
                                                _uvarr.push( makeUV(j/_segmentsW, 1 - i/_segmentsD));
                                                _uvarr.push( makeUV(j/_segmentsW, i/_segmentsD));
                                        } else {
                                                _uvarr.push( makeUV(1 - udelta - j*(1 - 6*udelta)/
(3*_segmentsW), vdelta + i*(1 - 4*vdelta)/(2*_segmentsD)) );
                                                _uvarr.push( makeUV(2/3 - udelta - j*(1 - 6*udelta)/
(3*_segmentsW), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD)) );
                                        }

                                        if (i && j) {
                                                a = inc + 2*((_segmentsD + 1)*i + j);
                                                b = inc + 2*((_segmentsD + 1)*i + j - 1);
                                                c = inc + 2*((_segmentsD + 1)*(i - 1) + j - 1);
                                                d = inc + 2*((_segmentsD + 1)*(i - 1) + j);

                                                buildFaces(a, b, c, d, _cubeMaterials.top, false, "top");
                                                buildFaces(a+1, b+1, c+1, d+1, _cubeMaterials.bottom, true,
"bottom");
                                        }
                                }
                        }

                        inc += 2*(_segmentsW + 1)*(_segmentsD + 1);

                        for (i = 0; i <= _segmentsH; i++) {
                                for (j = 0; j <= _segmentsD; j++) {

                                        //create left/right
                                        _varr.push( makeVertex(_width/2, _height/2 - i*_height/
_segmentsH, -_depth/2 + j*_depth/_segmentsD) );
                                        _varr.push( makeVertex(-_width/2, _height/2 - i*_height/
_segmentsH, -_depth/2 + j*_depth/_segmentsD) );

                                        if (_mappingType == CubeMappingType.NORMAL) {
                                                _uvarr.push( makeUV(j/_segmentsH, 1 - i/_segmentsD));
                                                _uvarr.push( makeUV(1 - j/_segmentsH, 1 - i/_segmentsD));
                                        } else {
                                                _uvarr.push( makeUV(2/3 + udelta + j*(1 - 6*udelta)/
(3*_segmentsH), 1 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD)) );
                                                _uvarr.push( makeUV(1/3 - udelta - j*(1 - 6*udelta)/
(3*_segmentsH), 1 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD)) );
                                        }

                                        if (i && j) {
                                                a = inc + 2*((_segmentsD + 1)*i + j);
                                                b = inc + 2*((_segmentsD + 1)*i + j - 1);
                                                c = inc + 2*((_segmentsD + 1)*(i - 1) + j - 1);
                                                d = inc + 2*((_segmentsD + 1)*(i - 1) + j);

                                                buildFaces(a, b, c, d, _cubeMaterials.left, false, "left");
                                                buildFaces(a+1, b+1, c+1, d+1, _cubeMaterials.right, true,
"right");
                                        }
                                }
                        }
        }

        /**
         * Defines the width of the cube. Defaults to 100.
         */
        public function get width():Number
        {
                return _width;
        }

        public function set width(val:Number):void
        {
                if (_width == val)
                        return;

                _width = val;
                _primitiveDirty = true;
        }

        /**
         * Defines the height of the cube. Defaults to 100.
         */
        public function get height():Number
        {
                return _height;
        }

        public function set height(val:Number):void
        {
                if (_height == val)
                        return;

                _height = val;
                _primitiveDirty = true;
        }

        /**
         * Defines the depth of the cube. Defaults to 100.
         */
        public function get depth():Number
        {
                return _depth;
        }

        public function set depth(val:Number):void
        {
                if (_depth == val)
                        return;

                _depth = val;
                _primitiveDirty = true;
        }

                /**
         * Defines the number of horizontal segments that make up the
cube. Defaults 1.
         */
        public function get segmentsW():Number
        {
                return _segmentsW;
        }

        public function set segmentsW(val:Number):void
        {
                if (_segmentsW == val)
                        return;

                _segmentsW = val;
                _primitiveDirty = true;
        }

                /**
         * Defines if the cube should use a single (3 cols/2 rows) map
spreaded over the whole cube.
                 * topleft: left, topcenter:front, topright:right
                 * downleft:back, downcenter:top, downright: bottom
                 * Default is false.
         */
        public function get mappingType():String
        {
                return _mappingType;
        }

        public function set mappingType(val:String):void
        {
                if (_mappingType == val)
                        return;

                _mappingType = val;
                _primitiveDirty = true;
        }

                /**
         * Defines if the cube faces should be reversed, like a skybox.
Default is false.
         */
        public function get flip():Boolean
        {
                return _flip;
        }

        public function set flip(b:Boolean):void
        {
                _flip = b;
        }

        /**
         * Defines the number of vertical segments that make up the cube.
Defaults 1.
         */
        public function get segmentsH():Number
        {
                return _segmentsH;
        }

        public function set segmentsH(val:Number):void
        {
                if (_segmentsH == val)
                        return;

                _segmentsH = val;
                _primitiveDirty = true;
        }

                /**
                 * Defines the number of vertical segments that make up the cube.
Defaults 1.
                 */
                public function get segmentsD():Number
                {
                        return _segmentsD;
                }

                public function set segmentsD(val:Number):void
                {
                        if (_segmentsD == val)
                                return;

                        _segmentsD = val;
                        _primitiveDirty = true;
                }

                /**
         * Defines the face materials of the cube.
         */
        public function get cubeMaterials():CubeMaterialsData
        {
                return _cubeMaterials;
        }

        public function set cubeMaterials(val:CubeMaterialsData):void
        {
                if (_cubeMaterials == val)
                        return;

                if (_cubeMaterials)
                        _cubeMaterials.addOnMaterialChange(onCubeMaterialChange);

                _cubeMaterials = val;

                _cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
        }
                /**
                 * Creates a new <code>Cube</code> object.
                 *
                 * @param       init                    [optional]      An initialisation object for specifying
default instance properties.
                 * Properties of the init object: width, height, depth, segmentsH,
segmentsW, flip, map6, material or faces (as CubeMaterialsData)
                 */
        public function Cube(init:Object = null)
        {
            super(init);
            _width  = ini.getNumber("width",  100, {min:0});
            _height = ini.getNumber("height", 100, {min:0});
            _depth  = ini.getNumber("depth",  100, {min:0});
                        _flip = ini.getBoolean("flip", false);
            _cubeMaterials  = ini.getCubeMaterials("faces");
                        _segmentsW = ini.getInt("segmentsW", 1, {min:1});
            _segmentsH = ini.getInt("segmentsH", 1, {min:1});
                        _segmentsD = ini.getInt("segmentsD", 1, {min:1});
                        _mappingType = ini.getString("mappingType",
CubeMappingType.NORMAL);

                        if (!_cubeMaterials)
                                _cubeMaterials  = ini.getCubeMaterials("cubeMaterials");

                        if (!_cubeMaterials)
                                _cubeMaterials = new CubeMaterialsData();

                        _cubeMaterials.addOnMaterialChange(onCubeMaterialChange);

                        type = "Cube";
                        url = "primitive";
        }
    }
} 