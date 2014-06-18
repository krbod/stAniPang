package com.stintern.anipang.worldmapscene.layer
{
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.TouchManager;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	
	public class WorldMapLayer extends Sprite
	{
		private var _touchManager:TouchManager;
		private var _worldContainer:Sprite;
		
		private var _container:Vector.<Sprite>;
		
		private var _startPoint:int;
		private var _endPoint:int;
		
		public function WorldMapLayer(preloadImagePaths:Array, currentStageOrder:uint, lastStageOrder:uint )
		{
			this.name = Resources.LAYER_WORLD_MAP;
			
			init(preloadImagePaths, currentStageOrder, lastStageOrder);
		}
		
		private function init(preloadImagePaths:Array, currentStageOrder:uint, lastStageOrder:uint):void
		{
			_worldContainer = new Sprite();
			addChild(_worldContainer);
			
			_container = new Vector.<Sprite>();
			_touchManager = new TouchManager(onTouchMove);
			
			// 화면 중앙에 위치해야할 이미지의 번호와 미리 로드한 이미지들 가운데 맨 아래에 위치하는 이미지 번호와의 간격을 계산해서
			// 이미지들을 어디서부터 출력해야 할지를 계산해서 이미지를 출력
			var firstImageorder:uint = uint(preloadImagePaths[0].slice(preloadImagePaths[0].lastIndexOf("_")+1, preloadImagePaths[0].lastIndexOf(".")));
			var diff:int = currentStageOrder - firstImageorder;
			loadImages(preloadImagePaths, diff*Starling.current.stage.stageHeight);
			
			// 맨 아랫부분과 윗부분의 좌표를 저장후 더이상 안 움직이도록 제한
			_startPoint = (1-currentStageOrder) * Starling.current.stage.stageHeight;
			_endPoint = (lastStageOrder - currentStageOrder) * Starling.current.stage.stageHeight;
		}
		
		/**
		 * 월드맵 스프라이트 시트 이미지들을 로드해서 화면에 출력합니다. 
		 * @param paths 로드할 월드맵 스프라이트 시트 경로
		 * @param startPosition Array[0:png], [1:xml] 에 있는 이미지가 출력될 Y 좌표 
		 */
		private function loadImages(paths:Array, startPosition:int):void
		{
			var imageCount:uint = paths.length / 2;
			for(var i:uint=0; i<imageCount; ++i)
			{
				var fileName:String = (paths[i*2] as String).slice(paths[i*2].lastIndexOf("/")+1, paths[0].lastIndexOf("."));
				
				loadImage( fileName, 0, startPosition - Starling.current.stage.stageHeight * i);
			}
		}
		
		/**
		 * 스프라이트 시트에 있는 이미지들을 모두 로드해서 화면에 출력합니다. 
		 */
		public function loadImage( flieName:String, x:Number, y:Number ):void
		{
			var sprite:Sprite = new Sprite();
			UILoader.instance.loadAll(flieName, sprite, _touchManager.onTouch, x, y);
			
			_worldContainer.addChild(sprite);
			_container.push(sprite);
		}
		
		private function onTouchMove(distance:int):void
		{
			// 맨 아랫부분
			if( _startPoint > _worldContainer.y + distance )
			{
				_worldContainer.y = _startPoint
			}
			// 맨 윗부분
			else if( _endPoint < _worldContainer.y + distance )
			{
				_worldContainer.y = _endPoint
			}
			else
			{
				_worldContainer.y += distance;
			}
		}
		
	}
}