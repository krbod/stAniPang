package com.stintern.anipang.worldmapscene
{
	import com.stintern.anipang.SceneManager;
	import com.stintern.anipang.maingamescene.LevelManager;
	import com.stintern.anipang.maingamescene.layer.MainGameScene;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.worldmapscene.layer.StageInfoLayer;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TouchManager
	{
		private var _isTouched:Boolean;
		private var _isMoved:Boolean;
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
						
						_touchMoveCallback(touch.globalY - touch.previousGlobalY);
						_isMoved = true;
						break;
					
					case TouchPhase.ENDED :
						_isTouched = false;
					
						if( _isMoved )
						{
							_isMoved = false;	
						}
						else
						{
							var stageName:String = ((event.target as DisplayObject).name ); 
							if( stageName == "bkg" )
								return;
							
							var stage:uint = uint(stageName.slice(stageName.lastIndexOf("_")+1, stageName.length));

							LevelManager.instance.currentStageLevel = stage;
							
							var stageInfoLayer:StageInfoLayer= new StageInfoLayer();
                            stageInfoLayer.name = Resources.LAYER_STAGE_INFO;
                            (Starling.current.root as SceneManager).currentScene.addChild(stageInfoLayer);
						}
						
						break;
				}
			}
		}
		
	}
}