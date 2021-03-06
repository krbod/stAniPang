package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.maingamescene.block.Block;
    import com.stintern.anipang.maingamescene.block.BlockManager;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class MainGameLayer extends Sprite
    {
        public function MainGameLayer()
        {
            this.name = Resources.LAYER_MAIN_GAME;
        }
        
        public function init(onInited:Function = null):void
        {
            // 블럭들을 출력할 수 있도록 초기화
            BlockManager.instance.init(this);
            
            loadStage(onInited);
        }
        
        /**
         * 새로운 스테이지를 불러와 레이어에 출력합니다. 
         */
        public function loadStage(onInited:Function=null):void
        {
            // 스테이지 레벨에 맞도록 게임 보드를 초기화
            GameBoard.instance.initBoard();
            
            // 보드 배경을 그림
            BlockManager.instance.drawBoard();
            
            // 블럭들을 배치
            BlockManager.instance.createBlocks();
            
            addEventListener(Event.ENTER_FRAME, gameLoop);
			
			if( onInited != null )
				onInited();
        }
        
        public function resetStage():void
        {
            GameBoard.instance.dispose();
        }
        
        private function gameLoop(event:Event):void
        {
            BlockManager.instance.stepBlocks();
        }
        
    }
}