package com.dehats.air.sqlite
{
	import flash.data.SQLColumnSchema;
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	public class SQLiteDBHelper 
	{
		
		private var cnx:SQLConnection;
			
		
		public function SQLiteDBHelper()
		{
		}
		
		// DB


		public function openDBFile(pFile:File, pCryptoKey:ByteArray=null):void
		{
			cnx = new SQLConnection();	

			cnx.open(pFile, SQLMode.CREATE, false, 1024, pCryptoKey);

		}
		
		public function reencrypt(pKey:ByteArray):void
		{
			cnx.reencrypt(pKey);
		}
		
		// Main routine
		
		public function executeStatement(pStatement:String, pParams:Object=null):SQLResult
		{
			trace( pStatement)
			var createStmt:SQLStatement = new SQLStatement();
			
			createStmt.sqlConnection = cnx;
			createStmt.text = pStatement;

			if( pParams)
			{
				// copy params
				for ( var z:String in pParams)  createStmt.parameters[z] = pParams[z];
			}
			
			try
			{
			    createStmt.execute();
			}
			catch (error:SQLError)
			{
				Alert.show(error.message+"\n"+error.details+"\nStatement:\n"+pStatement, "Error");
			}						
			
			return createStmt.getResult();
		}		
		
		// Structure
		
		public function compact():void
		{
			cnx.compact();
		}
		
		public function getSchemas():SQLSchemaResult
		{
			
			try
			{
			    cnx.loadSchema();
			}
			catch (error:SQLError)
			{
				Alert.show(error.message+"\n"+error.details);
				return null;
			}			
			
			return cnx.getSchemaResult();
		}
	
		
		public function createTable(pTableName:String, pColumns:Array=null):void
		{
					
			var sql:String = "CREATE TABLE IF NOT EXISTS "+ pTableName ;
			
			if(pColumns) sql+=" (" + pColumns.join(", ")+")";
			
			else sql+=" ( "+pTableName+"id INTEGER PRIMARY KEY AUTOINCREMENT )";
		
			executeStatement(sql);
		}
		
		
		public function dropTable(pTable:SQLTableSchema):void
		{
			var sql:String = "DROP TABLE "+ pTable.name ;	
			executeStatement(sql);
		}


		public function renameTable(pTable:SQLTableSchema, pNewName:String):void
		{
			executeStatement("ALTER TABLE "+ pTable.name+" RENAME TO "+ pNewName);
		}
			
			
		public function addColumn(pTable:SQLTableSchema, pColName:String, pDataType:String, pAllowNull:Boolean, pUnique:Boolean, pDefault:String=""):void
		{
			var definition:String = pDataType;
			if( ! pAllowNull ) definition+=" NOT NULL";
			if( pUnique) definition += " UNIQUE";					
			if( pDefault.length>0 )definition += " DEFAULT "+ pDefault;

			executeStatement("ALTER TABLE "+ pTable.name+" ADD "+ pColName +" "+ definition);
		}
		
/*
		// NOT SUPPORTED !
		
		public function modifyColumn(pTable:SQLTableSchema, pColName:String, pColDef:String):void
		{
			executeStatement("ALTER TABLE " + pTable.name+" MODIFY COLUMN " + pColName +" "+ pColDef);
		}
		
*/			


		public function copyTable(pTable:SQLTableSchema, pNewName:String, pCopyData:Boolean=true):void
		{
			
			var originalStatement:String = pTable.sql;
			
			var index:int = originalStatement.indexOf("(");
						
			var newStatement:String = "CREATE TABLE IF NOT EXISTS "+ pNewName + originalStatement.slice(index);

			executeStatement( newStatement);
			
			if( pCopyData==false) return ;
			
			executeStatement("INSERT INTO "+ pNewName+ " SELECT * FROM "+pTable.name+";");
						
		}


		public function renameColumn(pTable:SQLTableSchema, pColName:String, pColNewName:String):void
		{
			// Not directly supported
			// We have to create a new backup table from the previous one, change the col name
			//then drop the whole original table , and rename the backup
			
			var allCols:Array = pTable.columns;
			var remainingCols:Array = [];			

			for ( var i:int = 0 ; i < allCols.length ; i++)
			{
				var col:SQLColumnSchema = allCols[i];
				if(col.name!= pColName) remainingCols.push(col.name);
				else remainingCols.push(pColNewName);
			}

			var rawSQL:String = pTable.sql;
			
			var definitions:String = rawSQL.slice( rawSQL.indexOf("(")+1, rawSQL.lastIndexOf(")"));
					
			var newDefs:String="";
			
			var defTab:Array = definitions.split(",");
			
			// parse the column 
			for ( var j:int = 0 ; j < defTab.length ; j++)
			{
				var def:String = defTab[j];
				var colName:String = def.match(/\w+/)[0];
				
				if( pColName == colName)
				{
					var reg:RegExp = new RegExp( pColName, "");
					def = def.replace(reg, pColNewName);
					
				}  
				newDefs+= def;
				if(j< defTab.length-1) newDefs+=", ";
			}

			var backupCreateStatement:String = "("+newDefs+")";
			
			executeStatement("CREATE TABLE backup "+backupCreateStatement+";");
			executeStatement("INSERT INTO backup SELECT * FROM "+pTable.name+";");

			executeStatement("DROP TABLE "+ pTable.name+";");	
			executeStatement("ALTER TABLE backup RENAME TO "+ pTable.name);			
			
		}
	
		
		public function removeColumn(pTable:SQLTableSchema, pColName:String):void
		{
			// Not directly supported
			// We have to create a new backup table from the previous one (minus the discarded column)
			//then drop the whole original table, and rename the backup
			
			var allCols:Array = pTable.columns;
			var remainingCols:Array = [];

			for ( var i:int = 0 ; i < allCols.length ; i++)
			{
				var col:SQLColumnSchema = allCols[i];
				if(col.name!= pColName) remainingCols.push(col.name);
			}

			var rawSQL:String = pTable.sql;
			var defsArray:Array = rawSQL.match(/\(.*/g);
			var defs:String= defsArray[0];

			var regExp:RegExp = new RegExp("[(,]\\s*"+pColName+"[^,)]*", "g");
			defs = defs.replace(regExp, "");
			if( defs.charAt(0)==",") defs = "("+defs.substr(1);
			
			var backupCreateStatement:String = defs; 
			
			executeStatement("CREATE TABLE backup "+backupCreateStatement+";");
			executeStatement("INSERT INTO backup SELECT "+remainingCols.join(",")+" FROM "+pTable.name+";");

			executeStatement("DROP TABLE "+ pTable.name+";");	
			executeStatement("ALTER TABLE backup RENAME TO "+ pTable.name);		
			
		}
		
		
		public function getTablePK(pTable:SQLTableSchema):SQLColumnSchema
		{						
			
			for ( var i:int = 0 ; i < pTable.columns.length ; i++)
			{
				var col:SQLColumnSchema = pTable.columns[i] as SQLColumnSchema;

				if( col.primaryKey) return col ;
				
			}
			
			return null;
		}
		
		private function getTablePKName(pTable:SQLTableSchema):String
		{			
			var pk:SQLColumnSchema = getTablePK(pTable);

			if(pk!=null) return pk.name;
			
			return "rowid";
		}
		
		// INDICES

		/**
		 * 
		 * @param pName
		 * @param pTable
		 * @param pCol
		 * @param pUnique
		 * @param pIfNotExists
		 * @param pOrder empty string or ASC or DESC
		 * @return 
		 * 
		 */		
		public function createIndex(pName:String, pTable:SQLTableSchema, pCol:SQLColumnSchema, pUnique:Boolean=false, pIfNotExists:Boolean= true, pOrder:String=""):SQLResult
		{
			var sql:String = "CREATE ";
			if( pUnique ) sql+="UNIQUE ";
			sql+="INDEX ";
			if( pIfNotExists) sql+="IF NOT EXISTS ";
			sql+= pName +" ON "+pTable.name+" ( "+pCol.name + pOrder+" );";
			
			return executeStatement( sql) ;
		}
		
		public function removeIndex(pName:String):SQLResult
		{
			var sql:String = "DROP INDEX IF EXISTS "+ pName;
			return executeStatement(sql);
		}

		
		// Records
		
		public function getTableRecords(pTable:SQLTableSchema):Array
		{
			var res:SQLResult = executeStatement("SELECT rowid AS rowid,* FROM "+pTable.name);				
			return res.data ;
		}


		public function updateRecord(pTable:SQLTableSchema, pOldRecord:Object, pVo:Object):void
		{
			
			var sql:String = "UPDATE "+ pTable.name+ " SET ";
			
			var params:Object={};
			
			for ( var i:int = 0 ; i < pTable.columns.length ; i++)
			{
				var col:SQLColumnSchema = pTable.columns[i] as SQLColumnSchema;
				if( ! col.primaryKey)
				{					
					sql+= col.name + " = @p"+i;
					params["@p"+i] = pVo[ col.name];
					
					if(i!=pTable.columns.length-1) sql+=", ";	
				}
									
			}				

			// old method using getTablePKName
			/*
			var pkName:String = getTablePKName(pTable);
			sql+=" WHERE "+ pkName +" = '"+ pOldRecord[pkName] +"'";
			*/
			
			// new method using rowid, faster and more secure
			sql+=" WHERE rowid ="+ pOldRecord["rowid"] ;
			
			executeStatement(sql, params);
			
		}


		public function createRecord(pTable:SQLTableSchema, pVo:Object):void
		{
			
			var sql:String = "INSERT INTO "+ pTable.name;
			
			var colDefs:Array=[];
			var colValues:Array=[];
			
			var params:Object = {};
			
			for ( var i:int = 0 ; i < pTable.columns.length ; i++)
			{

				var col:SQLColumnSchema = pTable.columns[i] as SQLColumnSchema;
				
				if( ! col.primaryKey)
				{				
					if(pVo[ col.name]!="" || pVo[ col.name] is XML)
					{
						colDefs.push(col.name);
						
						colValues.push("@p"+i);
						params["@p"+i] = pVo[col.name];
						
					}
				}
			}				

			sql+=" ("+colDefs.join(",")+") VALUES ("+ colValues.join(",") +");";
			
			executeStatement(sql, params);
			
		}


		public function exportTableRecords(pTable:SQLTableSchema, pList:Array=null):String
		{
			var records:Array ;
			
			var st:String="";
			
			if( pList == null) records = getTableRecords(pTable);
			else records = pList;
			
			if( records==null) return "";
			
			var n:int = records.length;
			
			for ( var i:int=0 ; i < n ; i++)
			{
				var rec:Object = records[i];				
				st+= exportRecord(pTable, rec);				
				st+="\n";			
			}			
			
			return st;
			
		}
		
		private function exportRecord(pTable:SQLTableSchema, pRec:Object):String
		{
			var st:String = "INSERT INTO "+ pTable.name;
			
			var colDefs:Array=[];
			var colValues:Array=[];			
			
			for ( var i:int = 0 ; i < pTable.columns.length ; i++)
			{
				var col:SQLColumnSchema = pTable.columns[i] as SQLColumnSchema;
				colDefs.push(col.name);
					
				if(pRec[ col.name] is String)
				{
					var value:String = pRec[ col.name];
					// we need to escape simple quotes
					var reg:RegExp = new RegExp("'", "gi");
					value = value.replace(reg, "\\'");
					colValues.push("'"+value+"'");
				} 
				else if(pRec[ col.name] is XML || pRec[ col.name] is XMLList) colValues.push((pRec[ col.name] as XML).toXMLString());
				else colValues.push((pRec[ col.name]).toString());
					
			}				

			st+=" ("+colDefs.join(",")+") VALUES ("+ colValues.join(",") +");";
			
			return st;
		}


		public function deleteRecord(pTable:SQLTableSchema, pRecord:Object):void
		{
			var sql:String = "DELETE FROM " + pTable.name ;
			
			// old method
			/*
			var pkName:String = getTablePKName(pTable);
			sql+=" WHERE "+ pkName +" = '"+ pRecord[pkName] +"'";
			*/
			// new method using rowid
			sql+=" WHERE rowid ="+ pRecord["rowid"] ;
			
			executeStatement(sql);
			
		}

		public function emptyTable(pTable:SQLTableSchema):Array
		{
			var res:SQLResult = executeStatement("DELETE FROM "+pTable.name);			
			return res.data ;			
		}
		
	}
}