package com.stintern.anipang.maingamescene.block
{
    import starling.display.Image;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;
    
    public class Block
    {
        private var _type:uint;
        private var _image:Image;
        
        public function Block()
        {
        }
        
        public function setTouchEnable():void
        {
            _image.addEventListener(TouchEvent.TOUCH, onTouch);
        }
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(_image);
            if(touch)
            {
                switch(touch.phase)
                {
                    case TouchPhase.BEGAN : 
                        break;
                    
                    case TouchPhase.MOVED : 
                        break;
                    
                    case TouchPhase.ENDED :
                        break;
                }
            }
        }
        
        internal function init(type:uint, texture:Texture):void
        {
            if( _image == null )
            {                
                _image = new Image(texture);
            }
            
            _type = type;
        }
        
        public function get type():uint
        {
            return _type;
        }
        public function set type(type:uint):void
        {
            _type = type;
        }
        
        public function get image():Image
        {
            return _image;
        }
        public function set image(image:Image):void
        {
            _image = image;
        }
        
        public function get visible():Boolean
        {
            return _image.visible;
        }
        public function set visible(visible:Boolean):void
        {
            _image.visible = visible;
        }
    }
}