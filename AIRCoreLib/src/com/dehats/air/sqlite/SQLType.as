package com.dehats.air.sqlite
{
	
    public class SQLType
    {
    	
    	public static const TYPES:Array = [ TEXT, NUMERIC, INTEGER, REAL, DATE, BOOLEAN, XML, XMLLIST, OBJECT, NONE];

        public static const TEXT:String = "TEXT";
    	
        public static const NUMERIC:String = "NUMERIC";

        public static const INTEGER:String = "INTEGER";

        public static const REAL:String = "REAL";

        public static const NONE:String = "NONE";
        
        // AIR Specific affinity type (plus string (=text) and number(=real))

        public static const BOOLEAN:String = "BOOLEAN";

        public static const DATE:String = "DATE";

        public static const XML:String = "XML";

        public static const XMLLIST:String = "XMLLIST";

        public static const OBJECT:String = "OBJECT";


		public static function getAffinity(pType:String):String
		{
/*
# If the data type of the column contains any of the strings "CHAR", "CLOB", "STRI", or "TEXT" then that column has TEXT/STRING affinity. Notice that the type VARCHAR contains the string "CHAR" and is thus assigned TEXT affinity.
# If the data type for the column contains the string "BLOB" or if no data type is specified then the column has affinity NONE.
# If the data type for column contains the string "XMLL" then the column has XMLLIST affinity.
# If the data type is the string "XML" then the column has XML affinity.
# If the data type contains the string "OBJE" then the column has OBJECT affinity.
# If the data type contains the string "BOOL" then the column has BOOLEAN affinity.
# If the data type contains the string "DATE" then the column has DATE affinity.
# If the data type contains the string "INT" (including "UINT") then it is assigned INTEGER affinity.
# If the data type for a column contains any of the strings "REAL", "NUMB", "FLOA", or "DOUB" then the column has REAL/NUMBER affinity.
# Otherwise, the affinity is NUMERIC.
*/			

			var dataType:String = pType.toLocaleLowerCase();
			
			if( dataType.indexOf("char") !=-1) return TEXT;
			if( dataType.indexOf("clob") !=-1) return TEXT;
			if( dataType.indexOf("stri") !=-1) return TEXT;
			if( dataType.indexOf("text") !=-1) return TEXT;
			
			if(dataType==null || dataType=="" || dataType=="blob") return NONE;
			
			if( dataType.indexOf("xmll") !=-1) return XMLLIST;
			
			if( dataType=="xml" ) return XML;

			if( dataType.indexOf("obje") !=-1) return OBJECT;

			if( dataType.indexOf("bool") !=-1) return BOOLEAN;
			
			if( dataType.indexOf("date") !=-1) return DATE;
			
			if( dataType.indexOf("int") !=-1) return INTEGER;

			if( dataType.indexOf("real") !=-1) return REAL;
			if( dataType.indexOf("numb") !=-1) return REAL;
			if( dataType.indexOf("floa") !=-1) return REAL;
			if( dataType.indexOf("doub") !=-1) return REAL;
			
			return NUMERIC;

		}

    }
}