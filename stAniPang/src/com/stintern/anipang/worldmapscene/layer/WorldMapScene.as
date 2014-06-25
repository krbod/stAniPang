package com.stintern.anipang.worldmapscene.layer
{
	import com.stintern.anipang.userinfo.UserInfo;
	import com.stintern.anipang.utils.AssetLoader;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.WorldmapInfo;
	
	import starling.display.Sprite;
	
	public class WorldMapScene extends Sprite
	{
		private var _worldMapInfo:WorldmapInfo;
		private var _worldMapLayer:WorldMapLayer;
		
		public function WorldMapScene()
		{
			this.name = Resources.SCENE_WORLD_MAP;
		}
		
		public override function dispose():void
		{
			for(var i:uint=0; i<numChildren; ++i)
            {
                getChildAt(i).dispose();
            }
		}
		
		public function init(onInited:Function = null):void
		{
			// 월드맵에 대한 정보를 로드
			_worldMapInfo = new WorldmapInfo();
			_worldMapInfo.loadWorldMapInfo( AssetLoader.instance.loadXMLDirectly(Resources.XML_WORLD_MAP_INFO) );
			
			// 현재 사용자의 스테이지 클리어 정보를 로드
			loadUserInfo();
			
			// 사용자의 정보를 바탕으로 월드맵을 출력
			// 사용자 스테이지에 맞는 이미지 상 하 2 개씩 미리 로드 해둠 
			var paths:Array = preLoad( UserInfo.instance.currentStage );
			
			UILoader.instance.loadUISheet(onComplete, onProgress, paths);
			function onComplete():void
			{
				// 마지막 스테이지의 번호를 넘겨서 월드맵을 옮길 때 더이상 넘어가지 않도록 제한
				var lastStagePath:String = _worldMapInfo.getPathByStage( _worldMapInfo.lastStage, true );
				var lastStageOrder:uint = uint(lastStagePath.slice(lastStagePath.lastIndexOf("_")+1, lastStagePath.lastIndexOf(".")));
				_worldMapLayer = new WorldMapLayer(
					paths, 				// 월드맵을 구성할 미리로드한 이미지
					_worldMapInfo,		  // 현재 화면에 출력할 월드맵 이미지 번호
					lastStageOrder,		// 마지막 스테이지의 이미지 번호
					onInited
				);
				addChild(_worldMapLayer);
			}
			function onProgress(ratio:Number):void
			{
				trace(ratio);
			}
		}
		
		private function loadUserInfo():void
		{
			UserInfo.instance.init();
			UserInfo.instance.loadUserInfo( AssetLoader.instance.loadXMLDirectly(Resources.XML_USER_INFO) );
		}
		
		private function preLoad(stageNo:uint):Array
		{
			var paths:Array = new Array();
			
			var order:uint = _worldMapInfo.getWorldmapOrder( stageNo );
			var lastOrder:uint = _worldMapInfo.getWorldmapOrder( _worldMapInfo.lastStage );
			
			// 앞 뒤로 2개씩 미리 로드
			for(var i:int=order-2; i<=order+2; ++i)
			{
				if( i <= 0 )
					continue;
				
				// 마지막 월드맵을 넘어서면 더이상 삽입 X 
				if( i > lastOrder )
					break;
				
				paths.push( _worldMapInfo.getPathByOrder( i, true ) );
				paths.push( _worldMapInfo.getPathByOrder( i, false ) );
			}
			
			return paths;
		}
		
	}
}