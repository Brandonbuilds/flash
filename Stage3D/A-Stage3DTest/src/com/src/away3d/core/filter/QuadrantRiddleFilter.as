﻿package away3d.core.filter
{
	import away3d.arcane;
	import away3d.cameras.lenses.*;
	import away3d.core.base.*;
	import away3d.core.project.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	
	import flash.utils.*;

	use namespace arcane;
	
    /**
    * Splits all intersecting triangles and line segments.
    */
    public class QuadrantRiddleFilter implements IPrimitiveQuadrantFilter
    {
        private var maxdelay:int;
        
        private var renderer:QuadrantRenderer;
    	private var start:int;
        private var check:int;
        private var primitives:Vector.<uint>;
        private var turn:int;
        private var rivals:Vector.<uint>;
        private var parts:Array;
        private var lens:AbstractLens;
        private var positiveArea:Number;
        
        private var av0z:Number;
        private var av0p:Number;
        private var av0x:Number;
        private var av0y:Number;

        private var av1z:Number;
        private var av1p:Number;
        private var av1x:Number;
        private var av1y:Number;

        private var av2z:Number;
        private var av2p:Number;
        private var av2x:Number;
        private var av2y:Number;

        private var ad1x:Number;
        private var ad1y:Number;
        private var ad1z:Number;

        private var ad2x:Number;
        private var ad2y:Number;
        private var ad2z:Number;

        private var apa:Number;
        private var apb:Number;
        private var apc:Number;
        private var apd:Number;
        
        private var tv0z:Number;
        private var tv0p:Number;
        private var tv0x:Number;
        private var tv0y:Number;

        private var tv1z:Number;
        private var tv1p:Number;
        private var tv1x:Number;
        private var tv1y:Number;

        private var tv2z:Number;
        private var tv2p:Number;
        private var tv2x:Number;
        private var tv2y:Number;

        private var sv0:Number;
        private var sv1:Number;
        private var sv2:Number;
        
        private var td1x:Number;
        private var td1y:Number;
        private var td1z:Number;

        private var td2x:Number;
        private var td2y:Number;
        private var td2z:Number;

        private var tpa:Number;
        private var tpb:Number;
        private var tpc:Number;
        private var tpd:Number;
        
        private var sav0:Number;
        private var sav1:Number;
        private var sav2:Number;
        
        private var q0x:Number;
        private var q0y:Number;
        private var q1x:Number;
        private var q1y:Number;
        private var q2x:Number;
        private var q2y:Number;
        
        private var w0x:Number;
        private var w0y:Number;
        private var w1x:Number;
        private var w1y:Number;
        private var w2x:Number;
        private var w2y:Number;
        
        private var ql01a:Number;
        private var ql01b:Number;
        private var ql01c:Number;
        private var ql01s:Number;
        private var ql01w0:Number;
        private var ql01w1:Number;
        private var ql01w2:Number;
        
        private var ql12a:Number;
        private var ql12b:Number;
        private var ql12c:Number;
        private var ql12s:Number;
        private var ql12w0:Number;
        private var ql12w1:Number;
        private var ql12w2:Number;
        
        private var ql20a:Number;
        private var ql20b:Number;
        private var ql20c:Number;
        private var ql20s:Number;
        private var ql20w0:Number;
        private var ql20w1:Number;
        private var ql20w2:Number;
		
        private var wl01a:Number;
        private var wl01b:Number;
        private var wl01c:Number;
        private var wl01s:Number;
        private var wl01q0:Number;
        private var wl01q1:Number;
        private var wl01q2:Number;
		
        private var wl12a:Number;
        private var wl12b:Number;
        private var wl12c:Number;
        private var wl12s:Number;
        private var wl12q0:Number;
        private var wl12q1:Number;
        private var wl12q2:Number;
		
        private var wl20a:Number;
        private var wl20b:Number;
        private var wl20c:Number;
        private var wl20s:Number;
        private var wl20q0:Number;
        private var wl20q1:Number;
        private var wl20q2:Number;
        
        private var d:Number;
        private var k0:Number;
        private var k1:Number;
		private var k2:Number;
		
        private var tv01z:Number;
        private var tv01p:Number;
        private var tv01x:Number;
        private var tv01y:Number;
        
        private var tv12z:Number;
        private var tv12p:Number;
        private var tv12x:Number;
        private var tv12y:Number;
        
        private var tv20z:Number;
        private var tv20p:Number;
        private var tv20x:Number;
        private var tv20y:Number;
        
        private var _viewSourceObjectQ:ViewSourceObject;
        private var _viewSourceObjectW:ViewSourceObject;
        private var _index:uint;
        private var _startIndexQ:uint;
        private var _startIndexW:uint;
        private var _uvs:Vector.<UV>;
        
    	private function riddle(q:uint, w:uint):Array
        {
            if (renderer.primitiveType[q] == PrimitiveType.FACE) { 
                if (renderer.primitiveType[w] == PrimitiveType.FACE)
                    return riddleTT(q, w);
                if (renderer.primitiveType[w] == PrimitiveType.SEGMENT)
                    return riddleTS(q, w);
            }
            else
            if (renderer.primitiveType[q] == PrimitiveType.SEGMENT) {
                if (renderer.primitiveType[w] == PrimitiveType.FACE)
                    return riddleTS(w, q);
            }
            return [];
        }
        
        private final function riddleTT(q:uint, w:uint):Array
        {
        	positiveArea = renderer.primitiveProperties[uint(q*9 + 8)];
        	
        	if (positiveArea < 0)
        		positiveArea = -positiveArea;
        	
			_viewSourceObjectW = renderer.primitiveSource[w];
			_startIndexW = renderer.primitiveProperties[uint(w*9)];
			_viewSourceObjectQ = renderer.primitiveSource[q];
        	_startIndexQ = renderer.primitiveProperties[uint(q*9)];
        	
        	//return if triangle area below 10 or if actual rival triangles do not overlap
            if (positiveArea < 10 || positiveArea < 10 || !overlap())
                return null;
			
			
			//deperspective rival v0 
			_index = _viewSourceObjectW.screenIndices[_startIndexW];
            av0z = lens.getScreenZ(_viewSourceObjectW.screenUVTs[uint(_index*3 + 2)]);
            av0p = lens.getPerspective(av0z);
            av0x = _viewSourceObjectW.screenVertices[uint(_index*2)] / av0p;
            av0y = _viewSourceObjectW.screenVertices[uint(_index*2 + 1)] / av0p;
			
			//deperspective rival v1
			_index = _viewSourceObjectW.screenIndices[uint(_startIndexW + 1)];
            av1z = lens.getScreenZ(_viewSourceObjectW.screenUVTs[uint(_index*3 + 2)]);
            av1p = lens.getPerspective(av1z);
            av1x = _viewSourceObjectW.screenVertices[uint(_index*2)] / av1p;
            av1y = _viewSourceObjectW.screenVertices[uint(_index*2 + 1)] / av1p;
			
			//deperspective rival v2
			_index = _viewSourceObjectW.screenIndices[uint(_startIndexW + 2)];
            av2z = lens.getScreenZ(_viewSourceObjectW.screenUVTs[uint(_index*3 + 2)]);
            av2p = lens.getPerspective(av2z);
            av2x = _viewSourceObjectW.screenVertices[uint(_index*2)] / av2p;
            av2y = _viewSourceObjectW.screenVertices[uint(_index*2 + 1)] / av2p;
			
			//calculate rival face normal
            ad1x = av1x - av0x;
            ad1y = av1y - av0y;
            ad1z = av1z - av0z;

            ad2x = av2x - av0x;
            ad2y = av2y - av0y;
            ad2z = av2z - av0z;

            apa = ad1y*ad2z - ad1z*ad2y;
            apb = ad1z*ad2x - ad1x*ad2z;
            apc = ad1x*ad2y - ad1y*ad2x;
            
            //calculate the dot product of the rival normal and rival v0
            apd = apa*av0x + apb*av0y + apc*av0z;
			
			//return if normal length is less than 1
            if (apa*apa + apb*apb + apc*apc < 1)
                return null;
			
			//deperspective v0
			_index = _viewSourceObjectQ.screenIndices[_startIndexQ];
            tv0z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            tv0p = lens.getPerspective(tv0z);
            tv0x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / tv0p;
            tv0y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / tv0p;

			//deperspective v1
			_index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 1)];
            tv1z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            tv1p = lens.getPerspective(tv1z);
            tv1x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / tv1p;
            tv1y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / tv1p;
			
			//deperspective v2
			_index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 2)];
            tv2z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            tv2p = lens.getPerspective(tv2z);
            tv2x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / tv2p;
            tv2y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / tv2p;
            
            //calculate the dot product of v0, v1 and v2 to the rival normal
            sv0 = apa*tv0x + apb*tv0y + apc*tv0z - apd;
            sv1 = apa*tv1x + apb*tv1y + apc*tv1z - apd;
            sv2 = apa*tv2x + apb*tv2y + apc*tv2z - apd;

            if (sv0*sv0 < 0.001)
                sv0 = 0;
            if (sv1*sv1 < 0.001)
                sv1 = 0;
            if (sv2*sv2 < 0.001)
                sv2 = 0;

            if (sv0*sv1 >= -0.01 && sv1*sv2 >= -0.01 && sv2*sv0 >= -0.01)
                return null;
			
			//calulate face normal
            td1x = tv1x - tv0x;
            td1y = tv1y - tv0y;
            td1z = tv1z - tv0z;

            td2x = tv2x - tv0x;
            td2y = tv2y - tv0y;
            td2z = tv2z - tv0z;

            tpa = td1y*td2z - td1z*td2y;
            tpb = td1z*td2x - td1x*td2z;
            tpc = td1x*td2y - td1y*td2x;
            
            //calculate the dot product of the face normal and v0
            tpd = tpa*tv0x + tpb*tv0y + tpc*tv0z;
			
			//return if normal length is less than 1
            if (tpa*tpa + tpb*tpb + tpc*tpc < 1)
                return null;
			
			//calculate the dot product of rival v0, v1 and v2 to the face normal
            sav0 = tpa*av0x + tpb*av0y + tpc*av0z - tpd;
            sav1 = tpa*av1x + tpb*av1y + tpc*av1z - tpd;
            sav2 = tpa*av2x + tpb*av2y + tpc*av2z - tpd;

            if (sav0*sav0 < 0.001)
                sav0 = 0;
            if (sav1*sav1 < 0.001)
                sav1 = 0;
            if (sav2*sav2 < 0.001)
                sav2 = 0;

            if ((sav0*sav1 >= -0.01) && (sav1*sav2 >= -0.01) && (sav2*sav0 >= -0.01))
                return null;

            // TODO: segment cross check - now some extra cuts are made
			d = sv0 - sv1;
            k1 = sv0 / d;
            k0 = -sv1 / d;

            tv01z = (tv1z*k1 + tv0z*k0);
            tv01p = lens.getPerspective(tv01z);
            tv01x = (tv1x*k1 + tv0x*k0) * tv01p;
            tv01y = (tv1y*k1 + tv0y*k0) * tv01p;
            
            d = sv1 - sv2;
            k2 = sv1 / d;
            k1 = -sv2 / d;

            tv12z = (tv2z*k2 + tv1z*k1);
            tv12p = lens.getPerspective(tv12z);
            tv12x = (tv2x*k2 + tv1x*k1) * tv12p;
            tv12y = (tv2y*k2 + tv1y*k1) * tv12p;
            
            d = sv2 - sv0;
            k0 = sv2 / d;
            k2 = -sv0 / d;

            tv20z = (tv0z*k0 + tv2z*k2);
            tv20p = lens.getPerspective(tv20z);
            tv20x = (tv0x*k0 + tv2x*k2) * tv20p;
            tv20y = (tv0y*k0 + tv2y*k2) * tv20p;
            
            _uvs = renderer.primitiveUVs[q];
            
			if (sv1*sv2 >= -1) {
                return renderer.primitiveSource[q].fivepointcut(q, renderer, _startIndexQ+2, tv20x, tv20y, tv20z, _startIndexQ, tv01x, tv01y, tv01z, _startIndexQ+1,
                    _uvs[uint(2)], UV.weighted(_uvs[uint(2)], _uvs[uint(0)], -sv0, sv2), _uvs[uint(0)], UV.weighted(_uvs[uint(0)], _uvs[uint(1)], sv1, -sv0), _uvs[uint(1)]);
            } else if (sv0*sv1 >= -1) {
                return renderer.primitiveSource[q].fivepointcut(q, renderer, _startIndexQ+1, tv12x, tv12y, tv12z, _startIndexQ+2, tv20x, tv20y, tv20z, _startIndexQ,
                    _uvs[uint(1)], UV.weighted(_uvs[uint(1)], _uvs[uint(2)], -sv2, sv1), _uvs[uint(2)], UV.weighted(_uvs[uint(2)], _uvs[uint(0)], sv0, -sv2), _uvs[uint(0)]);
            } else {                                                           
                return renderer.primitiveSource[q].fivepointcut(q, renderer, _startIndexQ, tv01x, tv01y, tv01z, _startIndexQ+1, tv12x, tv12y, tv12z, _startIndexQ+2,
                    _uvs[uint(0)], UV.weighted(_uvs[uint(0)], _uvs[uint(1)], -sv1, sv0), _uvs[uint(1)], UV.weighted(_uvs[uint(1)], _uvs[uint(2)], sv2, -sv1), _uvs[uint(2)]);
            }

            return null;
        }
         
        private function overlap():Boolean
        {
        	_index = _viewSourceObjectQ.screenIndices[_startIndexQ]*2;
            q0x = _viewSourceObjectQ.screenVertices[_index];
            q0y = _viewSourceObjectQ.screenVertices[uint(_index + 1)];
            _index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 1)]*2;
            q1x = _viewSourceObjectQ.screenVertices[_index];
            q1y = _viewSourceObjectQ.screenVertices[uint(_index + 1)];
            _index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 2)]*2;
            q2x = _viewSourceObjectQ.screenVertices[_index];
            q2y = _viewSourceObjectQ.screenVertices[uint(_index + 1)];
        	
        	_index = _viewSourceObjectW.screenIndices[_startIndexW]*2;
            w0x = _viewSourceObjectW.screenVertices[_index];
            w0y = _viewSourceObjectW.screenVertices[uint(_index + 1)];
            _index = _viewSourceObjectW.screenIndices[uint(_startIndexW + 1)]*2;
            w1x = _viewSourceObjectW.screenVertices[_index];
            w1y = _viewSourceObjectW.screenVertices[uint(_index + 1)];
            _index = _viewSourceObjectW.screenIndices[uint(_startIndexW + 2)]*2;
            w2x = _viewSourceObjectW.screenVertices[_index];
            w2y = _viewSourceObjectW.screenVertices[uint(_index + 1)];
        
            ql01a = q1y - q0y;
            ql01b = q0x - q1x;
            ql01c = -(ql01b*q0y + ql01a*q0x);
            ql01s = ql01a*q2x + ql01b*q2y + ql01c;
            ql01w0 = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s;
            ql01w1 = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s;
            ql01w2 = (ql01a*w2x + ql01b*w2y + ql01c) * ql01s;
        
            if ((ql01w0 <= 0.0001) && (ql01w1 <= 0.0001) && (ql01w2 <= 0.0001))
                return false;
        
            ql12a = q2y - q1y;
            ql12b = q1x - q2x;
            ql12c = -(ql12b*q1y + ql12a*q1x);
            ql12s = ql12a*q0x + ql12b*q0y + ql12c;
            ql12w0 = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s;
            ql12w1 = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s;
            ql12w2 = (ql12a*w2x + ql12b*w2y + ql12c) * ql12s;
        
            if ((ql12w0 <= 0.0001) && (ql12w1 <= 0.0001) && (ql12w2 <= 0.0001))
                return false;
        
            ql20a = q0y - q2y;
            ql20b = q2x - q0x;
            ql20c = -(ql20b*q2y + ql20a*q2x);
            ql20s = ql20a*q1x + ql20b*q1y + ql20c;
            ql20w0 = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s;
            ql20w1 = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s;
            ql20w2 = (ql20a*w2x + ql20b*w2y + ql20c) * ql20s;
        
            if ((ql20w0 <= 0.0001) && (ql20w1 <= 0.0001) && (ql20w2 <= 0.0001))
                return false;
        
            wl01a = w1y - w0y;
            wl01b = w0x - w1x;
            wl01c = -(wl01b*w0y + wl01a*w0x);
            wl01s = wl01a*w2x + wl01b*w2y + wl01c;
            wl01q0 = (wl01a*q0x + wl01b*q0y + wl01c) * wl01s;
            wl01q1 = (wl01a*q1x + wl01b*q1y + wl01c) * wl01s;
            wl01q2 = (wl01a*q2x + wl01b*q2y + wl01c) * wl01s;
        
            if ((wl01q0 <= 0.0001) && (wl01q1 <= 0.0001) && (wl01q2 <= 0.0001))
                return false;
        
            wl12a = w2y - w1y;
            wl12b = w1x - w2x;
            wl12c = -(wl12b*w1y + wl12a*w1x);
            wl12s = wl12a*w0x + wl12b*w0y + wl12c;
            wl12q0 = (wl12a*q0x + wl12b*q0y + wl12c) * wl12s;
            wl12q1 = (wl12a*q1x + wl12b*q1y + wl12c) * wl12s;
            wl12q2 = (wl12a*q2x + wl12b*q2y + wl12c) * wl12s;
        
            if ((wl12q0 <= 0.0001) && (wl12q1 <= 0.0001) && (wl12q2 <= 0.0001))
                return false;
        
            wl20a = w0y - w2y;
            wl20b = w2x - w0x;
            wl20c = -(wl20b*w2y + wl20a*w2x);
            wl20s = wl20a*w1x + wl20b*w1y + wl20c;
            wl20q0 = (wl20a*q0x + wl20b*q0y + wl20c) * wl20s;
            wl20q1 = (wl20a*q1x + wl20b*q1y + wl20c) * wl20s;
            wl20q2 = (wl20a*q2x + wl20b*q2y + wl20c) * wl20s;
        
            if ((wl20q0 <= 0.0001) && (wl20q1 <= 0.0001) && (wl20q2 <= 0.0001))
                return false;
            
            return true;
        }
        
        private function riddleTS(q:uint, w:uint):Array
        {
        	_viewSourceObjectQ = renderer.primitiveSource[q];
			_startIndexQ = renderer.primitiveProperties[uint(q*9)];
			
        	_index = _viewSourceObjectQ.screenIndices[_startIndexQ];
            av0z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            av0p = lens.getPerspective(av0z);
            av0x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / av0p;
            av0y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / av0p;
			
			_index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 1)];
            av1z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            av1p = lens.getPerspective(av1z);
            av1x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / av1p;
            av1y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / av1p;
			
			_index = _viewSourceObjectQ.screenIndices[uint(_startIndexQ + 2)];
            av2z = lens.getScreenZ(_viewSourceObjectQ.screenUVTs[uint(_index*3 + 2)]);
            av2p = lens.getPerspective(av2z);
            av2x = _viewSourceObjectQ.screenVertices[uint(_index*2)] / av2p;
            av2y = _viewSourceObjectQ.screenVertices[uint(_index*2 + 1)] / av2p;
			   
            ad1x = av1x - av0x;
            ad1y = av1y - av0y;
            ad1z = av1z - av0z;
			
            ad2x = av2x - av0x;
            ad2y = av2y - av0y;
            ad2z = av2z - av0z;
			
            apa = ad1y*ad2z - ad1z*ad2y;
            apb = ad1z*ad2x - ad1x*ad2z;
            apc = ad1x*ad2y - ad1y*ad2x;
            apd = - (apa*av0x + apb*av0y + apc*av0z);
			
            if (apa*apa + apb*apb + apc*apc < 1)
                return null;
			
			_viewSourceObjectW = renderer.primitiveSource[w];
        	_startIndexW = renderer.primitiveProperties[uint(w*9)];
        	
        	_index = _viewSourceObjectW.screenIndices[_startIndexW];
            tv0z = lens.getScreenZ(_viewSourceObjectW.screenUVTs[uint(_index*3 + 2)]);
            tv0p = lens.getPerspective(tv0z);
            tv0x = _viewSourceObjectW.screenVertices[uint(_index*2)] / tv0p;
            tv0y = _viewSourceObjectW.screenVertices[uint(_index*2 + 1)] / tv0p;
			
			_index = _viewSourceObjectW.screenIndices[uint(_startIndexW + 1)];
            tv1z = lens.getScreenZ(_viewSourceObjectW.screenUVTs[uint(_index*3 + 2)]);
            tv1p = lens.getPerspective(tv1z);
            tv1x = _viewSourceObjectW.screenVertices[uint(_index*2)] / tv1p;
            tv1y = _viewSourceObjectW.screenVertices[uint(_index*2 + 1)] / tv1p;
			
            sv0 = apa*tv0x + apb*tv0y + apc*tv0z + apd;
            sv1 = apa*tv1x + apb*tv1y + apc*tv1z + apd;
			
            if (sv0*sv1 >= 0)                                           
                return null;
			
            d = sv1 - sv0;
            k0 = sv1 / d;
            k1 = -sv0 / d;
			
            tv01z = (tv0z*k0 + tv1z*k1);
            tv01p = lens.getPerspective(tv01z);
            tv01x = (tv0x*k0 + tv1x*k1) * tv01p;
            tv01y = (tv0y*k0 + tv1y*k1) * tv01p;
			
            if (!_viewSourceObjectQ.contains(q, renderer, tv01x, tv01y))
                return null;
			
			return renderer.primitiveSource[w].onepointcut(w, renderer, tv01x, tv01y, tv01z);
        }
        
		/**
		 * Creates a new <code>QuadrantRiddleFilter</code> object.
		 *
		 * @param	maxdelay	[optional]		The maximum time the filter can take to resolve z-depth before timing out.
		 */
        public function QuadrantRiddleFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
        
		/**
		 * @inheritDoc
		 */
        public function filter(renderer:QuadrantRenderer):void
        {
        	this.renderer = renderer;
            start = getTimer();
            check = 0;
    		lens = renderer._view.camera.lens;
    		
            primitives = renderer.list();
            turn = 0;
            
            while (primitives.length > 0)
            {
                var leftover:Vector.<uint> = new Vector.<uint>();
				var priIndex:uint;
                for each (priIndex in primitives)
                {
                    
                    ++check;
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
                    
                    rivals = renderer.getRivals(priIndex, renderer.primitiveSource[priIndex].source);
					var rival:uint;
                    for each (rival in rivals)
                    {
                    	if (rival == priIndex)
                            continue;
                        if (renderer.primitiveProperties[uint(rival*9 + 6)] >= renderer.primitiveProperties[uint(priIndex*9 + 7)])
                            continue;
                        if (renderer.primitiveProperties[uint(rival*9 + 7)] <= renderer.primitiveProperties[uint(priIndex*9 + 6)])
                            continue;
                        
                        parts = riddle(priIndex, rival);
                        
                        if (parts == null)
                            continue;
    					
                        renderer.remove(priIndex);
						var part:uint;
                        for each (part in parts)
                        	if (renderer.primitive(part))
                            	leftover.push(part);
                        
                        break;
                    }
                }
                primitives = leftover;
                turn += 1;
                if (turn == 40)
                    break;
            }
        }
        
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "QuadrantRiddleFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }

}