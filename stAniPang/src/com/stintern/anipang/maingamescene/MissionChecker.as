package com.stintern.anipang.maingamescene
{
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;

    public class MissionChecker
    {
        private var _currentScore:uint;
        private var _leftStepCount:uint;     // 앞으로 블럭을 옮길 수 있는 횟수
        private var _stepLimit:uint;            // 현재 스테이지에서 블럭을 옮길 수 있는 횟수
        
        private var _missionType:String;    // 현재 스테이지의 미션 타입
        private var _missionGoal:uint;      // 미션 목표
        
        public static var MISSION_RESULT_SUCCESS:uint = 0;
        public static var MISSION_RESULT_FAILURE:uint = 1;
        public static var MISSION_RESULT_KEEP_PLAYING:uint = 2;

        
        public function MissionChecker()
        {
            init();
        }
        
        private function init():void
        {
            var stageInfo:StageInfo = LevelManager.instance.stageInfo;
            _stepLimit = stageInfo.moveLimit;
            
            _missionType = stageInfo.missionType;
            _missionGoal = stageInfo.mission;
        }
        
        /**
         * 미션을 클리어했는 지 확인합니다. 
         * @return MISSION_RESULT_SUCCESS : 클리어 했을 경우 
         *              MISSION_RESULT_FAILURE : 실패인 경우 
         *              MISSION_RESULT_KEEP_PLAYING : 계속 게임을 진행할 수 있는 경우 
         */
        public function check():uint
        {
            var checkResult:Boolean;
            switch(_missionType)
            {
                case Resources.MISSION_TYPE_ICE:
                    checkResult = checkMissionIce();
                    break;
                
                case Resources.MISSION_TYPE_SCORE:
                    checkResult = checkMissionScore();
                    break;
            }
            
            if( checkResult == true )
            {
                return MISSION_RESULT_SUCCESS;
            }
            else if( _leftStepCount == 0 )
            {
                return MISSION_RESULT_FAILURE;
            }
            else 
            {
                return MISSION_RESULT_KEEP_PLAYING;
            }
        }
        
        /**
         * 얼음을 제거하는 미션인 경우에 미션을 클리어 했는지 확인합니다.
         */
        private function checkMissionIce():Boolean
        {
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
            var iceCount:uint;
            var rowCount:uint = boardArray.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = boardArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    if( boardArray[i][j] == GameBoard.TYPE_OF_CELL_ICE )
                        ++iceCount;
                }
            }
            
            if( iceCount == 0 )
                return true;
            else
                return false;
        }
        
        /**
         * 일정 점수 이상의 점수를 내야하는 미션을 클리어 했는지 확인합니다. 
         */
        private function checkMissionScore():Boolean
        {
            return _currentScore >= _missionGoal ? true : false;  
        }
        
        public function set currentScore(score:uint):void
        {
            _currentScore = score;
        }
           
        public function step():void
        {
            --_leftStepCount;
        }
    }
}