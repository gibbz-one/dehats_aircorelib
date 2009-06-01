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

		public static const EVENT_UNREGISTRATION_SUCCESSFULL:String="unregisterSuccess";
		public static const EVENT_UNREGISTRATION_FAILURE:String="unregisterFailure";
		public static const EVENT_UNREGISTRATION_ERROR:String="unregisterError";

		public static const ELSITEM_LICENSE:String="license";

		public var license:String;
		
		private var productCode:String;
		private var tmpKey:String;
		private var registerUrlLoader:URLLoader;		
		private var registrationScriptURL:String;
		private var unregisterUrlLoader:URLLoader;				
		private var unregistrationScriptURL:String;

		
		public function LicenseManager(pRegistrationScriptURL:String, pUnregistrationURL:String, pProductCode:String)
		{
			registrationScriptURL = pRegistrationScriptURL;
			unregistrationScriptURL = pUnregistrationURL;
			productCode = pProductCode;
			
			registerUrlLoader = new URLLoader();
			
			registerUrlLoader.addEventListener(Event.COMPLETE, onRegistrationAttemptComplete);
			registerUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, onRegistrationAttemptFailure);			
			registerUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRegistrationAttemptFailure);		

			unregisterUrlLoader = new URLLoader();
			
			unregisterUrlLoader.addEventListener(Event.COMPLETE, onUnRegistrationAttemptComplete);
			unregisterUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, onUnRegistrationAttemptFailure);			
			unregisterUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUnRegistrationAttemptFailure);		
						
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
				trace(license)
				return true;
			}
		}
 
 		
		public function registerLicense(pLicense:String):void
		{
			tmpKey = pLicense;
			var req:URLRequest = new URLRequest(registrationScriptURL);
			req.method = URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			variables.license = pLicense;
			variables.productCode = productCode;			
			req.data = variables;
			
			registerUrlLoader.load(req);
		}
		
		private function onRegistrationAttemptComplete(pEvent:Event):void
		{
			var response:String = new String (registerUrlLoader.data);
			
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

		private function saveLicense(pLicense:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte( pLicense, "UTF-8");
			EncryptedLocalStore.setItem( ELSITEM_LICENSE, bytes );
		}
		
				
		private function onRegistrationAttemptFailure(pEvent:Event):void
		{
			dispatchEvent( new Event(EVENT_REGISTRATION_ERROR));
		}
		

		
		public function unregister():void
		{
			
			var req:URLRequest = new URLRequest(unregistrationScriptURL);
			req.method = URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			variables.license = license;
			variables.productCode = productCode;			
			req.data = variables;
			
			unregisterUrlLoader.load(req);
			
		}

		private function onUnRegistrationAttemptComplete(pEvent:Event):void
		{
			var response:String = new String (unregisterUrlLoader.data);
			if(response=="valid")
			{
				removeLicensingInfo();				
				dispatchEvent( new Event(EVENT_UNREGISTRATION_SUCCESSFULL));
			}
			
			else
			{
				dispatchEvent( new Event(EVENT_UNREGISTRATION_FAILURE));
			}
			
		}
		
		private function onUnRegistrationAttemptFailure(pEvent:Event):void
		{
			dispatchEvent( new Event(EVENT_UNREGISTRATION_ERROR));
		}

		private function removeLicensingInfo():void
		{
			EncryptedLocalStore.removeItem(ELSITEM_LICENSE);
		}
		

	}
}