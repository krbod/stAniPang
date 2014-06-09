package com.stintern.anipang.maingamescene.layer
{
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
            
            _componentLayer = new ComponentLayer();
            _mainGameLayer = new MainGameLayer();
            
            addChild( _componentLayer );
            addChild( _mainGameLayer );
        }
    }
}