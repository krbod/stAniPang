package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;

    public class BlockRemover
    {
        private var _blockPool:BlockPool;
        
        public function BlockRemover(pool:BlockPool)
        {
            _blockPool = pool;
        }
        
        /**
         * 블럭을 삭제합니다. 
         * @param result    블럭 제거 알고리즘의 결과값
         * @return 연결된 블럭이 없어 제거되지 않을 경우 false 리턴, 그렇지 않으면 true 
         */
        public function removeBlocks(blockArray:Vector.<Vector.<Block>>, result:Array):Boolean
        {
            // 연결된 블럭이 없을 경우 
            if( result[0] == null && result[1] == null )
                return false;
            
            var point:Point = new Point();
            for(var i:uint=0; i<2; ++i)
            {
                if( result[i] == null )
                    continue;
                
                var removerResult:RemoveAlgoResult = result[i] as RemoveAlgoResult;
                var stringArray:Array = removerResult.removePos.split(",");
                
                
                var length:uint = stringArray.length;
                for(var j:uint=0; j<length; ++j)
                {
                    point.x = removerResult.row;
                    point.y = removerResult.col;
                    
                    parseIndexString(point, stringArray[j]);
                    
                    if( blockArray[point.x][point.y] == null )
                        continue;
                    
                    // 특수 블럭인 경우 블럭의 특성에 맞게 주위 블럭들을 모두 삭제
                    if( blockArray[point.x][point.y].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                        blockArray[point.x][point.y].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                    {
                        removeSpecialBlock(blockArray, point.x, point.y);
                    }
                        // 옮겨진 블럭인 경우 타입을 확인해서 다른 블럭으로 변환할 지 확인
                    else if( removerResult.row == point.x && removerResult.col == point.y )
                    {
                        BlockManager.instance.makeSpecialBlock(point.x, point.y, removerResult.type);
                    }
                    else
                    {
                        removeBlockAt(blockArray, point.x, point.y);
                    }
                }
            }
            
            point= null
            return true;
        }
        
        public function removeBlockAt(blockArray:Vector.<Vector.<Block>>, x:uint, y:uint):void
        {
            // 더이상 이미지를 그리지 않음
            if( blockArray[x][y].type > Resources.BLOCK_TYPE_END )
            {
                BlockManager.instance.blockPainter.removeBlock(blockArray[x][y].image);
            }
            
            // Block 제거
            removeBlock(blockArray, x, y);
            
            // Board 정보 갱신
            GameBoard.instance.boardArray[x][y] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
        }
        
        public function removeBlock(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):void
        {
            var block:Block = blockArray[row][col];
            
            if( block == null )
                return;
            
            if( block.type > Resources.BLOCK_TYPE_END )
            {
                blockArray[block.row][block.col] = null;
                
                block.dispose();
                block = null;
                
                return;
            }
            
            _blockPool.push(block);
            blockArray[block.row][block.col] = null;
        }
        
        private function removeSpecialBlock(blockArray:Vector.<Vector.<Block>>, x:uint, y:uint):void
        {
            var block:Block = blockArray[x][y];
            switch( block.type % Resources.BLOCK_TYPE_PADDING  )
            {
                case Resources.BLOCK_TYPE_HEART_INDEX:
                    removeHexagon(blockArray, block.row, block.col);
                    break;
                
                case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                    removeHorizontal(blockArray, block.row, block.col);
                    break;
                
                case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                    removeVertical(blockArray, block.row, block.col);
                    break;
            }
        }
        
        private function removeHorizontal(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):void
        {
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            for(var i:uint=0; i<colCount; ++i)
            {
                if( blockArray[row][i] == null )
                    continue;
                
                if( i != col &&
                    blockArray[row][i].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    blockArray[row][i].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlock(blockArray[row][i], row, i);
                }
                else
                {
                    removeBlockAt(blockArray, row, i);
                }
            }
        }
        
        private function removeVertical(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):void
        {
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            for(var i:uint=0; i<colCount; ++i)
            {
                if( blockArray[i][col] == null )
                    continue;
                
                if( i != row &&
                    blockArray[i][col].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    blockArray[i][col].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlock(blockArray[i][col], i, col);
                }
                else
                {
                    removeBlockAt(blockArray, i, col);
                }
            }
        }
        
        private function removeHexagon(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):void
        {
            if( row >= 2 )
            {
                processRemove(-2, 0);
            }
            
            for(var i:int=-1; i<=1; ++i)
            {
                if( row -1 < 0 )
                    break;
                
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                
                processRemove(-1, i);
            }
            
            for(i=-2; i<=2; ++i)
            {
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                if( i == 0 )
                {
                    removeBlockAt(blockArray, row, col);
                }
                
                processRemove(0, i);
            }
            
            for( i=-1; i<=1; ++i)
            {
                if( row + 1 >= Resources.BOARD_ROW_COUNT )
                    break;
                
                if( col+i < 0 || col + i > Resources.BOARD_COL_COUNT )
                    continue;
                
                processRemove(1, i);
            }
            
            if( row  + 2 >= Resources.BOARD_ROW_COUNT )
            {
                processRemove(2, 0);
            }
            
            function processRemove(rowAlpha:int, colAlpha:int):void
            {
                if( blockArray[row+rowAlpha][col+colAlpha] != null )
                {
                    if( blockArray[row+rowAlpha][col+colAlpha].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                        blockArray[row+rowAlpha][col+colAlpha].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                    {
                        removeSpecialBlock(blockArray[row+rowAlpha][col+colAlpha], row+rowAlpha, col+colAlpha);
                    }
                    else
                    {
                        removeBlockAt(blockArray, row+rowAlpha, col+colAlpha);
                    }
                }
            }
            
        }
        
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
        
        
    }
}