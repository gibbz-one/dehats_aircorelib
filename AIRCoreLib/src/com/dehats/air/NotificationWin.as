package com.dehats.air
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class NotificationWin extends NativeWindow 
	{
		
		private var sprite:Sprite;
		
		private var fadeSpeed:Number;
		
		public function NotificationWin(pSprite:Sprite, pLastingTime:int=2000, pFadeSpeed:Number=0.1)
		{
			
			var options:NativeWindowInitOptions = new NativeWindowInitOptions();
			options.type = NativeWindowType.LIGHTWEIGHT;
			options.systemChrome = NativeWindowSystemChrome.NONE;
			options.transparent = true;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			fadeSpeed = pFadeSpeed;
			
			super(options);
			
			alwaysInFront = true ;
						
			sprite = pSprite;
		
			stage.addChild( pSprite);
			
			var timer:Timer = new Timer(pLastingTime, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(pEvt:Event):void
		{
			sprite.addEventListener(Event.ENTER_FRAME, fadeOut);
		}
		
		private function fadeOut(pEvt:Event):void
		{
			
			if (sprite.alpha>0)
			{
				sprite.alpha-=fadeSpeed;				
			}
			else close();
				
			
		}
		
		
	}
}