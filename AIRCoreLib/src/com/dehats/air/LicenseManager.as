package com.dehats.air
{
	import flash.data.EncryptedLocalStore;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class LicenseManager extends EventDispatcher
	{

		public static const EVENT_REGISTRATION_SUCCESSFULL:String="success";
		public static const EVENT_REGISTRATION_FAILURE:String="failure";
		public static const EVENT_REGISTRATION_ERROR:String="error";

		public static const ELSITEM_LICENSE:String="license";

		public var license:String;
		
		private var urlLoader:URLLoader;
		private var tmpKey:String;
		private var registrationScriptURL:String;

		
		public function LicenseManager(pRegistrationScriptURL:String)
		{
			registrationScriptURL = pRegistrationScriptURL;
			
			urlLoader = new URLLoader();
			
			urlLoader.addEventListener(Event.COMPLETE, onRegistrationAttemptComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onRegistrationAttemptFailure);			
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRegistrationAttemptFailure);		
						
		}

		public function checkLicense():Boolean
		{
			var storedValue:ByteArray = EncryptedLocalStore.getItem(ELSITEM_LICENSE);
			
			if(storedValue==null)
			{
				return false;
			}
			
			else
			{
				license = storedValue.readMultiByte( storedValue.bytesAvailable, "UTF-8");
				return true;
			}
		}
		
		private function saveLicense(pLicense:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte( pLicense, "UTF-8");
			EncryptedLocalStore.setItem( ELSITEM_LICENSE, bytes );
		}
		
		// Dev only : should never be used in production
/* 		
		private function removeLicensingInfo():void
		{
			EncryptedLocalStore.removeItem(ELSITEM_LICENSE);
		}
		
 */
 
 		
		public function registerLicense(pLicense:String, pProductCode:String):void
		{
			tmpKey = pLicense;
			var req:URLRequest = new URLRequest(registrationScriptURL);
			req.method = URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			variables.license = pLicense;
			variables.productCode = pProductCode;			
			req.data = variables;
			
			urlLoader.load(req);
		}
		
		private function onRegistrationAttemptComplete(pEvent:Event):void
		{
			var response:String = new String (urlLoader.data);
			
			if(response=="valid")
			{
				dispatchEvent( new Event(EVENT_REGISTRATION_SUCCESSFULL));
				saveLicense(tmpKey);
			}
			
			else
			{
				dispatchEvent( new Event(EVENT_REGISTRATION_FAILURE));
			}
			
		}
		
		private function onRegistrationAttemptFailure(pEvent:Event):void
		{
			dispatchEvent( new Event(EVENT_REGISTRATION_ERROR));
		}

	}
}