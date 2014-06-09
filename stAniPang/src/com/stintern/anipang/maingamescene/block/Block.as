package com.stintern.anipang.maingamescene.block
{
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;
    
    public class Block
    {
        private var _type:uint;
        private var _image:Image;
		
		private var _row:uint, _col:uint;
		
		private var _isTouch:Boolean;
		private var _distanceX:int, _distanceY:int;
		
        public function Block()
        {
        }
        
        internal function init(type:uint, texture:Texture):void
        {
            if( _image == null )
            {                
                _image = new Image(texture);
				_image.addEventListener(TouchEvent.TOUCH, onTouch);
            }
            
            _type = type;
        }
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(event.target as DisplayObject);
			if(touch)
			{
				switch(touch.phase)
				{
					case TouchPhase.BEGAN :
						_isTouch = true;
						_distanceX = 0;
						_distanceY = 0;
						break;
					
					case TouchPhase.MOVED : 
						if(_isTouch)
						{
							_distanceX += touch.globalX - touch.previousGlobalX;
							_distanceY += touch.globalY - touch.previousGlobalY;
							
							if( _distanceX < (event.target as DisplayObject).width * -1 )
							{
								//moveLeft(event.target as Image);
							}
							else if( _distanceX > (event.target as DisplayObject).width )
							{
								//moveRight();
							}
							
							if( _distanceY < (event.target as DisplayObject).height * -1 )
							{
								//moveUp();
							}
							else if( _distanceY > (event.target as DisplayObject).height )
							{
								//moveDown();
							}
						}
						break;
					
					case TouchPhase.ENDED :
						_isTouch = true;
						break;
				}
			}
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
		
		public function get row():uint
		{
			return _row;
		}
		public function set row(row:uint):void
		{
			_row = row;
		}
		
		public function get col():uint
		{
			return _col;
		}
		public function set col(col:uint):void
		{
			_col = col;
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