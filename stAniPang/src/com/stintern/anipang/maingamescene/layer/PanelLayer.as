package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    import com.stintern.anipang.utils.UILoader;
    
    import flash.text.Font;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    
    public class PanelLayer extends Sprite
    {
        [Embed(source = "../../HUHappy.ttf", fontName = "HUHappy",
			        mimeType = "application/x-font", fontWeight="Bold",
			        fontStyle="Bold", advancedAntiAliasing = "true",
			        embedAsCFF="false")]
        private static const _HUHappyFont:Class;
        private static var _font:Font;
        
        private var _isTouched:Boolean;         
        private var _clickedButton:DisplayObject;
        
        private var _container:Sprite;
        
        public function PanelLayer()
        {
            this.name = Resources.LAYER_COMPONENT;
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            _container = new Sprite();
            addChild(_container);
            
            AssetLoader.instance.loadDirectory(onComplete, null, Resources.PATH_DIRECTORY_PANEL);
            function onComplete():void
            {
                // 현재 스테이지 레벨을 읽음
                var stageLevel:uint = LevelManager.instance.currentStageLevel;
                
                LevelManager.instance.loadStageInfo(stageLevel);
                
                var paths:Array = new Array(
                    Resources.PATH_PANEL_SPRITE_SHEET, 
                    Resources.PATH_XML_PANEL_SHEET);
                
                UILoader.instance.loadUISheet(onLoadUI, null, paths);
            }
        }
        
        private function onLoadUI():void
        {
            // 스테이지 정보 배경 세팅
            UILoader.instance.loadAll(Resources.ATALS_NAME_PANEL, _container, onTouch, 0, 0);
            
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
                        
                        
                        break;
                }
            }
        }
        
    }
}