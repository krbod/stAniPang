package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.maingamescene.block.Block;
    import com.stintern.anipang.maingamescene.block.BlockManager;
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
		
		private var REMOVE_SHAPE_COUNT:uint = 16; 
        
        public function ConnectedBlockFinder(callback:Function)
        {
            _callback = callback;
            
            _timer = new Timer(3000, -1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
            
            _availableShape = new Array();
            for(var i:uint=0; i<REMOVE_SHAPE_COUNT; ++i)
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
			
			BlockManager.instance.blockArray
                
            var blockArray:Vector.<Vector.<Block>> = BlockManager.instance.blockArray
            var rowCount:uint = blockArray.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {                 
                    for(var k:uint=0; k<REMOVE_SHAPE_COUNT; ++k)
                    {
                        _availableShape[k] = true;
                    }
                    
					if(blockArray[i][j] == null )
						continue;
					
					var type:uint = getAnimalType(blockArray[i][j].type);
					
					// 동물인지 확인
					if( type > Resources.BLOCK_TYPE_END )
						continue;
					
                    
                    // LT 확인
					var tmp:uint;
                    if( i-1 < 0 ||  j-1 < 0 || blockArray[i-1][j-1] == null || getAnimalType(blockArray[i-1][j-1].type) != type )
                    {
                        for(k=0; k<_LTIndex.length; ++k)
                            _availableShape[ _LTIndex[k] ] = false;
                    }
                    
                    // RT 확인
                    if( i-1 < 0 || j+1 > colCount-1 || blockArray[i-1][j+1] == null || getAnimalType(blockArray[i-1][j+1].type) != type )
                    {
                        for( k=0; k<_RTIndex.length; ++k)
                            _availableShape[ _RTIndex[k] ] = false;
                    }
                    
                    // LB 확인
                    if( i+1 > rowCount-1 || j-1 < 0 || blockArray[i+1][j-1] == null || getAnimalType(blockArray[i+1][j-1].type) != type )
                    {
                        for( k=0; k<_LBIndex.length; ++k)
                            _availableShape[ _LBIndex[k] ] = false;
                    }    
                    
                    // RB 확인
                    if( i+1 > rowCount-1 || j+1 > colCount-1 || blockArray[i+1][j+1] == null || getAnimalType(blockArray[i+1][j+1].type) != type )
                    {
                        for( k=0; k<_RBIndex.length; ++k)
                            _availableShape[ _RBIndex[k] ] = false;
                    } 
                    
                    var result:Array = checkConnectedBlock(blockArray, i, j);
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
		
		private function getAnimalType(type:uint):uint
		{
			if( type >= 10 )
			{
				return uint(type * 0.1);
			}
			else
			{
				return type;
			}
		}
        
        private function checkConnectedBlock(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):Array
        {
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
			
            for(var i:uint=0; i<REMOVE_SHAPE_COUNT; ++i)
            {
                if( !_availableShape[i] )
                    continue;
                
                var result:Array = ConnectedShape.getShapeIndiceAt(i);
 				
				//모양은 일치하나 블럭이 옮길 수 없는 자리인 경우
				if( row+result[4] >= 0 && row+result[4] < rowCount &&
					col+result[5] >= 0 && col+result[5] < colCount && 
					GameBoard.instance.boardArray[ row+result[4] ][ col+result[5] ] == GameBoard.TYPE_OF_CELL_EMPTY )
				{
					result = null;
					continue;
				}			
				
				// 다른 블럭들의 좌표가 보드를 벗어나면 다른 모양을 찾음
                if( row+result[0] < 0 ||  row+result[2] > rowCount-1)
                {
                    result = null;
                    continue;
                }
                
                if( col+result[1] < 0 || col+result[3] > colCount-1 )
                {
                    result = null;
                    continue;
                }
                
				if( blockArray[row+result[0]][col+result[1]] == null )
					continue;
				
                var tmp:uint = blockArray[row+result[0]][col+result[1]].type;
                if( tmp >= 10 )
                    tmp = (uint)(tmp * 0.1);
                
				
				if( blockArray[row+result[2]][col+result[3]] == null )
					continue;
				
                var tmp2:uint = blockArray[row+result[2]][col+result[3]].type;
                if( tmp2 >= 10 )
                    tmp2 = (uint)(tmp2 * 0.1);
				
                var tmp3:uint = blockArray[row][col].type;
                if( tmp3 >= 10 )
                    tmp3 = (uint)(tmp3 * 0.1);
                
                
                // TEST
                if( tmp == 400 || tmp2 == 400 || tmp3 == 400 )
                    continue;
                
                if( tmp == tmp3 && tmp2 == tmp3 )
                {
                    result[0] += row;
                    result[1] += col;
                    result[2] += row;
                    result[3] += col;
                    result[4] = row;
					result[5] = col;
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