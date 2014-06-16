package com.stintern.anipang.worldmapscene
{
	import com.stintern.anipang.utils.Resources;

	/**
	 * 월드맵에 대한 정보(각 월드맵 스프라이트 이미지에 들어있는 스테이지, ... )를 포함합니다.
	 */
	public class WorldmapInfo
	{
		private var _eachSpriteEndStage:Vector.<uint>;
		private var _lastStage:uint;
		
		public function WorldmapInfo()
		{
			_lastStage = 0;
			_eachSpriteEndStage = new Vector.<uint>();
		}
		
		public function loadWorldMapInfo(xml:XML):void
		{
			var worldMapSpriteCount:uint = xml.child("spriteCount")[0];
			for(var i:uint=0; i<worldMapSpriteCount; ++i)
			{
				var elementName:String = "worldmap_" + (i+1);
				_eachSpriteEndStage.push( xml.child(elementName).end );
			}
		}
		
		/**
		 * 현재 스테이지 레벨이 있는 스프라이트의 번호(순서)를 리턴합니다. 
		 */
		public function getWorldmapOrder(stage:int):int
		{
			if( stage <= 0 )
				return -1;
			
			var count:uint = _eachSpriteEndStage.length;
			for(var i:uint=0; i<count; ++i)
			{
				if( _lastStage <= _eachSpriteEndStage[i] )
					_lastStage = _eachSpriteEndStage[i];
				
				if( stage <= _eachSpriteEndStage[i] )
					return i+1;
			}
			
			return -1;
		}
		
		/**
		 * 현재 스테이지 레벨이 있는 스프라이트의 경로를 리턴합니다. 
		 * @param stage 확인하고자 하는 스테이지 레빌
		 * @return 스프라이트의 경로 
		 */
		public function getPathByStage(stage:int, isPNG:Boolean):String
		{
			var order:int = getWorldmapOrder(stage);
			if( order == -1 )
				return null;
			
			if( isPNG )
				return getPathByOrder(order, true);
			else
				return getPathByOrder(order, false);
		}
		
		public function getPathByOrder(order:uint, isPNG:Boolean):String
		{
			if( isPNG )
				return Resources.PATH_DIRECTORY_WORLD_MAP + Resources.WORLD_MAP_NAME + order + ".png";
			else
				return Resources.PATH_DIRECTORY_WORLD_MAP + Resources.WORLD_MAP_NAME + order + ".xml";
		}
		
		public function get lastStage():uint
		{
			return _lastStage;
		}
	}
}