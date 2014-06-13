package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;

    public class BlockRemoveAlgorithm
    {
        private var _availableShape:Array;
        
        public static var MOVED_LEFT:uint = 0;
        public static var MOVED_UP:uint = 1;
        public static var MOVED_RIGHT:uint = 2;
        public static var MOVED_DOWN:uint = 3;
        
        // X:Moved Block
        // T(TOP):Blocks on the moved one
        // B(BOTTOM):blocks under the moved one
        // L(LEFT):blocks at the left side of moved one
        // R(RIGHT):blocks at the right side of moved one
        private var POS_TTX:uint = 0;
        private var POS_TX:uint = 1;
        private var POS_LLX:uint = 2;
        private var POS_LX:uint = 3;
        private var POS_BX:uint = 4;
        private var POS_BBX:uint = 5;
        private var POS_RX:uint = 6;
        private var POS_RRX:uint = 7;
        
        private var _positionArray:Array = new Array();
        
        public function BlockRemoveAlgorithm()
        {
            // POS_OOO 가 관여하는 Shape 들 
            _positionArray.push ( new Array(RemoveShape.TTMBB, RemoveShape.LLMTT, RemoveShape.TTMRR, RemoveShape.TTLMR, RemoveShape.TTMB, RemoveShape.TTM) );
            _positionArray.push ( new Array(RemoveShape.TTMBB, RemoveShape.LLMTT, RemoveShape.TTMRR, RemoveShape.LTMRB, RemoveShape.TTLMR, RemoveShape.LLTMB, RemoveShape.RRTMB, RemoveShape.TTMB, RemoveShape.TMBB, RemoveShape.TTM, RemoveShape.TMB) );
            _positionArray.push ( new Array(RemoveShape.LLMRR, RemoveShape.LLMTT, RemoveShape.LLMBB, RemoveShape.LLTMB, RemoveShape.LLMR, RemoveShape.LLM) );
            _positionArray.push ( new Array(RemoveShape.LLMRR, RemoveShape.LLMTT, RemoveShape.LLMBB, RemoveShape.LTMRB, RemoveShape.LLTMB, RemoveShape.TTLMR, RemoveShape.LMRBB, RemoveShape.LLMR, RemoveShape.LMRR, RemoveShape.LLM, RemoveShape.LMR) );
            _positionArray.push ( new Array(RemoveShape.TTMBB, RemoveShape.LLMBB, RemoveShape.RRMBB, RemoveShape.LTMRB, RemoveShape.LMRBB, RemoveShape.LLTMB, RemoveShape.RRTMB, RemoveShape.TTMB, RemoveShape.TMBB, RemoveShape.MBB, RemoveShape.TMB) );
            _positionArray.push ( new Array(RemoveShape.TTMBB, RemoveShape.LLMBB, RemoveShape.RRMBB, RemoveShape.LMRBB, RemoveShape.TMBB, RemoveShape.MBB) );
            _positionArray.push ( new Array(RemoveShape.LLMRR, RemoveShape.RRMBB, RemoveShape.TTMRR, RemoveShape.LTMRB, RemoveShape.RRTMB, RemoveShape.TTLMR, RemoveShape.LMRBB, RemoveShape.LLMR, RemoveShape.LMRR, RemoveShape.MRR, RemoveShape.LMR) );
            _positionArray.push ( new Array(RemoveShape.LLMRR, RemoveShape.RRMBB, RemoveShape.TTMRR, RemoveShape.RRTMB, RemoveShape.LMRR, RemoveShape.MRR) );
        }
        
        /**
         * 맞닿아 있는 블럭을 확인해서 제거합니다.
         * 왼쪽으로 옮겨진 블럭은 오른쪽에 맞닿은 블럭과는 검사를 하지 않습니다. 
         */
        public function checkBlocks(row1, col1, row2, col2):Array
        {
            var result:Array = new Array();
            
            if( row1 < row2 )
            {
                result.push(process(row1, col1, MOVED_UP));
                result.push(process(row2, col2, MOVED_DOWN));
            }
            else if( row1 > row2)
            {
                result.push(process(row1, col1, MOVED_DOWN));
                    result.push(process(row2, col2, MOVED_UP));
            }
            else
            {
                if( col1 > col2 )
                {
                    result.push(process(row1, col1, MOVED_RIGHT));
                        result.push(process(row2, col2, MOVED_LEFT));
                }
                else
                {
                    result.push(process(row1, col1, MOVED_LEFT));
                        result.push(process(row2, col2, MOVED_RIGHT));
                }
            }
            
            return result;
        }
        
        /**
         * 중복되는 블럭을 찾습니다. 
         * @param row 옮겨진 블럭의 row 인덱스
         * @param col 옮겨진 블럭의 col 인덱스
         * @param movedDirection 옮겨진 방향
         * @return 
         */
        public function process(row:uint, col:uint, movedDirection:uint):RemoveAlgoResult
        {
            // 제거될 수 있는 모양의 배열을 초기화
            _availableShape = new Array();
            _availableShape.length = RemoveShape.SHAPE_COUNT;
            for(var i:uint=0; i<RemoveShape.SHAPE_COUNT; ++i)
            {
                _availableShape[i] = false;
            }

            // 옮겨진 방향을 기준으로 제거될 수 있는 모양을 설정
            setAvailableShape(movedDirection);
            
            // 서로 맞닿아 있는 블럭들을 검사하여 제거될 수 있는 블럭이 있는 지 확인
            checkDuplication(row, col, movedDirection);
            
            // 제거될 수 있는 모양이 있으면 결과를 리턴
            for(i=0; i<RemoveShape.SHAPE_COUNT; ++i)
            {
                if( _availableShape[i] )
                {
                    _availableShape = null;
                    return new RemoveAlgoResult(row, col, i, RemoveShape.getStringAt(i));
                }
            }
            
            return null;
        }
        
        /**
         * 옮겨진 방향을 기준으로 제거될 수 있는 모양을 설정합니다. 
         * @param movedDirection 블럭이 옮겨진 방향
         */
        private function setAvailableShape(movedDirection:uint):void
        {
            switch(movedDirection)
            {
                //블럭이 왼쪽으로 옮겨진 경우
                // 가능한 모양 : '│', '┘', '┐', ... 
                case MOVED_LEFT:
                    _availableShape[RemoveShape.TTMBB] = true;
                    _availableShape[RemoveShape.LLMTT] = true;
                    _availableShape[RemoveShape.LLMBB] = true;
                    
                    _availableShape[RemoveShape.LLTMB] = true;
                    
                    _availableShape[RemoveShape.TTMB] = true;
                    _availableShape[RemoveShape.TMBB] = true;
                    _availableShape[RemoveShape.TTM] = true;
                    _availableShape[RemoveShape.LLM] = true;
                    _availableShape[RemoveShape.MBB] = true;
                    _availableShape[RemoveShape.TMB] = true;
                    break;
                    
                case MOVED_UP:
                    _availableShape[RemoveShape.LLMRR] = true;
                    _availableShape[RemoveShape.LLMTT] = true;
                    _availableShape[RemoveShape.TTMRR] = true;
                    
                    _availableShape[RemoveShape.TTLMR] = true;
                    
                    _availableShape[RemoveShape.LLMR] = true;
                    _availableShape[RemoveShape.LMRR] = true;
                    _availableShape[RemoveShape.TTM] = true;
                    _availableShape[RemoveShape.LLM] = true;
                    _availableShape[RemoveShape.MRR] = true;
                    _availableShape[RemoveShape.LMR] = true;
                    
                    break;
                    
                case MOVED_RIGHT:
                    _availableShape[RemoveShape.TTMBB] = true;
                    _availableShape[RemoveShape.RRMBB] = true;
                    _availableShape[RemoveShape.TTMRR] = true;
                    
                    _availableShape[RemoveShape.RRTMB] = true;
                    
                    _availableShape[RemoveShape.TTMB] = true;
                    _availableShape[RemoveShape.TMBB] = true;
                    _availableShape[RemoveShape.TTM] = true;
                    _availableShape[RemoveShape.MBB] = true;
                    _availableShape[RemoveShape.MRR] = true;
                    _availableShape[RemoveShape.TMB] = true;
                    break;
                    
                case MOVED_DOWN:
                    _availableShape[RemoveShape.LLMRR] = true;
                    _availableShape[RemoveShape.LLMBB] = true;
                    _availableShape[RemoveShape.RRMBB] = true;
                    
                    _availableShape[RemoveShape.LMRBB] = true;
                    
                    _availableShape[RemoveShape.LLMR] = true;
                    _availableShape[RemoveShape.LMRR] = true;
                    _availableShape[RemoveShape.LLM] = true;
                    _availableShape[RemoveShape.MBB] = true;
                    _availableShape[RemoveShape.MRR] = true;
                    _availableShape[RemoveShape.LMR] = true;
                    break;
            }
        }

        private function checkDuplication(row:uint, col:uint, movedDirection:uint):void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
            // 아래로 옮겨진 블럭의 경우에는 위쪽 블럭들을 검사할 필요가 없음
            if( movedDirection != MOVED_DOWN )
            {
                // 옮겨진 블럭과 2개 위쪽으로 떨어진 블럭이 옮겨진 블럭과 같지 않을 경우
                // 가능하지 않은 모양들을 제거
                if(row < 2  ||  !check2Value(board, row, col, -2, 0) )
                {
                    removeAvailableFunction(POS_TTX);
                }
                
                if( row < 1 || !check2Value(board, row, col, -1, 0) )
                {
                    removeAvailableFunction(POS_TX);
                }
            }
            
            // 위와 같은 방식으로 나머지 방향도 검사

            if( movedDirection != MOVED_RIGHT )
            {
                if( col < 2 || !check2Value(board, row, col, 0, -2) )
                {
                    removeAvailableFunction(POS_LLX);
                }
                  
                if( col < 1 || !check2Value(board, row, col, 0, -1) )
                {
                    removeAvailableFunction(POS_LX);
                }
            }
            
            if( movedDirection != MOVED_UP )
            {
                if( row > Resources.BOARD_ROW_COUNT-2 ||  !check2Value(board, row, col, 1, 0) )
                {
                    removeAvailableFunction(POS_BX);
                }
                
                if( row > Resources.BOARD_ROW_COUNT-3 || !check2Value(board, row, col, 2, 0) )
                {
                    removeAvailableFunction(POS_BBX);
                }
            }

            if( movedDirection != MOVED_LEFT )
            {
                if( col > Resources.BOARD_COL_COUNT-2 || !check2Value(board, row, col, 0, 1) )
                {
                    removeAvailableFunction(POS_RX);
                }
                
                if( col > Resources.BOARD_COL_COUNT-3 || !check2Value(board, row, col, 0, 2 ) )
                {
                    removeAvailableFunction(POS_RRX);
                }
            }
            
        }
        
        private function check2Value(board:Vector.<Vector.<uint>>, row:uint, col:uint, rowAlpha:int, colAlpha:int):Boolean
        {
            var tmp1:uint, tmp2:uint;
            
            board[row+rowAlpha][col+colAlpha] < 10 ? tmp1 = board[row + rowAlpha][col + colAlpha] : tmp1 = uint(board[row + rowAlpha][col + colAlpha] / Resources.BLOCK_TYPE_PADDING);
            board[row][col] < 10 ? tmp2 = board[row][col] : tmp2 = uint(board[row][col] / Resources.BLOCK_TYPE_PADDING);
            
            if( tmp1 == tmp2 )
            {
                return true;
            }
            return false;
        }
       
        private function removeAvailableFunction(type:uint):void
        {
            var count:uint = _positionArray[type].length;
            for(var i:uint=0; i<count; ++i)
            {
                _availableShape[ _positionArray[type][i] ] = false;
            }
        }
            
    }
}

