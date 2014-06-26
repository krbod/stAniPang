package com.stintern.anipang.worldmapscene
{
	import starling.display.Sprite;

	public class WorldMapContainer
	{
		private var _size:uint;
		private var _vec:Vector.<Sprite>;
		
		public function WorldMapContainer(size:uint = 5)
		{
			_size = size;
			_vec = new Vector.<Sprite>();
		}
		
		public function dispose():void
		{
			while(_vec.length)
			{
				_vec[0].dispose();
				_vec.shift();
			}
			
			_vec = null;
		}
		
		public function pushBack(sprite:Sprite):void
		{
			if( _vec.length == _size )
			{
				_vec.shift();
			}
			
			_vec.push(sprite);
		}
		
		public function popBack():Sprite
		{
			return _vec.pop();
		}
		
		public function pushFront(sprite:Sprite):void
		{
			if( _vec.length == _size )
				_vec.pop();
			
			_vec.unshift(sprite);
		}
		
		public function popFront():Sprite
		{
			return _vec.shift();
		}
		
		public function getLastSprite():Sprite
		{
			return _vec[_vec.length-1];
		}
		
		public function getSpriteAt(at:uint):Sprite
		{
			return _vec[at];
		}
		
		public function get length():uint
		{
			return _vec.length;
		}
			
	}
}