package com.dehats.air
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.BitmapData;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.system.Capabilities;
	
	public class AppWinManager extends EventDispatcher
	{

		public static const EVENT_BEFORE_CLOSING:String = "beforeClosing";

		public var isDocked:Boolean = false;
				
		private var nativeWin:NativeWindow;
		
		private var dockImage:BitmapData;

		private var dockOnClose:Boolean;
		
		public function AppWinManager(pWin:NativeWindow, pDockOnClose:Boolean=true)
		{			
			
			nativeWin= pWin ;
			nativeWin.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onDisplayChanged);
			dockOnClose = pDockOnClose;
		}
							
		
		public function prepareForSystray( pDockImageClass:Class, pToolTip:String="", pMenu:NativeMenu=null):void {
   
 		     dockImage = new pDockImageClass().bitmapData;
 		     
 		     var menu:NativeMenu;
 		     if( pMenu!=null) menu =pMenu;
 		     else menu = createSystrayRootMenu();
 		     
     		//For windows systems we can set the systray props            		
      		if (NativeApplication.supportsSystemTrayIcon)
      		{
      			
      			var sysTrayIcon:SystemTrayIcon = SystemTrayIcon(NativeApplication.nativeApplication.icon);
      			
				sysTrayIcon.tooltip =pToolTip;
		      
				sysTrayIcon.addEventListener(MouseEvent.CLICK, undock);
	      
				sysTrayIcon.menu = menu; 				
     		}
     		
     		// MacOSX
			if( NativeApplication.supportsDockIcon)
			{
				var dockIcon:flash.desktop.DockIcon = NativeApplication.nativeApplication.icon as flash.desktop.DockIcon;
				
				dockIcon.addEventListener(MouseEvent.CLICK, undock); // doesn't work ! ?
				
				dockIcon.menu = menu; 
			}
				
		}
		

   		private function onDisplayChanged(pEvt:NativeWindowDisplayStateEvent):void
   		{

   			 if(pEvt.afterDisplayState == NativeWindowDisplayState.MINIMIZED) 
   			 {
	   			isDocked = true ;		 	
   			 }
   			 else if(pEvt.afterDisplayState == NativeWindowDisplayState.NORMAL)
   			 {
	   			isDocked = false ;		 	
   			 }
   			 else if(pEvt.afterDisplayState == NativeWindowDisplayState.MAXIMIZED)
   			 {
	   			isDocked = false ;		 	   			 	
   			 }
   			 
   		}	
   
		private function createSystrayRootMenu():NativeMenu
		{
			
      		//Add the menuitems with the corresponding actions
			var menu:NativeMenu = new NativeMenu();
      		var openNativeMenuItem:NativeMenuItem = new NativeMenuItem("Open");
			var exitNativeMenuItem:NativeMenuItem = new NativeMenuItem("Exit");

			//What should happen when the user clicks on something...       

			openNativeMenuItem.addEventListener(Event.SELECT, undock);

			exitNativeMenuItem.addEventListener(Event.SELECT, onCloseApp);

			//Add the menuitems to the menu
			menu.addItem(openNativeMenuItem);
			menu.addItem(new NativeMenuItem("",true));//separator			
			menu.addItem(exitNativeMenuItem);
      
			return menu;
		}
   
   		private function onCloseApp(pEvt:Event):void
   		{
   			dispatchEvent(new Event(EVENT_BEFORE_CLOSING));
   			
   			NativeApplication.nativeApplication.exit();
   		}
   
	   public function dock():void {
	   	
	      nativeWin.visible = false;
	      
	      if( dockImage) NativeApplication.nativeApplication.icon.bitmaps = [dockImage];
	      
	      isDocked = true ;
	   }
	

	   public function undock(evt:Event):void {
	      //After setting the window to visible, make sure that the application is ordered to the front,       
	      //else we'll still need to click on the application on the taskbar to make it visible
	      nativeWin.visible = true;
	      nativeWin.orderToFront();
	      
	      //Clearing the bitmaps array also clears the applcation icon from the systray
	      NativeApplication.nativeApplication.icon.bitmaps = [];
	      
	      isDocked = false;
	   }		
		   
	   public function center(pWin:NativeWindow=null):void
	   {
	   		if(pWin==null) pWin = nativeWin;
			pWin.x = (Capabilities.screenResolutionX - pWin.width) / 2;
			pWin.y = (Capabilities.screenResolutionY - pWin.height) / 2;
	   }			


		public function createNotifWin(pSprite:Sprite):void
		{
				
			var win:NotificationWin = new NotificationWin(pSprite);
			win.x = Capabilities.screenResolutionX - pSprite.width - 10;
			win.y = 30+( (NativeApplication.nativeApplication.openedWindows.length-2) *(pSprite.width+10) );
						
			win.activate();	
			
		}			
			
	}
}