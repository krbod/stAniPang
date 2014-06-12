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
        // 블럭 정보
        private var _type:uint;
        private var _image:Image;
		private var _row:uint, _col:uint;
		
        // 터치 관련
		private var _isTouch:Boolean;
		private var _distanceX:int, _distanceY:int;
        private var _callbackMove:Function;     // 블럭을 터치할 때 불려지는 콜백함수 저장
        
        public var isMoving:Boolean = false;
        // 출력 여부
        private var _requiredRedraw:Boolean;    // 블럭이 옮겨진 후 재 출력해야 할지 여부
        
        public function Block()
        {
        }
        
        internal function init(type:uint, texture:Texture, callback:Function):void
        {
            setTexture(texture);
            
            _type = type;
            _callbackMove = callback;
        }
		
        public function setTexture(texture:Texture, x:Number = 0.0, y:Number = 0.0):void
        {
            if( _image == null )
            {
                _image = new Image(texture);
                _image.addEventListener(TouchEvent.TOUCH, onTouch);
                
                _image.x = x;
                _image.y = y;
            }
        }
        
        public function dispose():void
        {
            disposeImage();
            _callbackMove = null;
        }
        
        public function disposeImage():void
        {
            _image.removeEventListener(TouchEvent.TOUCH, onTouch);
            _image = null;
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
							
							if( _distanceX < (event.target as DisplayObject).width * -0.5 )
							{
                                _callbackMove(_row, _col, _row, _col - 1);
                                _isTouch = false;
							}
							else if( _distanceX > (event.target as DisplayObject).width * 0.5 )
							{
                                _callbackMove(_row, _col, _row, _col + 1);
                                _isTouch = false;
							}
							
							if( _distanceY < (event.target as DisplayObject).height * -0.5 )
							{
                                _callbackMove(_row, _col, _row - 1, _col );
                                _isTouch = false;
							}
							else if( _distanceY > (event.target as DisplayObject).height * 0.5)
							{
                                _callbackMove(_row, _col, _row + 1, _col);
                                _isTouch = false;
							}
						}
						break;
					
					case TouchPhase.ENDED :
						_isTouch = false;
                        
                        //debugging
                        if( _image.name == "DEBUGGING" )
                        {
                            BlockManager.instance.debugging(this);
                        }
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
        
        public function get width():uint
        {
            return _image.texture.width;
        }
        
        public function get drawRequired():Boolean
        {
            return _requiredRedraw;
        }
        public function set drawRequired(requiredRedraw:Boolean):void
        {
            _requiredRedraw = requiredRedraw;
        }
    }
}