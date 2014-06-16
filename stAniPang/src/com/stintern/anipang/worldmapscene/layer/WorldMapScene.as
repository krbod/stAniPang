package com.stintern.anipang.worldmapscene.layer
{
	import com.stintern.anipang.userinfo.UserInfo;
	import com.stintern.anipang.utils.AssetLoader;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.WorldmapInfo;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class WorldMapScene extends Sprite
	{
		private var _worldMapInfo:WorldmapInfo;
		private var _worldMapLayer:WorldMapLayer;
		
		public function WorldMapScene()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init( event:Event ):void
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
				_worldMapLayer = new WorldMapLayer();
				addChild(_worldMapLayer);
				
				var fileName:String = (paths[0] as String).slice(paths[0].lastIndexOf("/")+1, paths[0].lastIndexOf("."));;
				_worldMapLayer.onImageLoaded( fileName );
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
			
			// 현재 화면에 출력해야할 스프라이트 경로를 제일 먼저 저장
			paths.push( _worldMapInfo.getPathByStage( stageNo, true ) );
			paths.push( _worldMapInfo.getPathByStage( stageNo, false ) );
			
			var order:uint = _worldMapInfo.getWorldmapOrder( stageNo );
			var lastOrder:uint = _worldMapInfo.getWorldmapOrder( _worldMapInfo.lastStage );
			
			// 앞 뒤로 2개씩 미리 로드
			for(var i:int=order-2; i<=order+2; ++i)
			{
				if( i <= 0 || i == order)
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