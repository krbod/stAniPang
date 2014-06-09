package com.stintern.anipang.maingamescene.board
{
    import com.stintern.anipang.maingamescene.StageInfo;
    import com.stintern.anipang.utils.LevelLoader;

    public class GameBoard
    {
        private var _stageInfo:StageInfo; 
        
        public function GameBoard()
        {
        }
        
        public function dispose():void
        {
            
        }
        
        /**
         *  스테이지 레벨에 맞는 보드 정보를 입력합니다.
         */
        public function initBoard(level:uint):void
        {
            // 레벨에 맞는 보드 정보를 불러옵니다.
            var levelLoader:LevelLoader = new LevelLoader();
            _stageInfo = levelLoader.loadXMLAt(1);
        }
    }
}