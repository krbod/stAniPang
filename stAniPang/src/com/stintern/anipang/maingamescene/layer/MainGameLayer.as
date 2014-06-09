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
        private var _gameBoard:GameBoard;
        
        public function MainGameLayer()
        {
            this.name = Resources.LAYER_MAIN_GAME;
            
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init( event:Event ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // 게임 보드를 초기화 
            _gameBoard = new GameBoard;
            
            // 블럭들을 출력할 수 있도록 초기화
            BlockManager.instance.init(this);
            
            loadStage();
        }
        
        /**
         * 새로운 스테이지를 불러와 레이어에 출력합니다. 
         */
        public function loadStage():void
        {
            // 현재 스테이지 레벨을 읽음
            var stageLevel:uint = LevelManager.instance.getCurrentLevel();
            
            // 스테이지 레벨에 맞도록 게임 보드를 초기화
            _gameBoard.initBoard(stageLevel);
            
            // 블럭들을 배치
            BlockManager.instance.createBlocks( _gameBoard.boardArray );
        }
        
        public function resetStage():void
        {
            _gameBoard.dispose();
        }
        
    }
}