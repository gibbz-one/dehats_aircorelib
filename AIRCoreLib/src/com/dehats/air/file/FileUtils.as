package com.dehats.air.file
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class FileUtils
	{
		
		
		public static function getFileString(file:File, pEncoding:String="utf-8", pConvertEOL:Boolean=true):String
		{
			//var file:File = File.desktopDirectory.resolvePath(pPath);
			
			var stream:FileStream = new FileStream();
			
			stream.open(file, FileMode.READ);
			
			var str:String = stream.readMultiByte(stream.bytesAvailable, pEncoding);
			
			stream.close();
			
			if(pConvertEOL) str = str.replace(/\r\n/g, "\n");
			
			return str;
		}
		
		
		public static function createFileFromString(pPath:String, pText:String, pEncoding:String="utf-8", pConvertEOL:Boolean=true):File
		{
			var file:File =  new File(pPath);			
			writeTextInFile(file, pText, pEncoding, pConvertEOL);			
			return file;
		}
		
		public static function createTmpFileFromString(pName:String, pText:String, pEncoding:String="utf-8", pConvertEOL:Boolean=true):File
		{

			var file:File = File.createTempDirectory().resolvePath(pName);
			writeTextInFile(file, pText, pEncoding, pConvertEOL);
			return file;

		}	
		
		public static function writeTextInFile(pFile:File, pText:String, pEncoding:String="utf-8", pConvertEOL:Boolean=true):void
		{
			// Replace line ending character with the appropriate one
			if(pConvertEOL)
			{
				pText = pText.replace(/\r\n/g, "\n");
				pText = pText.replace(/\n/g, File.lineEnding);
			}
			
			var stream:FileStream = new FileStream();			
			stream.open(pFile, FileMode.WRITE);			
			stream.writeMultiByte(pText, pEncoding);			
			stream.close();			
		}
		
		public static function getOrMoveFile(pDirPath:String, pParentDir:File=null):File
		{
		
			if(pParentDir==null) pParentDir = File.applicationStorageDirectory;
			
			var f:File = pParentDir.resolvePath(pDirPath);
			
			if(!f.exists) { 
				
				trace("Unable to find "+pDirPath+", copying from applicationDirectory to " + pParentDir.nativePath);
				
				var f2:File = File.applicationDirectory.resolvePath(pDirPath); 
				
				if( ! f2.exists ){
					trace("Unable to find file or directory : "+ pDirPath, "File not found");
					return null ;
				} 
				
				var dest:File = pParentDir.resolvePath(pDirPath);
				f2.copyTo(dest);
				 
				return dest;
			}
			else return f;
			
		}

	}
}