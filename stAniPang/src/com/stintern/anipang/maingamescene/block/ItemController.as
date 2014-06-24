package com.stintern.anipang.maingamescene.block
{
    import com.greensock.TweenLite;
    import com.stintern.anipang.SceneManager;
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.layer.PanelLayer;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class ItemController
    {
        // 싱글톤 관련
        private static var _instance:ItemController;
        private static var _creatingSingleton:Boolean = false;
        
        private var _isTouch:Boolean;
        
        // 고글팡 관련
        private var _gogglePangActivated:Boolean;
        private var _gogglePangImages:Array;
        
        private var _activeBlock:Block;
            
        public function ItemController()
        {
            if (!_creatingSingleton){
                throw new Error("[ItemController] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():ItemController
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new ItemController();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        public function checkItemUsed(block:Block):void
        {
            _activeBlock = block;
            
            if( BlockManager.instance.clickPangClicked )
            {
                BlockManager.instance.removeBlockAt(_activeBlock.row, _activeBlock.col);
                BlockManager.instance.resetConnectedBlockFinder();
                
                BlockManager.instance.clickPangClicked = false;
                
                var panelLayer:PanelLayer = (Starling.current.root as SceneManager).getLayerByName(Resources.LAYER_PANEL) as PanelLayer;
                panelLayer.animateItemButton(Resources.GAME_PANEL_CLICK_PANG_BUTTON, false);
            }
            else if( BlockManager.instance.gogglePangClicked )
            {
                processGogglePang();
            }
            else if( BlockManager.instance.changePangClicked )
            {
                
            }
        }
        
        private function processGogglePang():void
        {
            // 고글팡 동물을 선택안하고 다시 자신을 클릭할 경우 고글팡 아이템을 취소
            if( _gogglePangActivated )
            {
                deactivateGogglePang();
                return;
            }
            
            // 클릭한 동물 주위에 고글팡 이미지를 출력
            activateGogglePang();
        }
        
        private function deactivateGogglePang():void
        {
            var panelLayer:PanelLayer = (Starling.current.root as SceneManager).getLayerByName(Resources.LAYER_PANEL) as PanelLayer;
            for(var i:uint=0; i<2; ++i)
            {
                animateItemButton(_gogglePangImages[i], false);
                panelLayer.removeChild(_gogglePangImages[i]);
                
                _gogglePangImages[i].dispose();
                _gogglePangImages[i] = null;
            }
            
            _gogglePangImages.length = 0;
            _gogglePangImages = null;
            _gogglePangActivated = false;
            
            BlockManager.instance.gogglePangClicked = false;
            panelLayer.animateItemButton(Resources.GAME_PANEL_GOGGLE_PANG_BUTTON, false);
        }
        
        private function activateGogglePang():void
        {
            var pos:Point = BlockManager.instance.blockPainter.getBlockPosition(_activeBlock.row, _activeBlock.col, _activeBlock.image.texture);
            
            // 좌우 고글팡
            var horizontalImage:Image = new Image( BlockManager.instance.blockPainter.getTextureByType(_activeBlock.type * Resources.BLOCK_TYPE_PADDING + 1 ) );
            horizontalImage.x = pos.x + horizontalImage.width;
            horizontalImage.y = pos.y;
            horizontalImage.name = "horizontal";
            horizontalImage.addEventListener(TouchEvent.TOUCH, onTouch);
            
            // 수직 고글팡
            var verticalImage:Image = new Image( BlockManager.instance.blockPainter.getTextureByType(_activeBlock.type * Resources.BLOCK_TYPE_PADDING + 2 ) );
            verticalImage.x = pos.x;
            verticalImage.y = pos.y - verticalImage.height;
            verticalImage.name = "vertical";
            verticalImage.addEventListener(TouchEvent.TOUCH, onTouch);
            
            // 패널레이어에 이미지를 출력
            var panelLayer:PanelLayer = (Starling.current.root as SceneManager).getLayerByName(Resources.LAYER_PANEL) as PanelLayer;
            panelLayer.addChild(horizontalImage);
            panelLayer.addChild(verticalImage);
            
            animateItemButton(horizontalImage, true);
            animateItemButton(verticalImage, true);
            
            _gogglePangImages = new Array();
            _gogglePangImages.push(horizontalImage);
            _gogglePangImages.push(verticalImage);
            
            _gogglePangActivated = true;
        }
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(event.target as DisplayObject);
            if(touch)
            {
                switch(touch.phase)
                {
                    case TouchPhase.ENDED:
                        
                        if( (event.target as DisplayObject).name == "horizontal")
                        {
                            BlockManager.instance.makeSpecialBlock(_activeBlock.row, _activeBlock.col, RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT, false);
                        }
                        else
                        {
                            BlockManager.instance.makeSpecialBlock(_activeBlock.row, _activeBlock.col, RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_UP_DOWN, false);
                        }
                        
                        deactivateGogglePang();
                        break;
                }
            }
        }
        
        private function animateItemButton(image:Image, isStart:Boolean):void
        {
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
        
    }
}