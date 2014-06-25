package com.stintern.anipang.worldmapscene.layer
{
	import com.stintern.ane.FacebookANE;
	import com.stintern.anipang.userinfo.UserInfo;
	import com.stintern.anipang.utils.AssetLoader;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.utils.UILoader;
	import com.stintern.anipang.worldmapscene.TouchManager;
	import com.stintern.anipang.worldmapscene.WorldmapInfo;
	
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class WorldMapLayer extends Sprite
	{
		private var _touchManager:TouchManager;
		private var _worldContainer:Sprite;
		
		private var _container:Vector.<Sprite>;
		
		private var _startPoint:int;
		private var _endPoint:int;
		
		private var _worldMapInfo:WorldmapInfo;
		private var _userImage:Image;
		
		private var _inviteButton:Image;
		
		public function WorldMapLayer(preloadImagePaths:Array, worldMapInfo:WorldmapInfo, lastStageOrder:uint, onInited:Function = null )
		{
			this.name = Resources.LAYER_WORLD_MAP;
			
			_worldMapInfo = worldMapInfo;
			
			init(preloadImagePaths, _worldMapInfo.getWorldmapOrder( UserInfo.instance.currentStage), lastStageOrder, onInited);
		}
		
		private function init(preloadImagePaths:Array, currentStageOrder:uint, lastStageOrder:uint, onInited:Function = null):void
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
			
			// 클리어한 스테이지는 회색 스테이지 버튼을 Invisible
			initStageButton();
			
			initConnectingHeart();
			
			// 사용자의 이미지를 출력
			displayUserImage(onInited);
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
		
		/**
		 * 클리어한 버튼은 활성화상태로 두고 아직 클리어하지 못한 스테이지는
		 * 버튼을 비활성화 상태로 둡니다. 
		 */
		private function initStageButton():void
		{
			var currentStage:uint = UserInfo.instance.currentStage;
			for(var i:uint=1; i<=currentStage; ++i)
			{
				var image:DisplayObject = getChildByName(_worldContainer, "Button_Unclear_" + i );
				image.visible = false;
			}
		}
		
		/**
		 * 부모 Sprite 객체로 부터 자식까지 name 을 가진 객체를 찾아 리턴합니다.  
		 */
		private function getChildByName(parent:Sprite, name):DisplayObject
		{
			if( parent == null )
				return null;
			
			var displayObject:DisplayObject = parent.getChildByName(name);
			if( displayObject == null )
			{
				var childrenCount:uint = parent.numChildren;
				for(var i:uint=0; i<childrenCount; ++i)
				{
					var object:DisplayObject = getChildByName(( parent.getChildAt(i) as Sprite), name);
					if( object != null )
						return object;
				}
				return null;
			}
			else
			{
				return displayObject;
			}
		}
		
		private function initConnectingHeart():void
		{
			var currentStage:uint = UserInfo.instance.currentStage;
			var lastStage:uint = _worldMapInfo.lastStage;
			for(var i:uint=currentStage; i<lastStage; ++i)
			{
				for(var j:uint=1; ; ++j)
				{
					var image:DisplayObject = getChildByName(_worldContainer, "connecting_heart_" + i + "_" + j );
					if( image == null )
						break;
					
					image.visible = false;
				}
			}
		}
		
		private function displayUserImage(onInited:Function = null):void
		{
			if( UserInfo.instance.userImage == null )
			{
				if( onInited != null )
					onInited();
				
				return;
			}
			
			var currentStage:uint = UserInfo.instance.currentStage;
			var order:uint = _worldMapInfo.getWorldmapOrder(currentStage);
			
			var pos:Point = UILoader.instance.getTexturePosition("worldmap_" + order, "Button_" + currentStage);
			_userImage = UserInfo.instance.userImage;
			
			AssetLoader.instance.loadFile(Resources.getAsset(Resources.IMAGE_USER_PICTURE_BOUND), onComplete);
			
			function onComplete():void
			{
				var pictureBound:Image = new Image( AssetLoader.instance.loadTexture(Resources.IMAGE_USER_PICTURE_BOUND_TEXTURE_NAME) );
				pictureBound.x = pos.x + pictureBound.width * 1.5;
				pictureBound.y = pos.y;
				
				pictureBound.pivotX = pictureBound.texture.width * 0.5;
				
				_userImage.x = pictureBound.x
				_userImage.y = pictureBound.y + pictureBound.height * 0.15;
				
				_userImage.width = pictureBound.width * 0.7;
				_userImage.height = pictureBound.height * 0.7;
				
				_userImage.pivotX = _userImage.texture.width * 0.5;
				
				_worldContainer.addChild(pictureBound);
				_worldContainer.addChild(_userImage);
				
				pos = null;
				
				// 페이스북 초대 버튼 초기화
				displayInviteButton(onInited);
			}
		}
		
		private function displayInviteButton(onInited:Function = null):void
		{
			AssetLoader.instance.loadFile(Resources.getAsset(Resources.IMAGE_FACEBOOK_INVITE), onComplete);
			
			function onComplete():void
			{
				var invite:Image = new Image( AssetLoader.instance.loadTexture(Resources.IMAGE_FACEBOOK_INVITE_TEXTURE_NAME) );
				invite.pivotX = invite.texture.width;
				
				invite.x = Starling.current.stage.stageWidth - 10;
				invite.y = 10;
				
				invite.addEventListener(TouchEvent.TOUCH, onInviteTouched)
				
				addChild(invite);
				
				if( onInited != null )
					onInited();
			}
		}
		
		private function onInviteTouched(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(event.target as DisplayObject);
			if(touch)
			{
				switch(touch.phase)
				{
					case TouchPhase.ENDED :
						var facebookANE:FacebookANE = new FacebookANE();
						facebookANE.inviteFriends();
						break;
				}
			}
		}
			
	}
}
