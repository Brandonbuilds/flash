package away3d.events
{
    import away3d.core.base.*;

    import flash.events.Event;
    
    /**
    * Passed as a parameter when a geometry event occurs
    */
    public class GeometryEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a geometryChanged event object.
    	 */
    	public static const GEOMETRY_UPDATED:String = "geometryUpdated";
    	    	    	
    	/**
    	 * Defines the value of the type property of a dimensionsChanged event object.
    	 */
    	public static const DIMENSIONS_CHANGED:String = "dimensionsChanged";
    	    	    	
    	/**
    	 * Defines the value of the type property of a mappingUpdated event object.
    	 */
    	public static const VISIBLE_CHANGED:String = "visibleChanged";
    	    	    	
    	/**
    	 * Defines the value of the type property of a mappingUpdated event object.
    	 */
    	public static const MAPPING_UPDATED:String = "mappingUpdated";
    	    	    	
    	/**
    	 * Defines the value of the type property of a mappingChanged event object.
    	 */
    	public static const MAPPING_CHANGED:String = "mappingChanged";
    	   	    	
    	/**
    	 * Defines the value of the type property of a geometryChanged event object.
    	 */
    	public static const GEOMETRY_CHANGED:String = "geometryChanged";
    	
    	/**
    	 * A reference to the 3d object that is relevant to the event.
    	 */
        public var geometry:Geometry;
		
		/**
		 * Creates a new <code>MaterialEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>Object3DEvent.TRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENETRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENE_CHANGED</code>, <code>Object3DEvent.RADIUS_CHANGED</code> and <code>Object3DEvent.DIMENSIONS_CHANGED</code>.
		 * @param	object		A reference to the 3d object that is relevant to the event.
		 */
        public function GeometryEvent(type:String, geometry:Geometry)
        {
            super(type);
            this.geometry = geometry;
        }
		
		/**
		 * Creates a copy of the Object3DEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new GeometryEvent(type, geometry);
        }
    }
}
