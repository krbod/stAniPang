package com.stintern.anipang.maingamescene.layer
{
	import com.stintern.anipang.utils.AssetLoader;
	import com.stintern.anipang.utils.Resources;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class BkgLayer extends Sprite
	{
		private var _bkgImage:Image;
		
		public function BkgLayer()
		{
			super();
		}
		
		public function init(onInited:Function):void
		{
			AssetLoader.instance.loadFile(Resources.getAsset(Resources.PATH_BACKGROUND_ON_MAIN_GAME), onComplete);
			
			function onComplete():void
			{
				_bkgImage = new Image( AssetLoader.instance.loadTexture(Resources.PATH_BACKGROUND_ON_MAGIN_GAME_TEXTURE_NAME) );
				
				_bkgImage.width = Starling.current.viewPort.width;
				_bkgImage.height = Starling.current.viewPort.height;
				
				addChild(_bkgImage);
				
				onInited();
			}
		}
			
	}
}