package com.stintern.anipang.maingamescene.layer
{
	import com.stintern.ane.FacebookANE;
	import com.stintern.anipang.SceneManager;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.layer.WorldMapScene;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class MissionClearLayer extends Sprite
	{

		private var _container:Sprite;
			
		public function MissionClearLayer()
		{
			init(null);
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
				Resources.getAsset(Resources.PATH_IMAGE_MISSION_CLEAR_SPRITE_SHEET),
				Resources.getAsset(Resources.PATH_XML_MISSION_CLEAR_SPRITE_SHEET)
				);
			
			UILoader.instance.loadUISheet(onLoadUI, null, paths);
				
			function onLoadUI():void
			{
				UILoader.instance.loadAll(Resources.PATH_IMAGE_MISSION_CLEAR_TEXTURE_NAME, _container, onTouch, 0, 0);
				if( onComplete != null )
					onComplete();
			}
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
						if( (event.target as Image).name == "nextButton" || 
							(event.target as Image).name == "closeButton"
						)
						{
							loadWorldMap();
						}
						else if( (event.target as Image).name == "shareButton" )
						{
							share();
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
		
		private function share():void
		{
			var facebookANE:FacebookANE = new FacebookANE();
			facebookANE.shareApp();
		}
	}
}
