package com.stintern.anipang.maingamescene.board
{
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.StageInfo;

    public class GameBoard
    {
        private var _stageInfo:StageInfo; 
        
        public static var TYPE_OF_BLOCK_NONE:uint = 0;      // 동물만 있는 공간
        public static var TYPE_OF_BLOCK_EMPTY:uint = 10;     // 아무 것도 없는 공간
        public static var TYPE_OF_BLOCK_ICE:uint = 20;
        public static var TYPE_OF_BLOCK_BOX:uint = 30;
        
        public function GameBoard()
        {
        }
        
        public function dispose():void
        {
            _stageInfo.dispose();
        }
        
        /**
         *  스테이지 레벨에 맞는 보드 정보를 입력합니다.
         */
        public function initBoard(level:uint):void
        {
            // 레벨에 맞는 보드 정보를 불러옵니다.
            _stageInfo = LevelManager.instance.loadStageInfo(level);
        }
        
        public function get boardArray():Vector.<Vector.<uint>>
        {
            return _stageInfo.boardArray;
        }
    }
}