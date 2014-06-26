package com.stintern.anipang.utils
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;

	public class LoadingLayer extends Sprite
	{
		private var _loadingImage:Image;
		private var _requiredStop:Boolean;
		
		{
		public function LoadingLayer()
		}
		public override function dispose():void
		{
			_loadingImage.dispose();
			_loadingImage = null;
		}
		
		public function init(onInited:Function):void
		{
			_requiredStop = false;
			AssetLoader.instance.loadFile(Resources.getAsset(Resources.PATH_IMAGE_LOADING), onComplete);
			
			function onComplete():void
			{
				_loadingImage = new Image( AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_LOADING_TEXTURE_NAME) );
				_loadingImage.x = Starling.current.viewPort.width * 0.5;
				_loadingImage.y = Starling.current.viewPort.height * 0.5;
				
				_loadingImage.pivotX = _loadingImage.width * 0.5;
				_loadingImage.pivotY = _loadingImage.height * 0.5;

				
				addChild(_loadingImage);
				
				onInited();
			}
		}
		
		public function start():void
		{
			if( !_requiredStop )
				TweenLite.to(_loadingImage, 1.0, {rotation:_loadingImage.rotation + 10 , onComplete:start, ease:Linear.easeNone});
		}
		
		public function stop():void
		{
			_requiredStop = true;
		}
	}
}