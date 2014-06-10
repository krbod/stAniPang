package com.stintern.anipang.maingamescene.board
{
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.StageInfo;

    public class GameBoard
    {
        // 싱글톤 관련
        private static var _instance:GameBoard;
        private static var _creatingSingleton:Boolean = false;
        
        private var _stageInfo:StageInfo; 
        
        public static var TYPE_OF_BLOCK_NONE:uint = 0;      // 동물만 있는 공간
        public static var TYPE_OF_BLOCK_EMPTY:uint = 10;     // 아무 것도 없는 공간
        public static var TYPE_OF_BLOCK_ICE:uint = 20;
        public static var TYPE_OF_BLOCK_BOX:uint = 30;
        
        public function GameBoard()
        {
            if (!_creatingSingleton){
                throw new Error("[GameBoard] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():GameBoard
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new GameBoard();
                _creatingSingleton = false;
            }
            return _instance;
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