package com.stintern.anipang.worldmapscene
{
	import com.stintern.anipang.utils.Resources;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TouchManager
	{
		private var _isTouched:Boolean;
		private var _touchMoveCallback:Function;
		
		public function TouchManager(touchMoveCallback:Function)
		{
			_isTouched = false;
			
			_touchMoveCallback = touchMoveCallback;
		}
		
		public function onTouch( event:TouchEvent ):void
		{
			var touch:Touch = event.getTouch(event.target as DisplayObject);
			if(touch)
			{
				switch(touch.phase)
				{
					case TouchPhase.BEGAN :
						_isTouched = true;
						break;
					
					case TouchPhase.MOVED : 
						if( !_isTouched )
							return;
						
						if( (event.target as DisplayObject).name == Resources.WORLD_MAP_BACKGROUND_NAME )
						{
							_touchMoveCallback(touch.globalY - touch.previousGlobalY);
						}
						
						break;
					
					case TouchPhase.ENDED :
						_isTouched = false;
						break;
				}
			}
		}
		
	}
}