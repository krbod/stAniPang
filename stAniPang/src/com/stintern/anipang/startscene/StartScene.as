package com.stintern.anipang.startscene
{
    import com.dynamicflash.util.Base64;
    import com.greensock.events.LoaderEvent;
    import com.greensock.loading.LoaderMax;
    import com.stintern.ane.FacebookANE;
    import com.stintern.ane.events.ANEResultEvent;
    import com.stintern.anipang.SceneManager;
    import com.stintern.anipang.userinfo.UserInfo;
    import com.stintern.anipang.utils.AssetLoader;
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
        }
        
        private function init():void
        {
            // Facebook 관련 초기화
            _facebookANE = new FacebookANE();
            _facebookANE.addEventListener(ANEResultEvent.EVENT_USER_IMAGE, onUserImageLoaded);
            _facebookANE.addEventListener(ANEResultEvent.EVENT_USER_NAME, onUserNameLoaded);
            
            // 배경화면 및 버튼 초기화
            initComponents();
            
            NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
        }
    
        private function onKeyDown(event:KeyboardEvent):void
        {
            if( event.keyCode == Keyboard.BACK )
            {
                event.preventDefault();
                event.stopImmediatePropagation();
                
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
            (Starling.current.root as SceneManager).replaceScene(new WorldMapScene());
        }
        
        private function onUserNameLoaded(event:ANEResultEvent):void
        {
            UserInfo.instance.userName = event.aneResult;
        }
        
        private function initComponents():void
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
                            _facebookANE.getUserInfo();
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
        
        private function loadTexture(path:String, onComplete:Function, onProgress=null ):void
        {
            var file:File = findFile(path);
            var fileStream:FileStream = new FileStream(); 
            fileStream.open(file, FileMode.READ);
            
            var bytes:ByteArray = new ByteArray();
            fileStream.readBytes(bytes);
            
            fileStream.close();
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.loadBytes(bytes);
            
            function onLoaderProgress(event:ProgressEvent):void
            {
                trace(event.bytesLoaded/event.bytesTotal * 100);
                if( onProgress != null )
                {
                    onProgress(event.bytesLoaded/event.bytesTotal * 100);
                }
            }
            
            function onLoaderComplete(event:Event):void
            {
                trace("onLoaderComplete : " + path);
                
                //_assetMap[path] = LoaderInfo(event.target).content as Bitmap;
                
                onComplete( LoaderInfo(event.target).content as Bitmap );
            }
            
            function ioErrorHandler(event:IOErrorEvent):void
            {
                trace("Image Load error: " + event.target + " _ " + event.text );                  
            }
        }
        
        
        /**
         * 디바이스 내부 저장소를 확인하여 File 객체를 리턴합니다. 
         */
        private function findFile(path:String):File
        {
            var file:File = File.applicationDirectory.resolvePath(path);
            if( file.exists )
                return file;
            
            file = File.applicationStorageDirectory.resolvePath(path);
            if( file.exists )
                return file;
            
            return null;
        }

    }
}