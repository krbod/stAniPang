package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    
    public class MainGameScene extends Sprite
    {
        private var _panelLayer:PanelLayer;
        private var _mainGameLayer:MainGameLayer;
        
		private var _onInitedCallback:Function;
		private var _initedLayerCount:uint = 0;
		
        public function MainGameScene()
        {
            this.name = Resources.SCENE_MAIN_GAME;
        }
        
        public function init(onInited:Function = null):void
        {
			_onInitedCallback = onInited;
			
			AssetLoader.instance.loadDirectory(onComplete, null, Resources.getAsset(Resources.PATH_DIRECTORY_BLOCK));
        }
		
		private function onComplete():void
		{
			_panelLayer = new PanelLayer();
			_panelLayer.init(onInit);
			
			_mainGameLayer = new MainGameLayer();
			_mainGameLayer.init(onInit);
			
			function onInit():void
			{
				++_initedLayerCount;
				if( _initedLayerCount == 1)
				{
					addChild( _panelLayer );
					addChild( _mainGameLayer );
					
					_onInitedCallback();
				}
			}
		}
    }
}
