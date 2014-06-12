package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.block.algorithm.BlockRemoveAlgorithm;
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;

    public class BlockRemover
    {
        private var _blockArray:Vector.<Vector.<Block>>;    
        private var _blockPool:BlockPool;
        
        private var _blockRemoveAlgorithm:BlockRemoveAlgorithm;     //블럭 삭제 알고리즘
        
        public function BlockRemover(blockArray:Vector.<Vector.<Block>>, pool:BlockPool)
        {
            _blockArray = blockArray;
            _blockPool = pool;
            
            // 블럭을 삭제하는 알고리즘 객체 생성
            _blockRemoveAlgorithm = new BlockRemoveAlgorithm();
        }
        
        /**
         * 블럭을 삭제합니다. 
         * @param result    블럭 제거 알고리즘의 결과값
         * @return 연결된 블럭이 없어 제거되지 않을 경우 false 리턴, 그렇지 않으면 true 
         */
        public function removeBlocks(row1:uint, col1:uint, row2:uint, col2:uint):Boolean
        {
            var result:Array = _blockRemoveAlgorithm.checkBlocks(row1, col1, row2, col2);
            
            // 연결된 블럭이 없을 경우 
            if( result[0] == null && result[1] == null )
                return false;
            
            for(var i:uint=0; i<2; ++i)
            {
                // 블럭 제거 알고리즘의 결과를 바탕으로 블럭들을 제거
                removeBlockWithRemoveResult( result[i] as RemoveAlgoResult );
            }
            
            return true;
        }
        
        /**
         * 블럭 제거 알고리즘에 따른 결과를 바탕으로 블럭들을 제거 합니다. 
         */
        private function removeBlockWithRemoveResult(removerResult:RemoveAlgoResult):void
        {
            if( removerResult == null )
                return;
            
            var stringArray:Array = removerResult.removePos.split(",");
            var length:uint = stringArray.length;
            
            var point:Point = new Point();
            for(var j:uint=0; j<length; ++j)
            {
                point.x = removerResult.row;
                point.y = removerResult.col;
                
                parseIndexString(point, stringArray[j]);
                
                if( _blockArray[point.x][point.y] == null )
                    continue;
                
                // 특수 블럭인 경우 블럭의 특성에 맞게 주위 블럭들을 모두 삭제
                if( _blockArray[point.x][point.y].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    _blockArray[point.x][point.y].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlockAt(point.x, point.y);
                }
                    // 옮겨진 블럭인 경우 타입을 확인해서 다른 블럭으로 변환할 지 확인
                else if( removerResult.row == point.x && removerResult.col == point.y )
                {
                    BlockManager.instance.makeSpecialBlock(point.x, point.y, removerResult.type);
                }
                else
                {
                    removeBlockAt(point.x, point.y);
                }
            }
            
            point= null;
        }
        
        /**
         * 특정 인덱스의 블럭을 제거합니다. 
         */
        public function removeBlockAt(row:uint, col:uint):void
        {
            // 더이상 이미지를 그리지 않음
            if( _blockArray[row][col].type > Resources.BLOCK_TYPE_END )
            {
                BlockManager.instance.blockPainter.removeBlock(_blockArray[row][col].image);
            }
            
            // Block 제거
            disposeBlock(row, col);
            
            // Board 정보 갱신
            GameBoard.instance.boardArray[row][col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
        }
        
        /**
         * 블럭의 이미지를 제거하고 블럭 풀에 저장합니다. 
         */
        public function disposeBlock(row:uint, col:uint):void
        {
            var block:Block = _blockArray[row][col];
            
            if( block == null )
                return;
            
            if( block.type > Resources.BLOCK_TYPE_END )
            {
                _blockArray[block.row][block.col] = null;
                
                block.dispose();
                block = null;
                
                return;
            }
            
            _blockPool.push(block);
            _blockArray[block.row][block.col] = null;
        }
        
        /**
         * 특수 블럭을 제거합니다. 
         */
        private function removeSpecialBlockAt(x:uint, y:uint):void
        {
            var block:Block = _blockArray[x][y];
            switch( block.type % Resources.BLOCK_TYPE_PADDING  )
            {
                case Resources.BLOCK_TYPE_HEART_INDEX:
                    removeHexagon(block.row, block.col);
                    break;
                
                case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                    removeHorizontal(block.row, block.col);
                    break;
                
                case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                    removeVertical(block.row, block.col);
                    break;
            }
        }
        
        /**
         * 특수블럭이 삭제되면서 좌우 모든 블럭들을 삭제합니다. 
         */
        private function removeHorizontal(row:uint, col:uint):void
        {
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            for(var i:uint=0; i<colCount; ++i)
            {
                if( _blockArray[row][i] == null )
                    continue;
                
                // 블럭들을 삭제하면서 특수 블럭이 있으면 해당 기능을 수행합니다.
                if( i != col &&
                    _blockArray[row][i].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    _blockArray[row][i].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlockAt(row, i);
                }
                else
                {
                    removeBlockAt(row, i);
                }
            }
        }
        
        private function removeVertical(row:uint, col:uint):void
        {
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            for(var i:uint=0; i<colCount; ++i)
            {
                if( _blockArray[i][col] == null )
                    continue;
                
                if( i != row &&
                    _blockArray[i][col].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    _blockArray[i][col].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlockAt(i, col);
                }
                else
                {
                    removeBlockAt(i, col);
                }
            }
        }
        
        private function removeHexagon(row:uint, col:uint):void
        {
            // 맨 윗줄의 블럭 하나 삭제
            if( row >= 2 )
            {
                processRemove(-2, 0);
            }
            
            // 두 번째 줄의 블럭 3개 삭제
            for(var i:int=-1; i<=1; ++i)
            {
                if( row -1 < 0 )
                    break;
                
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                processRemove(-1, i);
            }
            
            // 세 번째 줄의 블럭 5개 삭제
            for(i=-2; i<=2; ++i)
            {
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                if( i == 0 )
                    removeBlockAt(row, col);
                
                processRemove(0, i);
            }
            
            // 4번째 줄의 블럭 3개 삭제
            for( i=-1; i<=1; ++i)
            {
                if( row + 1 >= Resources.BOARD_ROW_COUNT )
                    break;
                
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                processRemove(1, i);
            }
            
            // 5번째 줄의 블럭 1개 삭제
            if( row  + 2 >= Resources.BOARD_ROW_COUNT )
            {
                processRemove(2, 0);
            }
            
            function processRemove(rowAlpha:int, colAlpha:int):void
            {
                if( _blockArray[row+rowAlpha][col+colAlpha] != null )
                {
                    if( _blockArray[row+rowAlpha][col+colAlpha].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                        _blockArray[row+rowAlpha][col+colAlpha].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                    {
                        removeSpecialBlockAt(row+rowAlpha, col+colAlpha);
                    }
                    else
                    {
                        removeBlockAt(row+rowAlpha, col+colAlpha);
                    }
                }
            }
            
        }
        
        
        /**
         * 블럭 제거 알고리즘의 결과로 받은 스트링을 파싱해서 인덱스를 반환합니다. 
         */
        private function parseIndexString(result:Point, letter:String):Point
        {
            switch( letter )
            {
                case "T2":  result.x -= 2;  break;
                case "L2":  result.y -= 2;  break;
                case "B2":  result.x += 2;  break;
                case "R2":  result.y += 2;  break;
                case "T":   result.x -= 1;  break;
                case "L":   result.y -= 1;  break;
                case "B":   result.x += 1;  break;
                case "R":   result.y += 1;  break;
            }
            
            return result;
        }
        
        /**
         * 블럭이 낙하한 뒤 연결된 블럭이 있으면 삭제합니다. 
         */
        public function removeConnectedBlocks():void
        {
            var rowCount:uint = _blockArray.length;
            for(var i:int=rowCount-1; i>=0; --i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    var res:RemoveAlgoResult = _blockRemoveAlgorithm.processRemoveAlgorithm(i, j, BlockRemoveAlgorithm.MOVED_DOWN);
                    removeBlockWithRemoveResult(res);
                }
            }
        }
        
    }
}