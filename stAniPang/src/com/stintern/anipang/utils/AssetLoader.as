package com.stintern.anipang.utils
{
    import com.greensock.events.LoaderEvent;
    import com.greensock.loading.ImageLoader;
    import com.greensock.loading.LoaderMax;
    
    import flash.display.Bitmap;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;

    public class AssetLoader
    {
        // 싱글톤 관련
        private static var _instance:AssetLoader;
        private static var _creatingSingleton:Boolean = false;
        
        public static var TEXTURE_CUBE_0:String = "res/texture/texture0.png";
        public static var TEXTURE_CUBE_1:String = "res/texture/texture1.png";
        
        private var imgDictionary:Dictionary = new Dictionary();
        
        public function AssetLoader()
        {
            if (!_creatingSingleton){
                throw new Error("[AssetLoader] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():AssetLoader
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new AssetLoader();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        public function loadXML(path:String):XML
        {
            var file:File = findFile(path);
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            
            var xmlNode:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            return xmlNode;
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
        
        
        public function loadTexture(path:Array, onComplete:Function, onProgress:Function = null):void
        {
            var queue:LoaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
            
            var pathCount:uint = path.length;
            for(var i:uint=0; i<pathCount; ++i)
            {
                queue.append(new ImageLoader(path[i], {name:path[i], estimatedBytes:106, container:this, alpha:0, width:512, height:256, scaleMode:"proportionalInside"}) );
            }
            
            queue.load();
            
            function progressHandler(event:LoaderEvent):void 
            {
                if( onProgress != null )
                    onProgress(event.target.progress);
            }
            
            function completeHandler(event:LoaderEvent):void 
            {
                for(var i:uint=0; i<pathCount; ++i)
                {
                    imgDictionary[path[i]] = LoaderMax.getLoader(path[i]).rawContent;
                }
                
                onComplete();
            }
            
            function errorHandler(event:LoaderEvent):void 
            {
                trace("error occured with " + event.target + ": " + event.text);
            }
        }
        
        public function getTextureBitmap(imagePath:String):Bitmap
        {
            return imgDictionary[imagePath] as Bitmap;
        }
        
    }
}