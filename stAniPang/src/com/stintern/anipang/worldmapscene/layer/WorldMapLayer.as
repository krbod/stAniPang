package com.stintern.anipang.worldmapscene.layer
{
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	
	import starling.display.Sprite;
	import com.stintern.anipang.worldmapscene.TouchManager;
	
	public class WorldMapLayer extends Sprite
	{
		private var _touchManager:TouchManager;
		private var _worldContainer:Sprite;
		
		private var _container:Sprite;
		
		public function WorldMapLayer()
		{
			this.name = Resources.LAYER_WORLD_MAP;
			
			init();
		}
		
		private function init():void
		{
			_worldContainer = new Sprite();
			addChild(_worldContainer);
			
			_touchManager = new TouchManager(onTouchMove);
			
			_container = new Sprite();
			_worldContainer.addChild(_container);
		}
		
		public function onImageLoaded( flieName:String ):void
		{
			UILoader.instance.loadAll(flieName, _container, _touchManager.onTouch);
		}
		
		private function onTouchMove(distance:int):void
		{
			_worldContainer.y += distance;
		}
		
	}
}