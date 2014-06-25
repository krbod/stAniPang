package com.stintern.anipang.maingamescene.layer
{
	import com.stintern.anipang.SceneManager;
	import com.stintern.anipang.maingamescene.LevelManager;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.layer.StageInfoLayer;
	import com.stintern.anipang.worldmapscene.layer.WorldMapScene;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	public class MissionFailureLayer extends Sprite
	{

		private var _container:Sprite;
			
		public function MissionFailureLayer()
		{
			init();
		}
		
		public override function dispose():void
		{
			for(var i:uint=0; i<_container.numChildren; ++i)
			{
				_container.getChildAt(i).dispose()
			}
		}
		
		private function init(onComplete:Function = null):void
		{
			_container = new Sprite();
			addChild(_container);
			
			var paths:Array = new Array(
				Resources.getAsset(Resources.PATH_IMAGE_MISSION_FAILURE_SPTIRE_SHEET),
				Resources.getAsset(Resources.PATH_XML_MISSION_FAILURE_SPTIRE_SHEET)
				);
			
			UILoader.instance.loadUISheet(onLoadUI, null, paths);
				
			function onLoadUI():void
			{
				UILoader.instance.loadAll(Resources.PATH_IMAGE_MISSION_FAILURE_TEXTURE_NAME, _container, onTouch, 0, 0);
				
				initFailedMissionString();
				
				if( onComplete != null )
					onComplete();
			}
		}
		
		private function initFailedMissionString():void
		{
			var textField:TextField = _container.getChildByName(Resources.LABEL_MISSION_FAILURE) as TextField;
			
			switch(LevelManager.instance.stageInfo.missionType)
			{
			case Resources.MISSION_TYPE_ICE:
				textField.text = Resources.MISSION_FAiLURE_STRING_TYPE_ICE;
				break;
				
			case Resources.MISSION_TYPE_SCORE:
				textField.text = Resources.MISSION_FAiLURE_STRING_TYPE_SCORE;
				break;
			}
			textField.fontSize = Starling.current.viewPort.height * 0.02;
			textField.width = textField.textBounds.width + 10;
			textField.height = textField.textBounds.height + 10;
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(event.target as DisplayObject);
			if(touch)
			{
				switch(touch.phase)
				{
					case TouchPhase.BEGAN :
						break;
					
					case TouchPhase.MOVED : 
						break;
					
					case TouchPhase.ENDED :
						if( (event.target as Image).name == Resources.IMAGE_NAME_CLOSE_BUTTON_ON_MISSION_FAILURE )
						{
							loadWorldMap();
						}
						else if( (event.target as Image).name == Resources.IMAGE_NAME_AGAIN_BUTTON )
						{
							regame();
						}
						break;
				}
			}
		}
		
		private function loadWorldMap():void
		{
			var worldMapScene:WorldMapScene = new WorldMapScene();
			worldMapScene.init(onInited);
			
			function onInited():void
			{
				(Starling.current.root as SceneManager).replaceScene( worldMapScene );
			}
		}
		
		private function regame():void
		{
			var stageInfoLayer:StageInfoLayer= new StageInfoLayer();
			stageInfoLayer.name = Resources.LAYER_STAGE_INFO;
			(Starling.current.root as SceneManager).currentScene.addChild(stageInfoLayer);
		}
	}
}
