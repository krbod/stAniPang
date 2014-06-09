package com.stintern.anipang.utils
{
    import com.stintern.anipang.maingamescene.StageInfo;

    public class LevelLoader
    {
        public function LevelLoader()
        {
        }
        
        public function loadXMLAt(level:uint):StageInfo
        {
            var filePath:String = Resources.PATH_LEVEL_XML + level.toString() + ".xml";
            return getStageInfo( AssetLoader.instance.loadXML(filePath) );
        }
        
        public function getStageInfo(xml:XML):StageInfo
        {
            var stageInfo:StageInfo = new StageInfo();
            
            // 게임 보드 2차월 배열 설정
            var boardInfo:XMLList = xml.child(Resources.ELEMENT_NAME_OF_BOARD_INFO);
            stageInfo.boardArray = getBoardInfo(boardInfo[0]);    
            
            // 블럭 이동 제한 설정
            var moveLimit:XMLList = xml.child(Resources.ELEMENT_NAME_OF_MOVE_LIMIT);
            stageInfo.moveLimit = moveLimit[0];
            
            var mission:XMLList = xml.child(Resources.ELEMENT_NAME_OF_MISSION);
            stageInfo.mission = mission[0];
            stageInfo.missionType = mission.attributes()[0];            
            
            return stageInfo; 
        }
        
        private function getBoardInfo(boardString:String):Vector.<Vector.<uint>>
        {
            var tmpArray:Array = boardString.split(",");
            
            var resultBoard:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
            var rowCount:uint = Resources.BOARD_ROW_COUNT;
            var colCount:uint = Resources.BOARD_COL_COUNT;
            
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colVector:Vector.<uint> = new Vector.<uint>();
                for(var j:uint=0; j<colCount; ++j)
                {
                    colVector.push( trim(tmpArray[i*colCount + j]) );
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