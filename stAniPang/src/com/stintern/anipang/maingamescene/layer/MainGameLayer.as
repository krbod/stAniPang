package com.stintern.anipang.maingamescene.layer
{
    import com.stintern.anipang.maingamescene.LevelManager;
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
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // 블럭들을 출력할 수 있도록 초기화
            BlockManager.instance.init(this);
            
            loadStage();
            
            //this.clipRect = new Rectangle();
        }
        
        /**
         * 새로운 스테이지를 불러와 레이어에 출력합니다. 
         */
        public function loadStage():void
        {
            // 현재 스테이지 레벨을 읽음
            var stageLevel:uint = LevelManager.instance.currentStageLevel;
            
            // 스테이지 레벨에 맞도록 게임 보드를 초기화
            GameBoard.instance.initBoard(stageLevel);
            
            // 블럭들을 배치
            BlockManager.instance.createBlocks();
            
            addEventListener(Event.ENTER_FRAME, gameLoop);
            
            //Debugging
            var b:Block = BlockManager.instance.createBlock(1);
            b.image.x = 50;
            b.image.y = 50;
            b.image.name = "DEBUGGING";
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