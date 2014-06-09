package com.stintern.anipang.maingamescene
{
    

    public class StageInfo
    {
        private var _boardArray:Vector.<Vector.<uint>> = null;
        private var _moveLimit:uint;
        private var _missionType:String;
        private var _mission:uint;
        
        public function StageInfo()
        {
        }
        
        public function dispose():void
        {
            while(_boardArray.length )
            {
                _boardArray[0] = null;
                _boardArray.splice(0, 1);
            }
        }
        
        public function get boardArray():Vector.<Vector.<uint>> 
        {
            return _boardArray;
        }
        public function set boardArray(boardArray:Vector.<Vector.<uint>> ):void
        {
            _boardArray = boardArray;
        }
        
        public function get moveLimit():uint
        {
            return _moveLimit;
        }
        public function set moveLimit(moveLimit:uint):void
        {
            _moveLimit = moveLimit;
        }
        
        public function get missionType():String
        {
            return _missionType;
        }
        public function set missionType(missionType:String):void
        {
            _missionType = missionType;
        }
        
        public function get mission():uint
        {
            return _mission;
        }
        public function set mission(mission:uint):void
       {
            _mission = mission;
        }
    }
    
}