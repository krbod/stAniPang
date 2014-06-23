
package com.stintern.anipang.utils
{
    import com.greensock.events.LoaderEvent;
    import com.greensock.loading.ImageLoader;
    import com.greensock.loading.LoaderMax;
    
    import flash.display.Bitmap;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.TouchEvent;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    public class UILoader
    {
		// 싱글톤 관련
		private static var _instance:UILoader;
		private static var _creatingSingleton:Boolean = false;
		
		private var _xmlDictionary:Dictionary = new Dictionary();
		private var _textureAtlasDictionary:Dictionary = new Dictionary();
		private var _registrationPointDictionary:Dictionary = new Dictionary(); 
		
		private var _queue:LoaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
		
		private var _onProgressCallback:Function;
		private var _onCompleteCallback:Function;
		
		private var _textureFileNameArray:Array = new Array();
		
		public function UILoader()
		{
			if (!_creatingSingleton){
				throw new Error("[UILoader] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
			}
		}
		
		public static function get instance():UILoader
		{
			if (!_instance){
				_creatingSingleton = true;
				_instance = new UILoader();
				_creatingSingleton = false;
			}
			return _instance;
		}
		
		public function loadAll(atlasFileName:String, container:Sprite, onTouch:Function, x:Number, y:Number):void
		{
			var xml:XML = _xmlDictionary[atlasFileName];
			var namelist:XMLList = xml.child("SubTexture").attribute("name");
			
			var count:uint = namelist.length();
			for(var i:uint=0; i<count; ++i)
			{
				// 스테이지 레이블은 TextField 를 사용
				if( namelist[i].toString().slice(0, 5)  == "label" )
				{
					continue;
				}
				
				container.addChild( loadImage(atlasFileName, namelist[i], onTouch) );
			}
			
			container.x += x;
			container.y += y;
		}
		
		public function loadUISheet(onComplete:Function, onProgress:Function, atlasPaths:Array):void
		{
			_onCompleteCallback = onComplete;
			_onProgressCallback = onProgress;
			
			var count:uint = atlasPaths.length;
			for(var i:uint=0; i<count; ++i)
			{
				var fileName:String = getFileName(atlasPaths[i]);
				var extension:String = (atlasPaths[i] as String).slice(atlasPaths[i].lastIndexOf(".")+1, atlasPaths[i].length);
				if( extension == "xml" )
				{
					_xmlDictionary[fileName] = loadXML(atlasPaths[i]);
				}
				else if( extension == "png" )
				{
					enqueue(atlasPaths[i], fileName);
					_textureFileNameArray.push(fileName);
				}
			}
			
			_queue.load();
		}
		
		public function loadXML(path:String):XML
		{
			var file:File = findFile(path);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			
			var xmlNode:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			return xmlNode;
		}
		
		private function enqueue(path:String, name:String):void
		{
			_queue.append(new ImageLoader(path, {name:name, estimatedBytes:106, container:this, alpha:0, width:1024, height:1024, scaleMode:"proportionalInside"}) );
		}
		
		private function progressHandler(event:LoaderEvent):void 
		{
			if( _onProgressCallback != null )
				_onProgressCallback(event.target.progress);
		}
		
		private function completeHandler(event:LoaderEvent):void 
		{
			var pathCount:uint = _textureFileNameArray.length;
			for(var i:uint=0; i<pathCount; ++i)
			{
				_textureAtlasDictionary[_textureFileNameArray[i]] = new TextureAtlas( Texture.fromBitmap(LoaderMax.getLoader(_textureFileNameArray[i]).rawContent as Bitmap) );

				if( _xmlDictionary[_textureFileNameArray[i]] == null )
				{
					new Error(_textureFileNameArray[i] + "을 가진 XML파일이 없습니다.");
					return;
				}
				
				var xml:XML = (_xmlDictionary[_textureFileNameArray[i]] as XML);
				var xmllist:XMLList = xml.child("SubTexture");
				var nameList:XMLList = xmllist.attribute("name");
				
				var xList:XMLList = xmllist.attribute("x");
				var yList:XMLList = xmllist.attribute("y");
				var widthList:XMLList = xmllist.attribute("width");
				var heightList:XMLList = xmllist.attribute("height");
				
				var registrationXList:XMLList = xmllist.attribute("registrationX");
				var registrationYList:XMLList = xmllist.attribute("registrationY");
				
				var subTextureCount:uint = xml.children().length();
				
				_registrationPointDictionary[_textureFileNameArray[i]] = new Dictionary();
				
				for(var j:uint=0; j<subTextureCount; ++j)
				{
					_textureAtlasDictionary[_textureFileNameArray[i]].addRegion(
						nameList[j],
						new Rectangle(xList[j], yList[j], widthList[j], heightList[j])
					);
					
					_registrationPointDictionary[_textureFileNameArray[i]][nameList[j].toString()] = new Point(registrationXList[j], registrationYList[j]);
				}
				
			}
			
			_textureFileNameArray.length = 0;
			
			_onCompleteCallback();
		}
		
		private function errorHandler(event:LoaderEvent):void 
		{
			trace("error occured with " + event.target + ": " + event.text);
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
		
        public function loadImage(atlasPath:String, name:String, onClick:Function = null):Image
        {
			var textureAtlas:TextureAtlas = _textureAtlasDictionary[atlasPath];
			var texture:Texture = textureAtlas.getTexture(name);
			if( texture == null )
				return null;
						
			var image:Image = new Image(texture);
			image.name = name;
			
			image.x = _registrationPointDictionary[atlasPath][name].x;
			image.y = _registrationPointDictionary[atlasPath][name].y;
			
			if( onClick != null && name.slice(name.lastIndexOf("_")+1, name.length) != "clicked" )
			{
				image.addEventListener(TouchEvent.TOUCH, onClick);
			}
			
			return image;
        }
		
		
		private function getFileName(path:String):String
		{
			return path.slice(path.lastIndexOf("/")+1, path.lastIndexOf("."));
		}
        
        public function getTexture(atlasName:String, textureName:String):Texture
        {
            return _textureAtlasDictionary[atlasName].getTexture(textureName);
        }
        
    }
}