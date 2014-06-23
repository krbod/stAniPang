package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class MainGameScene extends Sprite
    {
        private var _componentLayer:PanelLayer;
        private var _mainGameLayer:MainGameLayer;
        
        public function MainGameScene()
        {
            this.name = Resources.SCENE_MAIN_GAME;
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
			
			AssetLoader.instance.loadDirectory(onComplete, null, Resources.PATH_DIRECTORY_BLOCK, Resources.PATH_DIRECTORY_WORLD_MAP);
          
            function onComplete():void
            {
                _componentLayer = new PanelLayer();
                _mainGameLayer = new MainGameLayer();
                
                addChild( _mainGameLayer );
                addChild( _componentLayer );
            }
        }
    }
}
