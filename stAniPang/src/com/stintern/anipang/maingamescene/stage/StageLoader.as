package com.stintern.anipang.maingamescene.stage
{
    import com.stintern.anipang.utils.Resources;

    public class StageLoader
    {
        public function StageLoader()
        {
        }
        
        public function getStageInfo(xml:XML):StageInfo
        {
            var stageInfo:StageInfo = new StageInfo();
            
			// 게임 보드 사이즈 설정
			var rowCount:XMLList = xml.child(Resources.ELEMENT_NAME_OF_ROW_COUNT);
			stageInfo.rowCount = rowCount[0];    
			var colCount:XMLList = xml.child(Resources.ELEMENT_NAME_OF_COL_COUNT);
			stageInfo.colCount = colCount[0];    
			
            // 게임 보드 2차월 배열 설정
            var boardInfo:XMLList = xml.child(Resources.ELEMENT_NAME_OF_BOARD_INFO);
            stageInfo.boardArray = getBoardInfo(boardInfo[0], rowCount[0], colCount[0]);    
            
            // 블럭 이동 제한 설정
            var moveLimit:XMLList = xml.child(Resources.ELEMENT_NAME_OF_MOVE_LIMIT);
            stageInfo.moveLimit = moveLimit[0];
            
            var mission:XMLList = xml.child(Resources.ELEMENT_NAME_OF_MISSION);
            stageInfo.mission = mission[0];
            stageInfo.missionType = mission.attributes()[0];            
            
            return stageInfo; 
        }
        
        private function getBoardInfo(boardString:String, rowCount:uint, colCount:uint):Vector.<Vector.<uint>>
        {
            var tmpArray:Array = boardString.split(",");
            
            var resultBoard:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
            
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colVector:Vector.<uint> = new Vector.<uint>();
                for(var j:uint=0; j<colCount; ++j)
                {
                    colVector.push( (int)(trim(tmpArray[i*colCount + j])) );
                }
                resultBoard.push(colVector);
            }
            
            return resultBoard;
            
            function trim( s:String ):String
            {
                var pattern:RegExp = /[\s\r\n]*/gim; 
                return s.replace(pattern, '');
            }
        }
    }
}