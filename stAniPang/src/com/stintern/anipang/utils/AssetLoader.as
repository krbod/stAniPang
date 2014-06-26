package com.stintern.anipang.utils
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.Dictionary;
    
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;

    public class AssetLoader
    {
        // 싱글톤 관련
        private static var _instance:AssetLoader;
        private static var _creatingSingleton:Boolean = false;
        
        private var imgDictionary:Dictionary = new Dictionary();
		
		private var _assetManager:AssetManager;
        private var _scaleFactor:int;
        
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
		
		public function init(scaleFactor:int):void
		{
            _assetManager = new AssetManager();
            _scaleFactor = scaleFactor;
		}
		
		public function loadDirectory(onComplete:Function, onProgress:Function, ...dirs):void
		{
			for(var i:uint=0; i<dirs.length; ++i)
			{
				var appDir:File;
				if( File.applicationDirectory.resolvePath(dirs[i]).exists )
				{
					appDir = File.applicationDirectory;
				}
				else if( File.applicationStorageDirectory.resolvePath(dirs[i]).exists )
				{
					appDir = File.applicationStorageDirectory;
				}
				_assetManager.enqueue(appDir.resolvePath(dirs[i]));	
			}
			
			_assetManager.loadQueue(function (ratio:Number):void
			{
				if ( ratio == 1 )
				{
					onComplete();
				}
				else
				{
                    trace(ratio);
					if( onProgress != null )
						onProgress(ratio);	
				}
				
			});
		}
		
		public function loadFile(filePath:String, onComplete:Function, onProgress:Function = null ):void
		{
			var file:File = File.applicationDirectory.resolvePath(filePath);
			_assetManager.enqueue(file);
			_assetManager.loadQueue(function (ratio:Number):void
			{
				if ( ratio == 1 )
				{
					onComplete();
				}
				else
				{
					trace(ratio);
					if( onProgress != null )
						onProgress(ratio);	
				}
				
			});
		}
		
		public function loadTextureAtlas(fileName:String):TextureAtlas
		{
			return _assetManager.getTextureAtlas(fileName);
		}
		
		public function loadTexture(fileName:String):Texture
		{
			return _assetManager.getTexture(fileName);
		}
			
		public function loadXML(fileName:String):XML
		{
			return _assetManager.getXml(fileName);
		}
        
        public function loadXMLDirectly(path:String):XML
        {
            var file:File = findFile(path);
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            
            var xmlNode:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            return xmlNode;
        }
        
        public function removeTexture(name):void
        {
            _assetManager.removeTexture(name);
        }
        
        /**
         * 디바이스 내부 저장소를 확인하여 File 객체를 리턴합니다. 
         */
        private function findFile(path:String):File
        {
			file = File.applicationStorageDirectory.resolvePath(path);
			if( file.exists )
				return file;
			
            var file:File = File.applicationDirectory.resolvePath(path);
            if( file.exists )
                return file;
            
            return null;
        }
        
        public function get scaleFactor():int
        {
            return _scaleFactor;
        }
        
        
    }
}