package com.stintern.anipang.maingamescene.layer
{
    import com.greensock.TweenLite;
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.block.BlockManager;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.GameFont;
    import com.stintern.anipang.utils.Resources;
    import com.stintern.anipang.utils.UILoader;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.utils.HAlign;
    
    public class PanelLayer extends Sprite
    {
        private var _isTouched:Boolean;         
        private var _clickedButton:String = "";
        
        private var _container:Sprite;
		private var _currentScore:uint;
		private var _missionLeft:int;
		
		private var _tfdLeftStep:TextField;
		private var _tfdCurrentScore:TextField;
		private var _tfdMission:TextField;
        private var _tfdStageLabel:TextField;
        
		private var _onInitedCallback:Function;
		
        public function PanelLayer()
        {
            this.name = Resources.LAYER_PANEL;
        }
        
        public function init(onInited:Function):void
        {
			_onInitedCallback = onInited;
			
            _container = new Sprite();
            addChild(_container);
            
            AssetLoader.instance.loadDirectory(onComplete, null, Resources.getAsset(Resources.PATH_DIRECTORY_PANEL));
            function onComplete():void
            {
                // 현재 스테이지 레벨을 읽음
                var stageLevel:uint = LevelManager.instance.currentStageLevel;
                
                LevelManager.instance.loadStageInfo(stageLevel);
                
                var paths:Array = new Array(
                    Resources.getAsset(Resources.PATH_PANEL_SPRITE_SHEET), 
					Resources.getAsset(Resources.PATH_XML_PANEL_SHEET));
                
                UILoader.instance.loadUISheet(onLoadUI, null, paths);
            }
        }
        
        private function onLoadUI():void
        {
            // 스테이지 정보 배경 세팅
            UILoader.instance.loadAll(Resources.ATALS_NAME_PANEL, _container, onTouch, 0, 0);
            
			// 남은 이동 텍스트 필드 초기화
			initLeftStepCount();
			
			// 현재 점수 텍스트필드 초기화
			initCurrentScore();
			
			// 미션 정보필드 초기화
			initMissionInfo();
            
            // 하단에 현재 스테이지 표시
            initStageLabel();
			
			_onInitedCallback();
        }
        
		private function initLeftStepCount():void
		{
			var leftStep:uint = LevelManager.instance.stageInfo.moveLimit;
			
			_tfdLeftStep = _container.getChildByName(Resources.LABEL_LEFT_STEP) as TextField;
			_tfdLeftStep.text = leftStep.toString();
			
			_tfdLeftStep.fontSize = Starling.current.viewPort.height * 0.03;
			_tfdLeftStep.width = _tfdLeftStep.textBounds.width + 10;
			_tfdLeftStep.height = _tfdLeftStep.textBounds.height + 10;
		}
		
		public function updateLeftStep(leftStep:int):void
		{
			_tfdLeftStep.text = leftStep.toString();
		}
			
		
		private function initCurrentScore():void
		{
			_tfdCurrentScore = _container.getChildByName(Resources.LABEL_SCORE) as TextField;
			_tfdCurrentScore.text = "0";
			_tfdCurrentScore.fontSize = Starling.current.viewPort.height * 0.03;
			_tfdCurrentScore.width = _tfdCurrentScore.textBounds.width + 100;
			_tfdCurrentScore.height = _tfdCurrentScore.textBounds.height + 10;
		}
		
		public function updateCurrentScore():void
		{
			_currentScore += 200;
			_tfdCurrentScore.text = _currentScore.toString();
			
			_tfdCurrentScore.width = _tfdCurrentScore.textBounds.width + 100;
			_tfdCurrentScore.height = _tfdCurrentScore.textBounds.height + 10;
		}
		
		private function initMissionInfo():void
		{
			var missionType:String = LevelManager.instance.stageInfo.missionType;
			var mission:uint = LevelManager.instance.stageInfo.mission;
			
			switch(missionType)
			{
				case Resources.MISSION_TYPE_SCORE:
					
					_tfdMission = _container.getChildByName(Resources.LABEL_MISSION_STRING) as TextField;
					_container.getChildByName(Resources.LABEL_MISSION_BLOCK).visible = false;
					
					_tfdMission.text = Resources.MISSION_SCORE_HEAD + mission.toString() + Resources.MISSION_SCORE_TAIL;
					_tfdMission.fontSize = Starling.current.viewPort.height * 0.015;
					break;
				
				case Resources.MISSION_TYPE_ICE:
					_tfdMission = _container.getChildByName(Resources.LABEL_MISSION_BLOCK) as TextField;
					_container.getChildByName(Resources.LABEL_MISSION_STRING).visible = false;
					
					_tfdMission.text = "x" + mission.toString();
					_tfdMission.fontSize = Starling.current.viewPort.height * 0.02;
					
					_missionLeft = mission;
					
					var texture:Texture = BlockManager.instance.blockPainter.getTextureByType(GameBoard.TYPE_OF_CELL_ICE);
					var image:Image = new Image(texture);
					image.x = _tfdMission.x - image.texture.width - 10
					image.y = _tfdMission.y - image.texture.height * 0.3;
					_container.addChild(image);
					
					break;
			}
			
			_tfdMission.width = _tfdMission.textBounds.width + 10;
			_tfdMission.height = _tfdMission.textBounds.height + 10;
		}
		
		public function updateLeftIce():void
		{
			--_missionLeft;
			_tfdMission.text = "x" + _missionLeft.toString();
		}
        
        private function initStageLabel():void
        {
            var currentStage:uint = LevelManager.instance.currentStageLevel;
			
			_tfdStageLabel = _container.getChildByName(Resources.LABEL_STAGE_LEVEL_ON_PANEL) as TextField;
                
			_tfdStageLabel.text += currentStage.toString();
			_tfdStageLabel.fontSize = Starling.current.viewPort.height * 0.04;
			
            _tfdStageLabel.width = _tfdStageLabel.textBounds.width + 10;
            _tfdStageLabel.height = _tfdStageLabel.textBounds.height + 10;
            
            _container.addChild(_tfdStageLabel);
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
                        
                        break;
                    
                    case TouchPhase.MOVED : 
                        if( !_isTouched )
                            return;
                        
                        break;
                    
                    case TouchPhase.ENDED :
                        _isTouched = false;
                        
                        processTouch((event.target as DisplayObject).name);
                        
                        break;
                }
            }
        }
        
        private function processTouch(button:String):void
        {
            switch(button)
            {
                case Resources.GAME_PANEL_CLICK_PANG_BUTTON:
                case Resources.GAME_PANEL_GOGGLE_PANG_BUTTON:
                case Resources.GAME_PANEL_CHANGE_PANG_BUTTON:
                    if( _clickedButton != button )
                    {
                        animateItemButton(button, true);
                        
                        // 다른 아이템을 클릭했을 경우 다른 아이템의 애니메이션을 취소
                        if( _clickedButton != "" )
                        {
                            animateItemButton(_clickedButton, false);
                        }
                        
                        _clickedButton = button;
                        
                        notifyBlockManager(_clickedButton, true);
                    }
                    else
                    {
                        animateItemButton(button, false);
                        _clickedButton = "";
                        
                        notifyBlockManager(_clickedButton, false);
                    }
                    
                
                case Resources.GAME_PANEL_PAUSE_BUTTON:
                    break;
            }
            
        }
        
        private function notifyBlockManager(button:String, isClicked:Boolean):void
        {
            switch(button)
            {
                case Resources.GAME_PANEL_CLICK_PANG_BUTTON:
                    BlockManager.instance.clickPangClicked = isClicked;
                    break;
                
                case Resources.GAME_PANEL_GOGGLE_PANG_BUTTON:
                    BlockManager.instance.gogglePangClicked = isClicked;
                    break;
                
                case Resources.GAME_PANEL_CHANGE_PANG_BUTTON:
                    BlockManager.instance.changePangClicked = isClicked;
                    break;
                
            }
        }
        
        public function animateItemButton(buttonName:String, isStart:Boolean):void
        {
            var image:Image = _container.getChildByName(buttonName) as Image;
            
            if( isStart )
            {
                scaleUp();
            }
            else
            {
                TweenLite.to(image, 0.1, {scaleX:1.0, scaleY:1.0});
            }
            
            function scaleUp():void
            {
                TweenLite.to(image, 0.5, {scaleX:1.1, scaleY:1.1, onComplete:scaleDown});
            }
            
            function scaleDown():void
            {
                TweenLite.to(image, 0.5, {scaleX:1.0, scaleY:1.0, onComplete:scaleUp});
            }
                
        }
        
        public function deactivate(buttonName:String):void
        {
            animateItemButton(buttonName, false);
            _clickedButton = "";
        }
            
    }
}