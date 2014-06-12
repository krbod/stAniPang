package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class ConnectedBlockFinder
    {
        private var _timer:Timer = null;
        private var _result:Array = null;
        
        private var _findRequired:Boolean = true;
        private var _callback:Function;
        
        private var _availableShape:Array = new Array();
        private var _LTIndex:Array = new Array(5, 10, 12, 13);
        private var _RTIndex:Array = new Array(7, 8, 13, 14);
        private var _LBIndex:Array = new Array(4, 11, 12, 15);
        private var _RBIndex:Array = new Array(6, 9, 14, 15);
        
        public function ConnectedBlockFinder(callback:Function)
        {
            _callback = callback;
            
            _timer = new Timer(3000, 0);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
            
            _availableShape = new Array();
            for(var i:uint=0; i<16; ++i)
            {
                _availableShape.push(true);
            }
        }
        
        public function reset():void
        {
            _findRequired = true;
            _timer.reset();
        }
        
        public function process():Array
        {
            // 연결된 블럭을 이미 찾았을 경우에는 다시 찾지 않음
            if( !_findRequired )
                return _result;
                
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            var rowCount:uint = boardArray.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = boardArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {                 
                    for(var k:uint=0; k<16; ++k)
                    {
                        _availableShape[k] = true;
                    }
                    
                    var value:uint = boardArray[i][j];
                    
                    // LT 확인
                    if( i-1 < 0 ||  j-1 < 0 || boardArray[i-1][j-1] != value )
                    {
                        for(k=0; k<_LTIndex.length; ++k)
                            _availableShape[ _LTIndex[k] ] = false;
                    }
                    
                    // RT 확인
                    if( i-1 < 0 || j+1 > colCount-1 || boardArray[i-1][j+1] != value )
                    {
                        for( k=0; k<_RTIndex.length; ++k)
                            _availableShape[ _RTIndex[k] ] = false;
                    }
                    
                    // LB 확인
                    if( i+1 > rowCount-1 || j-1 < 0 || boardArray[i+1][j-1] != value )
                    {
                        for( k=0; k<_LBIndex.length; ++k)
                            _availableShape[ _LBIndex[k] ] = false;
                    }    
                    
                    // RB 확인
                    if( i+1 > rowCount-1 || j+1 > colCount-1 || boardArray[i+1][j+1] != value )
                    {
                        for( k=0; k<_RBIndex.length; ++k)
                            _availableShape[ _RBIndex[k] ] = false;
                    } 
                    
                    var result:Array = checkConnectedBlock(boardArray, i, j);
                    if( result != null )
                    {
                        _timer.start();
                        _findRequired = false;
                        
                        _result = result;
                        return _result;
                    }
                }
            }
            
            // 연결된 블럭이 없을 경우
            _timer.stop();
            return null;
        }
        
        private function checkConnectedBlock(boardArray:Vector.<Vector.<uint>>, row:uint, col:uint):Array
        {
            for(var i:uint=0; i<16; ++i)
            {
                if( !_availableShape[i] )
                    continue;
                
                var result:Array = ConnectedShape.getShapeIndiceAt(i);
                if( row+result[0] < 0 ||  row+result[2] > Resources.BOARD_ROW_COUNT-1)
                {
                    result = null;
                    continue;
                }
                
                if( col+result[1] < 0 || col+result[3] > Resources.BOARD_COL_COUNT-1 )
                {
                    result = null;
                    continue;
                }
                
                var tmp:uint = boardArray[row+result[0]][col+result[1]];
                if( tmp >= 10 )
                    tmp = (uint)(tmp * 0.1);
                
                var tmp2:uint = boardArray[row+result[2]][col+result[3]];
                if( tmp2 >= 10 )
                    tmp2 = (uint)(tmp2 * 0.1);
                
                var tmp3:uint = boardArray[row][col];
                if( tmp3 >= 10 )
                    tmp3 = (uint)(tmp3 * 0.1);
                
                
                // TEST
                if( tmp == 400 || tmp2 == 400 || tmp3 == 400 )
                    continue;
                
                if( tmp == tmp3 && tmp2 == tmp3 )
                {
                    result.push(row, col);
                    return result;
                }
            }
            
            return null;
        }
        
        private function onTimerComplete(event:TimerEvent):void
        {
            _callback(_result);
        }
        
    }
}