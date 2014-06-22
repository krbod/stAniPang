package com.stintern.anipang
{
	import com.stintern.anipang.worldmapscene.layer.WorldMapScene;
	
	import starling.display.Sprite;
	
	public class SceneManager extends Sprite
	{
		private var _sceneArray:Vector.<Sprite>;
		
		public function SceneManager()
		{
			init(new WorldMapScene);
		}
		
		public function init(firstScene:Sprite):void
		{
			_sceneArray = new Vector.<Sprite>();
			
			pushScene(firstScene);
		}
		
		public function pushScene(scene:Sprite):void
		{
			_sceneArray.push(scene);
			
			addChild(scene);
		}
		
		public function popScene():void
		{
			removeChild(currentScene);
			currentScene.dispose();
			
			_sceneArray.pop();
			
			addChild(currentScene);
		}
		
		public function get currentScene():Sprite
		{
			return _sceneArray[_sceneArray.length-1];
		}
	}
}