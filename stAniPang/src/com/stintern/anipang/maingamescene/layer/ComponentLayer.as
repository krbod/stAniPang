package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class ComponentLayer extends Sprite
    {
        public function ComponentLayer()
        {
            this.name = Resources.LAYER_COMPONENT;
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
        }
    }
}