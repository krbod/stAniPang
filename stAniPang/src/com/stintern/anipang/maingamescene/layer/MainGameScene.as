package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class MainGameScene extends Sprite
    {
        private var _componentLayer:ComponentLayer;
        private var _mainGameLayer:MainGameLayer;
        
        public function MainGameScene()
        {
            this.name = Resources.LAYER_MAIN_SCENE;
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // 게임에서 사용할 텍스쳐들을 로드
            AssetLoader.instance.loadTexture(
                new Array(Resources.PATH_IMAGE_BLOCK_SPRITE_SHEET),
                onComplete
                );
          
            function onComplete():void
            {
                _componentLayer = new ComponentLayer();
                _mainGameLayer = new MainGameLayer();
                
                addChild( _componentLayer );
                addChild( _mainGameLayer );
            }
        }
    }
}