package com.stintern.anipang.startscene
{
    import com.dynamicflash.util.Base64;
    import com.greensock.events.LoaderEvent;
    import com.greensock.loading.LoaderMax;
    import com.stintern.ane.BackButtonANE;
    import com.stintern.ane.FacebookANE;
    import com.stintern.ane.events.ANEResultEvent;
    import com.stintern.anipang.scenemanager.SceneManager;
    import com.stintern.anipang.userinfo.UserInfo;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.LoadingLayer;
    import com.stintern.anipang.utils.Resources;
    import com.stintern.anipang.worldmapscene.layer.WorldMapScene;
    
    import flash.desktop.NativeApplication;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.ui.Keyboard;
    import flash.utils.ByteArray;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;
    
    public class StartScene extends Sprite
    {
        private var _loginImage:Image;
        private var _loginImageClicked:Image;
        
        private var _facebookANE:FacebookANE;
		private var _backButtonANE:BackButtonANE;
		
		private var _loadingSprite:LoadingLayer;
        
        public function StartScene()
        {
            init();
        }
        
        public override function dispose():void
        {
            for(var i:uint=0; i<numChildren; ++i)
            {
                getChildAt(i).dispose();
                getChildAt(i).removeEventListener(TouchEvent.TOUCH, onTouch);
            }
            
            AssetLoader.instance.removeTexture(Resources.PATH_IMAGE_START_SCENE_BACKGROUND_TEXTURE_NAME);
            AssetLoader.instance.removeTexture(Resources.PATH_IMAGE_FACEBOOK_LOGIN_TEXTURE_NAME);
            AssetLoader.instance.removeTexture(Resources.PATH_IMAGE_FACEBOOK_LOGIN_CLICKED_TEXTURE_NAME);
			
			_facebookANE.removeEventListener(ANEResultEvent.EVENT_USER_IMAGE, onUserImageLoaded);
			_facebookANE.removeEventListener(ANEResultEvent.EVENT_USER_NAME, onUserNameLoaded);
        }
        
        private function init():void
        {
            // Facebook 관련 초기화
            _facebookANE = new FacebookANE();
            _facebookANE.addEventListener(ANEResultEvent.EVENT_USER_IMAGE, onUserImageLoaded);
            _facebookANE.addEventListener(ANEResultEvent.EVENT_USER_NAME, onUserNameLoaded);
            
            // 배경화면 및 버튼 초기화
            initUI();
            
			_backButtonANE = new BackButtonANE();
            NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
    
        private function onKeyDown(event:KeyboardEvent):void
        {
            if( event.keyCode == Keyboard.BACK )
            {
                event.preventDefault();
                event.stopImmediatePropagation();
				
				_backButtonANE.callEndDialog();
            }
        }
        
        private function onUserImageLoaded(event:ANEResultEvent):void
        {
            var decodedArray:ByteArray = Base64.decodeToByteArray(event.aneResult);
            
            var loader:Loader = new Loader();
            loader.loadBytes(decodedArray);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
        }
        
        /**
         * 이미지 byte array 를 읽은 후 불려지는 함수입니다. 
         */
        private function onComplete(event:Event):void
        {
            var loaderInfo:LoaderInfo = LoaderInfo(event.target);
            var bitmapData:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height, false, 0xFFFFFF);
            bitmapData.draw(loaderInfo.loader);
            
            var userImage:Bitmap = new Bitmap();
            
            // 다른 이미지가 있을 경우 삭제
            if( userImage.bitmapData != null )
            {
                userImage.bitmapData.dispose();
            }
            
            userImage.bitmapData = bitmapData;
            UserInfo.instance.userImage = Image.fromBitmap(userImage);
            
            // 월드맵 씬으로 전환
			var worldMapScene:WorldMapScene = new WorldMapScene();
			worldMapScene.init(onInited);
			
			function onInited():void
			{
				_loadingSprite.stop();
				(Starling.current.root as SceneManager).replaceScene(worldMapScene);
			}
        }
        
        private function onUserNameLoaded(event:ANEResultEvent):void
        {
            UserInfo.instance.userName = event.aneResult;
        }
        
		/**
		 * UI 를 초기화합니다. 
		 */
        private function initUI():void
        {
            AssetLoader.instance.loadDirectory(onComplete, null, Resources.getAsset(Resources.PATH_DIRECTORY_START_SCENE));        
            
            function onComplete():void
            {
                var texture:Texture = AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_START_SCENE_BACKGROUND_TEXTURE_NAME);
                var bkgImage:Image = new Image(texture);
                bkgImage.width = Starling.current.viewPort.width;
                bkgImage.height = Starling.current.viewPort.height;
                bkgImage.addEventListener(TouchEvent.TOUCH, onTouch);          
                addChild(bkgImage);
                
                _loginImage = new Image(AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_FACEBOOK_LOGIN_TEXTURE_NAME));
                _loginImage.x = Starling.current.stage.stageWidth * 0.5 - _loginImage.texture.width * 0.5;
                _loginImage.y = Starling.current.stage.stageHeight * 0.8;
                _loginImage.addEventListener(TouchEvent.TOUCH, onTouch);                
                addChild(_loginImage);
                
                _loginImageClicked = new Image(AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_FACEBOOK_LOGIN_CLICKED_TEXTURE_NAME));
                _loginImageClicked.x = Starling.current.stage.stageWidth * 0.5 - _loginImageClicked.texture.width * 0.5;
                _loginImageClicked.y = Starling.current.stage.stageHeight * 0.8;
                addChild(_loginImageClicked);
                _loginImageClicked.visible = false;
            }
        }
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(event.target as DisplayObject);
            if(touch)
            {
                switch(touch.phase)
                {
                    case TouchPhase.BEGAN :
                        if( event.target == _loginImage )
                        {
                            _loginImageClicked.visible = true;
                        }
                        break;
                    
                    case TouchPhase.MOVED : 
                        break;
                    
                    case TouchPhase.ENDED :
                        if( event.target == _loginImage )
                        {
							// 로딩 화면을 활성화
							_loadingSprite = new LoadingLayer();
							_loadingSprite.init(onInited);
							function onInited():void
							{
								addChild(_loadingSprite);
								_loadingSprite.start();
								
								_facebookANE.getUserInfo();
							}
							
							
                        }
                        
                        _loginImageClicked.visible = false;
                        break;
                }
            }
        }
        
        
        private function progressHandler(event:LoaderEvent):void 
        {
        }
        
        private function completeHandler(event:LoaderEvent):void 
        {
                var texture:Texture = Texture.fromBitmap(LoaderMax.getLoader(Resources.PATH_IMAGE_START_SCENE_BACKGROUND_TEXTURE_NAME).rawContent as Bitmap);
                trace(texture.width);
        }
        
        private function errorHandler(event:LoaderEvent):void 
        {
            trace("error occured with " + event.target + ": " + event.text);
        }

    }
}