package com.stintern.anipang.maingamescene.layer
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.stintern.anipang.SceneManager;
	import com.stintern.anipang.utils.AssetLoader;
	import com.stintern.anipang.utils.Resources;
	import com.stintern.anipang.worldmapscene.layer.WorldMapScene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class MissionClearLayer extends Sprite
	{
		private var _clearImage:Image;
		
		public function MissionClearLayer(isClear:Boolean)
		{
			init(isClear);
		}
		
		public override function dispose():void
		{
			_clearImage.dispose();
			_clearImage = null;
		}
		
		private function init(isClear:Boolean):void
		{
			if( isClear )
				AssetLoader.instance.loadFile(Resources.PATH_IMAGE_MISSION_CLEAR, onComplete);
			else
				AssetLoader.instance.loadFile(Resources.PATH_IMAGE_MISSION_FAILED, onComplete);
			
			function onComplete():void{
				var texture:Texture;
				if( isClear )
					texture = AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_MISSION_CLEAR_TEXTURE_NAME);
				else
					texture = AssetLoader.instance.loadTexture(Resources.PATH_IMAGE_MISSION_FAILED_TEXTURE_NAME);
					
				_clearImage = new Image( texture );
				
				_clearImage.x = Starling.current.stage.stageWidth * 0.5;
				_clearImage.y = Starling.current.stage.stageHeight * 0.5;
				
				_clearImage.pivotX = _clearImage.width * 0.5;
				_clearImage.pivotY = _clearImage.height * 0.5;
				
				_clearImage.scaleX = 0.1;
				_clearImage.scaleY = 0.1;
				
				addChild( _clearImage );
				
				TweenLite.to(_clearImage, 0.5, {scaleX:1, scaleY:1, onComplete:loadWorldMap, ease:Quad.easeOut});
			}
		}
		
		private function loadWorldMap():void
		{
			(Starling.current.root as SceneManager).replaceScene( new WorldMapScene() );
		}
	}
}