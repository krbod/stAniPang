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
            
            
            loadStage();
        }
        
        public function loadStage():void
        {
            _gameBoard.initBoard(1);
            
            BlockManager.instance.init(this);
            var block:Block = BlockManager.instance.createBlock(0);
            
        }
        
        public function resetStage():void
        {
            _gameBoard.dispose();
        }
    }
}