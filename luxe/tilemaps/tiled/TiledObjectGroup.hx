package luxe.tilemaps.tiled;

import luxe.tilemaps.tiled.TiledMap;
import luxe.Vector;

enum TiledObjectType {
	polyline;
	polygon;
	rectangle;
	ellipse;
} //TiledObjectType

class TiledPolyObject {	
	public var origin:Vector;
	public var points:Array<Vector>;
	public function new(_origin:Vector, _points:Array<Vector>) {
		origin = _origin;
		points = _points;
	}
} //TiledPolyObject

class TiledObject {

	public var group : TiledObjectGroup;
		//A identification number, which represents a part of the tileset.
	public var gid:Int;
		//The name of this object
	public var name:String;
		//The type of this object
	public var type:String;
		//The x coordinate of this object (in pixels!)
	public var pos:Vector;
		//The width of this object in pixels
	public var width:Int;
		//The width of this object in pixels
	public var height:Int;
		//The object that represents a poly-like object (line/polygon)
	public var polyobject:TiledPolyObject;
		//The type of object this object represents
	public var object_type : TiledObjectType;
		//Contains all properties from this object
	public var properties:Map<String, String>;

	public function new( _group:TiledObjectGroup ) {
		group = _group;
		properties = new Map();
		pos = new Vector();
	}

	function is_valid_xml_element( element:Xml ) {
        return Std.string( element.nodeType ) == "element";
    }

    function polyobject_from_xml( xml:Xml ) {

		var points:Array<Vector> = new Array<Vector>();
		var pointsAsString:String = xml.get("points");
		var pointsAsStringArray:Array<String> = pointsAsString.split(" ");
		
		for(point in pointsAsStringArray) {
			var coords:Array<String> = point.split(",");
			points.push(new Vector(Std.parseInt(coords[0]), Std.parseInt(coords[1])));
		}
		
		return new TiledPolyObject( pos.clone(), points );

    } //polyobject_from_xml

	public function from_xml( xml:Xml ) {

		gid = xml.get("gid") != null ? Std.parseInt(xml.get("gid")) : 0;
		name = xml.get("name");
		type = xml.get("type");
		pos.x = Std.parseInt(xml.get("x"));
		pos.y = Std.parseInt(xml.get("y"));
		width = Std.parseInt(xml.get("width"));
		height = Std.parseInt(xml.get("height"));
		
		//default to rectangle
		object_type = TiledObjectType.rectangle;

		for(child in xml) {
			if( is_valid_xml_element(child)) {
				switch( child.nodeName ) {

					case "polygon": {
						object_type = TiledObjectType.polygon;
						polyobject = polyobject_from_xml(child);
					} //polygon

					case "polyline": {
						object_type = TiledObjectType.polyline;
						polyobject = polyobject_from_xml(child);
					} //polyline

					case "ellipse": {
						object_type = TiledObjectType.ellipse;
							//ellipse makes more sense as a centered object
						var _mid_x : Int = Std.int(width/2);
						var _mid_y : Int = Std.int(height/2);

						pos.x += _mid_x;
						pos.y += _mid_y;

					} //ellipse

					case "properties" : {
						for( property in child ) {
							if(is_valid_xml_element(property)) {
								properties.set(property.get("name"), property.get("value"));
							}
						} //each property
					} //properties

				} //switch child nodename
			}
		} //for each child node

	} //from_xml

} //TiledObject

class TiledObjectGroup {
	
	public var map : TiledMap;
	public var name : String;

	public var width : Int;
	public var height : Int;
	public var color:String;
	public var properties:Map<String, String>;
	public var objects : Array<TiledObject>;	

	public function new( _map:TiledMap ) {
		map = _map;

		name = '';
		width = 0;
		height = 0;
		color = '';
		properties = new Map();
		objects = [];

	} //new

    function is_valid_xml_element( element:Xml ) {
        return Std.string( element.nodeType ) == "element";
    } //is_valid_xml_element

	public function from_xml( xml:Xml ) {
		
		name = xml.get("name");
		color = xml.get("color");
		width = Std.parseInt(xml.get("width"));
		height = Std.parseInt(xml.get("height"));
		
		for( child in xml ) {
			if( is_valid_xml_element(child) ) {
				
				if( child.nodeName == "properties" ) {
					for( property in child)  {
						if( is_valid_xml_element(property) ) {
							properties.set(property.get("name"), property.get("value"));
						} //is valid property node
					} //for each property 
				} //if it's a property node
				
				if (child.nodeName == "object") {
					var object:TiledObject = new TiledObject( this );
						object.from_xml( child );
					objects.push( object);
				}
			}
		} //for each child
	} //from_xml

} //TiledObjectGroup