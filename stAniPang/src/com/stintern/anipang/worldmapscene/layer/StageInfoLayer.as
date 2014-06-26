package com.stintern.anipang.worldmapscene.layer
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Back;
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.layer.MainGameScene;
    import com.stintern.anipang.scenemanager.SceneManager;
    import com.stintern.anipang.userinfo.UserInfo;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.GrayscaleFilter;
    import com.stintern.anipang.utils.Resources;
    import com.stintern.anipang.utils.UILoader;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.text.TextField;
    import starling.textures.Texture;
    
    public class StageInfoLayer extends Sprite
    {
        private var _isTouched:Boolean;         
        private var _clickedButton:DisplayObject;
        
        private var _container:Sprite;
        
        public function StageInfoLayer()
        {
            super();
            
            init();
        }
        
        public override function dispose():void
        {
            for(var i:uint=0; i<_container.numChildren; ++i)
            {
                _container.getChildAt(i).dispose();
            }
            
            _clickedButton = null;
        }
        
        private function init():void
        {
            _container = new Sprite();
            addChild(_container);
            
            AssetLoader.instance.loadDirectory(onComplete, null, Resources.getAsset(Resources.PATH_DIRECTORY_STAGE_INFO) );
            
            function onComplete():void
            {
                // 현재 스테이지 레벨을 읽음
                var stageLevel:uint = LevelManager.instance.currentStageLevel;
                
                LevelManager.instance.loadStageInfo(stageLevel);
                
                var paths:Array = new Array(
						Resources.getAsset(Resources.PATH_STAGE_INFO_SPRITE_SHEET), 
						Resources.getAsset(Resources.PATH_XML_STAGE_INFO_SHEET));
                
                UILoader.instance.loadUISheet(onLoadUI, null, paths);
            }
        }
        
        private function onLoadUI():void
        {
            // 스테이지 정보 배경 세팅
            var texture:Texture = UILoader.instance.getTexture(Resources.ATALS_NAME_STAGE_INFO, Resources.STAGE_INFO_BACKGROUND_NAME);
            UILoader.instance.loadAll( Resources.ATALS_NAME_STAGE_INFO, _container, onTouch, 0, 0 );
            
            // 스테이지 정보 세팅
            var stageNo:uint = LevelManager.instance.currentStageLevel;
            
            // 별 세팅
            setStar(stageNo);
                        
            // 스테이지 레이블 세팅
            setStageLabel(stageNo, Starling.current.stage.stageWidth * 0.5, Starling.current.stage.stageHeight * 0.5 - texture.height * 0.45);
            
            // 미션세팅
            setMissionLabel(stageNo, Starling.current.stage.stageWidth * 0.5, Starling.current.stage.stageHeight * 0.5 + texture.height * 0.25);
			
			// 스프라이트 컨테이너 애니메이션
			animateSprite();
        }
        
        /**
         * 현재 스테이지의 별 개수(클리어했을 때의 별개수)를 그립니다. 
         */
        private function setStar(stageNo:uint):void
        {
            var starCount:uint = UserInfo.instance.getStarCountAt(stageNo);
            
            for(var i:uint; i<numChildren; ++i)
            {
                var name:String = _container.getChildAt(i).name;
                if( name.slice(0, Resources.STAGE_INFO_STAR.length) == Resources.STAGE_INFO_STAR)
                {
                    var star:uint = uint( name.charAt(name.length-1) );
                    if( star > starCount )
                        _container.getChildAt(i).visible = false;
                }
            }
            
        }
        
        /**
         * 상단에 스테이지 번호를 표시합니다. 
         */
        private function setStageLabel(stageNo:uint, x:Number, y:Number):void
        {
			var textField:TextField = _container.getChildByName(Resources.LABEL_STAGE_LEVEL) as TextField;
			textField.text += stageNo.toString();
			textField.width = textField.textBounds.width + 100;
			textField.height = textField.textBounds.height + 10;
        }
        
        /**
         * 현재 스테이지의 미션을 하단에 표시합니다. 
         */
        private function setMissionLabel(stageNo:uint, x:Number, y:Number):void
        {
            var missionString:String;
            switch( LevelManager.instance.stageInfo.missionType )
            {
                case Resources.MISSION_TYPE_SCORE:
                    missionString = Resources.MISSION_SCORE_HEAD + LevelManager.instance.stageInfo.mission + Resources.MISSION_SCORE_TAIL;
                    break;
                
                case Resources.MISSION_TYPE_ICE:
                    missionString = Resources.MISSION_ICE;
                    break;
            }
			
			var textField:TextField = _container.getChildByName(Resources.LABEL_MISSION) as TextField;
			textField.text = missionString;
			
            textField.fontSize = Starling.current.viewPort.height * 0.02;
			textField.width = textField.textBounds.width + 10;
			textField.height = textField.textBounds.height + 10;
        }
		
		private function animateSprite():void
		{
			_container.scaleX = 0.01;
			_container.scaleY = 0.01;
			
			_container.x = Starling.current.viewPort.width * 0.5;
			_container.y = Starling.current.viewPort.height * 0.5;
			
			_container.pivotX = Starling.current.viewPort.width * 0.5;
			_container.pivotY = Starling.current.viewPort.height * 0.5;
			
			TweenLite.to(_container, 0.5, {scaleX:1.0, scaleY:1.0, ease:Back.easeOut});
		}
        
        public function onTouch( event:TouchEvent ):void
        {
            var touch:Touch = event.getTouch(event.target as DisplayObject);
            if(touch)
            {
                switch(touch.phase)
                {
                    case TouchPhase.BEGAN :
                        _isTouched = true;
                        
                        var object:String = ((event.target as DisplayObject).name ); 
                        if( object == Resources.STAGE_INFO_START_BUTTON || object == Resources.STAGE_INFO_CLOSE_BUTTON )
                        {
                            _clickedButton = event.target as DisplayObject;
                            _clickedButton.visible = false;
                        }
                        break;
                    
                    case TouchPhase.MOVED : 
                        if( !_isTouched )
                            return;
                        
                        break;
                    
                    case TouchPhase.ENDED :
                        _isTouched = false;
                        
                        if( _clickedButton != null && (event.target as DisplayObject).name == _clickedButton.name )
                        {
                            _clickedButton.visible = true;
                            
                            switch( _clickedButton.name )
                            {
                                case Resources.STAGE_INFO_START_BUTTON:
									var mainGameScene:MainGameScene = new MainGameScene();
									mainGameScene.init( onMainGameSceneInited );
									
									function onMainGameSceneInited():void
									{
										(Starling.current.root as SceneManager).replaceScene( mainGameScene );
									}
                                    break;
                                
                                case Resources.STAGE_INFO_CLOSE_BUTTON:
									closeLayer();
                                    break;
                            }
                        }
                        break;
					
                }	// end of switch
            } // end of if(touch)
        }
		
		private function closeLayer():void
		{
			TweenLite.to(_container, 0.5, {scaleX:0.01, scaleY:0.01, onComplete:onCompleteClose, ease:Back.easeIn});
		}
		
		private function onCompleteClose():void
		{
			this.dispose();
			(Starling.current.root as SceneManager).currentScene.removeChild(this);	
			
			((Starling.current.root as SceneManager).currentScene.getChildByName(Resources.LAYER_WORLD_MAP) as WorldMapLayer).setGrayFilter(false);
		}
        
    }
}
