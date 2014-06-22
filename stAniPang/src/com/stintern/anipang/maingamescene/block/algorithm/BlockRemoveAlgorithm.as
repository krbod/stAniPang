package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.maingamescene.block.Block;
    import com.stintern.anipang.maingamescene.block.BlockManager;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;

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
        
        /**
         * 터치한 블럭과 주위 블럭의 타입을 비교하여 다를 경우 제거 될수 없는 모양을 삭제합니다. 
         * 예를 들어, 터치 블럭의 상,상단에 위치한 블럭의 타입이 다를 경우에  
         * 'TTMBB', 'LLMTT', 'TTMRR', 'TTLMR', 'TTMB', 'TTM' 의 모양으로 제거가 가능하지 않습니다.
         * 이런식으로 모든 주위 블럭을 체크하고 가능하지 않은 모양들을 삭제후 최 우선순위의 모양으로 블럭을 제거합니다.
         */
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
        public function checkBlocks(lhs:Block, rhs:Block):Array
        {
            var result:Array = new Array();
            
            // 유령블럭을 교환하는 지 확인
            if( lhs.type == Resources.BLOCK_TYPE_GHOST ||
                rhs.type == Resources.BLOCK_TYPE_GHOST )
            {
                result.push( processExchangeWithGhost(lhs, rhs) );
                return result;
            }
            
            // 특수블럭끼리 교환하는지 확인
            if( lhs.type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START && 
                lhs.type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END &&
                rhs.type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                rhs.type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
            {
                result.push(processExchangeSpecialBlocks(lhs, rhs));
                return result;
            }
            
            // 일반 블럭 끼리 교환 하는 경우
            if( lhs.row < rhs.row )
            {
                result.push(process(lhs, MOVED_UP));
                result.push(process(rhs, MOVED_DOWN));
            }
            else if( lhs.row > rhs.row)
            {
                result.push(process(lhs, MOVED_DOWN));
                result.push(process(rhs, MOVED_UP));
            }
            else
            {
                if( lhs.col > rhs.col )
                {
                    result.push(process(lhs, MOVED_RIGHT));
                    result.push(process(rhs, MOVED_LEFT));
                }
                else
                {
                    result.push(process(lhs, MOVED_LEFT));
                    result.push(process(rhs, MOVED_RIGHT));
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
        public function process(block:Block, movedDirection:uint):RemoveAlgoResult
        {
            if( block == null)
                return null;
            
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
            checkDuplication(block.row, block.col, movedDirection);
            
            // 제거될 수 있는 모양이 있으면 결과를 리턴
            for(i=0; i<RemoveShape.SHAPE_COUNT; ++i)
            {
                if( _availableShape[i] )
                {
                    _availableShape = null;
                    return new RemoveAlgoResult(block.row, block.col, i, RemoveShape.getPositionArrayByType(i), false);
                }
            }
            
            return null;
        }
        
        /**
         * 특수 블럭끼리 교체하였을 경우 각 특수 블럭의 기능에 맞게 블럭을 삭제한다. 
         * @param lhs 클릭해서 이동한 특수 블럭
         * @param rhs 자리가 교체된 특수 블럭
         */
        private function processExchangeSpecialBlocks(lhs:Block, rhs:Block):RemoveAlgoResult
        {
            // 특수블럭의 타입을 확인
            switch(lhs.type % Resources.BLOCK_TYPE_PADDING)
            {
                case Resources.BLOCK_TYPE_GOGGLE_INDEX:
                    return processExchangeWithGoggle(lhs, rhs);
                
                case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                    return processExchangeWithArrow(lhs, rhs);
                
                default:
                    return null;
            }
        }
        
        /**
         * 유령블럭과 다른 블럭을 교체할 경우 교체되는 블럭의 타입을 바탕으로 이벤트가 발생합니다. 
         */
        public function processExchangeWithGhost(lhs:Block, rhs:Block):RemoveAlgoResult
        {
            // 유령블럭과 다른 블럭을 구분해서 저장
            var ghostBlock:Block, normalBlock:Block;
            if( lhs.type == Resources.BLOCK_TYPE_GHOST )
            {
                ghostBlock = lhs;
                normalBlock = rhs;
            }
            else
            {
                ghostBlock = rhs;
                normalBlock = lhs;
            }
            
            // 유령블럭과 특수 블럭이 연결될 경우
            if( normalBlock.type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START )
            {
                return processExchangeGhostWithSpecial(ghostBlock, normalBlock);                
            }
            // 유령블럭과 일반 동물 블럭이 연결될 경우
            else
            {
                return processExchangeGhostWithNormal(ghostBlock, normalBlock);
            }
        }
            
        /**
         * 유령블럭과 일반 블럭이 만났을 때, 만난 블럭과 같은 타입의 모든 블럭들을 삭제합니다. 
         */
        private function processExchangeGhostWithNormal(ghost:Block, normal:Block):RemoveAlgoResult
        {
            // 같은 타입의 모든 블럭들을 읽음
            var blocks:Array = BlockManager.instance.getBlocksByType(normal.type);
            
            // 유령 블록을 중심으로 삭제할 블럭들의 상대좌표를 저장
            var positionArray:Array = new Array( );
            var blockCount:uint = blocks.length;
            for(var i:uint=0; i<blockCount; ++i)
            {
                positionArray.push( new Point(blocks[i].row - ghost.row, blocks[i].col - ghost.col) );
            }
            
            // 유령 블럭 자신도 없어져야 하기 때문에 저장
            positionArray.push( new Point(0, 0));
            
            blocks.length = 0;
            blocks = null;
            
           return new RemoveAlgoResult(ghost.row, ghost.col, RemoveShape.EXCHANGE_GHOST_NORMAL, positionArray, true);
        }
        
        /**
         * 유령블럭과 특수블럭이 만났을 때, 보드내의 특수블럭과 같은 동물블럭들을 모두 특수블럭으로 바꾼 후 삭제합니다. 
         */
        private function processExchangeGhostWithSpecial(ghost:Block, normal:Block):RemoveAlgoResult
        {
            // 유령블럭끼리 만났을 경우
            if(normal.type == Resources.BLOCK_TYPE_GHOST)
            {
                return null;
            }
            else
            {
                // 특수블럭과 같은 동물인 블럭들을 저장
                var blocks:Array = BlockManager.instance.getBlocksByType( uint(normal.type / Resources.BLOCK_TYPE_PADDING) );
                
                // 동물블럭들을 특수블럭으로 바꾸고 유령블럭을 중심으로 상대좌표를 저장
                var positionArray:Array = new Array( );
                var blockCount:uint = blocks.length;
                for(var i:uint=0; i<blockCount; ++i)
                {
                    switch( normal.type % Resources.BLOCK_TYPE_PADDING )
                    {
                        case Resources.BLOCK_TYPE_GOGGLE_INDEX:
                            BlockManager.instance.makeSpecialBlock(blocks[i].row, blocks[i].col, RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE);
                            break;
                            
                        case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                            BlockManager.instance.makeSpecialBlock(blocks[i].row, blocks[i].col, RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT);
                            break;
                        
                        case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                            BlockManager.instance.makeSpecialBlock(blocks[i].row, blocks[i].col, RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_UP_DOWN);
                            break;
                    }
                    
                    positionArray.push( new Point(blocks[i].row - ghost.row, blocks[i].col - ghost.col) );
                }
                
                // 유령 블럭 자신도 없어져야 하기 때문에 저장
                positionArray.push(new Point(0, 0));
                
                blocks.length = 0;
                blocks = null;
                
                return new RemoveAlgoResult(ghost.row, ghost.col, RemoveShape.EXCHNAGE_GHOST_HEART, positionArray, true);
            }
        }
        
        /**
         * 고글 특수 블럭과 다른 특수 블럭이 만났을 경우 
         */
        private function processExchangeWithGoggle(lhs:Block, rhs:Block):RemoveAlgoResult
        {
            switch( rhs.type % Resources.BLOCK_TYPE_PADDING )
            {
                case Resources.BLOCK_TYPE_GOGGLE_INDEX:
                    return new RemoveAlgoResult(lhs.row, lhs.col, RemoveShape.EXCHANGE_GOGGLES, new Array(new Point(0, 0), new Point(rhs.row-lhs.row, rhs.col-lhs.col)), true);
                    
                case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                    // 근처의 블럭들을 Arrow 블럭으로 바꿔서 상하좌우 Arrow 특수 블럭 모양으로 터지도록 함
                    exchangeBlockTypeWithHeartAround(lhs);
                    return new RemoveAlgoResult(lhs.row, lhs.col, RemoveShape.EXCHANGE_GOGGLE_ARROW, new Array(new Point(0, 0)) , true);
                    
                default:
                    return null;
            }
        }
        
        private function processExchangeWithArrow(lhs:Block, rhs:Block):RemoveAlgoResult
        {
            switch( rhs.type % Resources.BLOCK_TYPE_PADDING )
            {
                case Resources.BLOCK_TYPE_GOGGLE_INDEX:
                    // 근처의 블럭들을 Arrow 블럭으로 바꿔서 상하좌우 Arrow 특수 블럭 모양으로 터지도록 함
                    exchangeBlockTypeWithHeartAround(rhs);
                    return new RemoveAlgoResult(rhs.row, rhs.col, RemoveShape.EXCHANGE_GOGGLE_ARROW, new Array(new Point(0, 0)) , true);
                    
                case Resources.BLOCK_TYPE_LR_ARROW_INDEX:
                case Resources.BLOCK_TYPE_TB_ARROW_INDEX:
                    return new RemoveAlgoResult(lhs.row, lhs.col, RemoveShape.EXCHANGE_ARROWS, new Array(new Point(0, 0), new Point(rhs.row-lhs.row, rhs.col-lhs.col)) , true);
                    
                default:
                    return null;
            }
        }
        
        /**
         * 상하 및 좌우 모든 블럭이 터지는 특수 블럭과 육각형 모양으로 터지는 특수블럭이 만났을 경우에
         * 육각형 특수블럭 상하좌우로 3라인씩 삭제하기 위해서 주위 블럭을 Arrow 블럭으로 교체 
         * @param lhs 육각형 모양의 특수블럭
         */
        private function exchangeBlockTypeWithHeartAround(block:Block):void
        {
            var blockArray:Vector.<Vector.<Block>> = BlockManager.instance.blockArray;
            BlockManager.instance.exchangeBlockType(blockArray[block.row-1][block.col-1], blockArray[block.row-1][block.col-1].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX, false);
            BlockManager.instance.exchangeBlockType(blockArray[block.row-1][block.col], blockArray[block.row-1][block.col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX, false);
            BlockManager.instance.exchangeBlockType(blockArray[block.row-1][block.col+1], blockArray[block.row-1][block.col+1].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX, false);
            
            BlockManager.instance.exchangeBlockType(blockArray[block.row][block.col-1], blockArray[block.row][block.col-1].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX, false);
            BlockManager.instance.exchangeBlockType(blockArray[block.row+1][block.col-1], blockArray[block.row+1][block.col-1].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX, false);
            BlockManager.instance.exchangeBlockType(blockArray[block.row+1][block.col+1], blockArray[block.row+1][block.col+1].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX, false);
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
            //var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			var blockArray:Vector.<Vector.<Block>> = BlockManager.instance.blockArray;
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
            
            // 아래로 옮겨진 블럭의 경우에는 위쪽 블럭들을 검사할 필요가 없음
            if( movedDirection != MOVED_DOWN )
            {
                // 옮겨진 블럭과 2개 위쪽으로 떨어진 블럭이 옮겨진 블럭과 같지 않을 경우
                // 가능하지 않은 모양들을 제거
                if(row < 2  ||  !check2Value(blockArray, row, col, -2, 0) )
                {
                    removeAvailableFunction(POS_TTX);
                }
                
                if( row < 1 || !check2Value(blockArray, row, col, -1, 0) )
                {
                    removeAvailableFunction(POS_TX);
                }
            }
            
            // 위와 같은 방식으로 나머지 방향도 검사

            if( movedDirection != MOVED_RIGHT )
            {
                if( col < 2 || !check2Value(blockArray, row, col, 0, -2) )
                {
                    removeAvailableFunction(POS_LLX);
                }
                  
                if( col < 1 || !check2Value(blockArray, row, col, 0, -1) )
                {
                    removeAvailableFunction(POS_LX);
                }
            }
            
            if( movedDirection != MOVED_UP )
            {
                if( row > rowCount-2 ||  !check2Value(blockArray, row, col, 1, 0) )
                {
                    removeAvailableFunction(POS_BX);
                }
                
                if( row > rowCount-3 || !check2Value(blockArray, row, col, 2, 0) )
                {
                    removeAvailableFunction(POS_BBX);
                }
            }

            if( movedDirection != MOVED_LEFT )
            {
                if( col > colCount-2 || !check2Value(blockArray, row, col, 0, 1) )
                {
                    removeAvailableFunction(POS_RX);
                }
                
                if( col > colCount-3 || !check2Value(blockArray, row, col, 0, 2 ) )
                {
                    removeAvailableFunction(POS_RRX);
                }
            }
            
        }
        
        private function check2Value(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint, rowAlpha:int, colAlpha:int):Boolean
        {
            var tmp1:uint, tmp2:uint;
            
			if( blockArray[row+rowAlpha][col+colAlpha] == null || blockArray[row][col] == null )
				return false;
			
			blockArray[row+rowAlpha][col+colAlpha].type < 10 ? tmp1 = blockArray[row + rowAlpha][col + colAlpha].type : tmp1 = uint(blockArray[row + rowAlpha][col + colAlpha].type / Resources.BLOCK_TYPE_PADDING);
			blockArray[row][col].type < 10 ? tmp2 = blockArray[row][col].type : tmp2 = uint(blockArray[row][col].type / Resources.BLOCK_TYPE_PADDING);
            
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

