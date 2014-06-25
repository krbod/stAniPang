package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    
    public class MainGameScene extends Sprite
    {
        private var _panelLayer:PanelLayer;
        private var _mainGameLayer:MainGameLayer;
        
        public function MainGameScene()
        {
            this.name = Resources.SCENE_MAIN_GAME;
        }
        
        public function init(onInited:Function = null):void
        {
			AssetLoader.instance.loadDirectory(onComplete, null, Resources.getAsset(Resources.PATH_DIRECTORY_BLOCK));
          
            function onComplete():void
            {
                _panelLayer = new PanelLayer();
				_panelLayer.init(onInit);
				
                _mainGameLayer = new MainGameLayer();
				_mainGameLayer.init(onInit);
                
            }
			
			var initedLayerCount:uint = 0;
			function onInit():void
			{
				++initedLayerCount;
				if( initedLayerCount == 2)
				{
					addChild( _mainGameLayer );
					addChild( _panelLayer );
					
					onInited();
				}
			}
        }
    }
}
