package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.block.algorithm.BlockLocater;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockRemover;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockRemoverResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;
    
    import starling.animation.Tween;
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;

    public class BlockManager
    {
        // 싱글톤 관련
        private static var _instance:BlockManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _blockPool:BlockPool;               // 제거된 블럭들을 저장하는 풀
        private var _blockLocater:BlockLocater;     // 블럭을 배치하는 역할
        private var _blockArray:Vector.<Vector.<Block>>;    // 생성된 블럭들이 저장되어 있는 벡터
        
        private var _blockPainter:BlockPainter;         // 블럭들을 그리는 객체
        private var _blockRemover:BlockRemover;
        
        private var _isBlockExchaning:Boolean = false;
        
        public function BlockManager()
        {
            if (!_creatingSingleton){
                throw new Error("[BlockManager] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():BlockManager
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new BlockManager();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        public function init(layer:Sprite):void
        {
            // 제거한 블럭을 저장할 풀 생성
            _blockPool = new BlockPool();
            
            // 블럭 배치 알고리즘 생성기 
            _blockLocater = new BlockLocater();
            
            // 생성한 블럭들을 저장할 벡터 생성
            _blockArray = new Vector.<Vector.<Block>>();
            
            // 블럭을 그리는 Painter 객체 생성
            _blockPainter = new BlockPainter();
            layer.addChild(_blockPainter);
            
            // 블럭을 삭제하는 알고리즘 객체 생성
            _blockRemover = new BlockRemover();
        }
        
        /**
         * 매프레임당 블럭들의 아래쪽을 확인하면서 비워 있으면 낙하하도록 합니다. 
         */
        public function stepBlocks():void
        {
            var rowCount:uint = _blockArray.length;
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
			// 블럭들을 아래로 낙하시킴
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    var block:Block = _blockArray[i][j];    // 비워있는 보드칸이면 null 반환
                    if(block == null)
                        continue;
                    
                    // 마지막 행이면 검사하지 않음
                    if( block.row == Resources.BOARD_ROW_COUNT -1 )
                        continue;
                    
                    // 아래가 블록으로 채워져야하는 칸이면 낙하
                    if( boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED )
                    {
                        moveDown(block);
                    }
                    
                }
            }
			
			// 1행에 있던 블럭들이 내려간 자리로 새로운 블럭을 생성
			fillWithNewBlocks();
        }
		
		private function fillWithNewBlocks():void
		{
			var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			var colCount:uint = boardArray[0].length;
			for(var i:uint=0; i<colCount; ++i)
			{
				if( boardArray[0][i] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED )
				{
					var block:Block = createBlock( uint(Math.random() * Resources.BLOCK_TYPE_COUNT) + Resources.BLOCK_TYPE_START);	
					block.row = 0;
					block.col = i;
					
					block.image.x = i * block.image.texture.width + Starling.current.stage.stageWidth  * 0.5 - block.image.texture.width * 4;
					block.image.y = block.image.texture.height * -1 + Resources.PADDING_TOP;
					
					boardArray[0][i] = block.type;

					var tween:Tween = new Tween(block.image, 0.2);
					tween.moveTo(block.image.x, block.image.y + block.image.texture.width);
					Starling.juggler.add(tween);
					
					tween.onStart = onStartMove;
					tween.onComplete = onCompleteMove;
                    
                    _blockArray[block.row][block.col] = block;
					
					function onStartMove():void
					{
						block.isMoving = true;
						
						_blockPainter.turnOnFlatten(false);
					}
					function onCompleteMove():void
					{
						block.isMoving = false;
						
						_blockPainter.turnOnFlatten(true);
						tween = null;
					}
					
				}
			}
		}
        
        /**
         * 블럭을 아래로 낙하시킵니다. 
         * @param block 아래로 낙하할 블럭
         */
        private function moveDown(block:Block):void
        {
            // 블럭이 낙하하고 있으면 Return
            if( block.isMoving )
                return;
            
            // 낙하 트윈 생성
            var tween:Tween = new Tween(block.image, 0.1);
            tween.moveTo(block.image.x, block.image.y + block.image.texture.width);
            Starling.juggler.add(tween);
            
            tween.onStart = onStartMove;
            tween.onComplete = onCompleteMove;
            
            function onStartMove():void
            {
                block.isMoving = true;
                
                // 정보 갱신
                block.row += 1;
                GameBoard.instance.boardArray[block.row][block.col] = block.type;
                GameBoard.instance.boardArray[block.row-1][block.col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
                
                _blockArray[block.row][block.col] = block;
                _blockArray[block.row-1][block.col] = null;

                _blockPainter.turnOnFlatten(false);
            }
            function onCompleteMove():void
            {
                block.isMoving = false;
                
                _blockPainter.turnOnFlatten(true);
                tween = null;
            }
        }

        /**
         * 로드한 보드의 정보를 바탕으로 새로운 블럭들을 배치합니다. 
         * @param board 보드 정보가 들어있는 2차원 벡터
         */
        public function createBlocks():void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            var rowCount:uint = Resources.BOARD_ROW_COUNT;
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            
            for(var i:uint = 0; i<rowCount; ++i)
            {
                var colVector:Vector.<Block> = new Vector.<Block>();
                for(var j:uint = 0; j<colCount; ++j)
                {
                    board[i][j] = getTypeOfBlock(board, i, j);
                    
                    var block:Block = createBlock(board[i][j]);	//보드가 빈공간이면  null을 반환
                    if(block != null)	
                    {
						block.row = i;
						block.col = j;
                    }
                    
                    colVector.push(  block );
                }
                _blockArray.push( colVector );
            }
            
            // 생성한 블럭들을 그림
            _blockPainter.drawBlocks(_blockArray);
        }
        
        private function getTypeOfBlock(board:Vector.<Vector.<uint>>, row:uint, col:uint):uint
        {
            var blockType:uint;
            switch(board[row][col])
            {
                case GameBoard.TYPE_OF_CELL_EMPTY:
                    return GameBoard.TYPE_OF_CELL_EMPTY;
                    
                case GameBoard.TYPE_OF_CELL_NONE:
                    return _blockLocater.makeNewType(board, row, col);
                    
                default:
                    return board[row][col];
            }
            
            return blockType;
        }
        
        /**
         * 새로운 블럭을 생성합니다.  
         * @param type 생성할 블럭의 타입
         * @param autoRegister 블럭 매니저에 등록하여 바로 화면에 출력할 지 여부
         * @return 생성한 블럭
         */
        public function createBlock(type:uint, autoRegister:Boolean = true):Block
        {
            //투명 블럭등 동물 블럭이 아닌 경우
            if( type > Resources.BLOCK_TYPE_END )
                return null;
            
            // 풀에 블럭이 있으면 새로 만들지 않음.
            var block:Block = _blockPool.getBlock(type);
            if( block != null )
            {
                return block;
            }
            
            block  = new Block();
            block.init(type, _blockPainter.getTextureByType(type), moveCallback);
            
            if( autoRegister)
            {
                registerBlock(block);
            }
            
            return block;
            
        }
        
        public function registerBlock(block:Block):void
        {
            _blockPainter.addBlock(block.image);
        }
        
        public function removeBlock(block:Block):void
        {
            if( block == null )
                return;
            
            if( block.type > Resources.BLOCK_TYPE_END )
            {
                _blockArray[block.row][block.col] = null;
                
                _blockPainter.removeBlock(block.image);
                block.dispose();
                block = null;
                
                return;
            }
            
            _blockPool.push(block);
            _blockArray[block.row][block.col] = null;
        }
        
        public function moveCallback(row1:int, col1:int, row2:int, col2:int):void
        {
            if( !nextPosAvailable(row2, col2) || _isBlockExchaning )
                return;
            
            exchangeBlock(row1, col1, row2, col2, false);
        }
        
        /**
         * 블럭을 움직일 때 다음 위치로 옮길 수 있는 지 판단 
         * @param row 옮겨갈 다음 위치의 row Index
         * @param col 옮겨갈 다음 위치의 col Index
         * @return 옮길 수 있는 지 여부
         */
        private function nextPosAvailable(row:int, col:int):Boolean
        {
            // 보드 밖이면 FALSE
            if( row < 0 || col < 0 || row >= Resources.BOARD_ROW_COUNT || col >= Resources.BOARD_COL_COUNT )
                return false;
            
            switch( GameBoard.instance.boardArray[row][col] )
            {
                case GameBoard.TYPE_OF_CELL_EMPTY:
                    return false;
                    
                case GameBoard.TYPE_OF_CELL_BOX:
                    return false;
                    
                default:
                    return true;
            }
        }
        
        /**
         * 블럭을 교환시킵니다. 
         * @param row1 이동시킬 블럭의 row Index
         * @param col1 이동시킬 블럭의 col Index
         * @param row2 이동할 위치의 row Index
         * @param col2 이동할 위치의 col Index
         * @param isReturn 교환한 후 연결되는 블럭이 없어서 다시 돌아오는 경우에는 true, 그렇지 않으면 false
         */
        private function exchangeBlock(row1:uint, col1:uint, row2:uint, col2:uint, isReturn:Boolean):void
        {
            var image1:Image = _blockArray[row1][col1].image;
            var image2:Image = _blockArray[row2][col2].image;
            
            var tween:Tween = new Tween(image1, 0.1);
            var tween2:Tween = new Tween(image2, 0.1);
            
            tween.moveTo(image2.x, image2.y);
            tween2.moveTo(image1.x, image1.y);
            
            Starling.juggler.add(tween);
            Starling.juggler.add(tween2);
            
            tween.onStart = onStartExchangeBlock;
            tween.onComplete = onCompleteExchangeBlock;
            tween2.onComplete = onCompleteExchangeBlock;

            function onStartExchangeBlock():void
            {
                _isBlockExchaning = true;
                _blockPainter.turnOnFlatten(false);
            }
            
            // 2개의 트윈이 모드 완료한 뒤에 블럭의 정보를 갱신
            var completeCount:uint = 0;
            function onCompleteExchangeBlock():void
            {
                ++completeCount;
                if(completeCount == 2)
                    updateBlocks(row1, col1, row2, col2, isReturn);
                
                _blockPainter.turnOnFlatten(true);
                
                tween = null;
                tween2 = null;
            }
        }
        
        private function updateBlocks(row1:uint, col1:uint, row2:uint, col2:uint, isReturn:Boolean):void
        {
            _isBlockExchaning = false; 
            _blockPainter.turnOnFlatten(true);
            
            // 변경한 블럭들로 정보 변경
            updateInfo(row1, col1, row2, col2);
            
            // 다시 돌아오는 경우에는 삭제될 블럭을 찾는 알고리즘을 실행시키지 않음
            if( isReturn )
                return;
            
            // 변경된 보드에서 삭제될 블럭이 있는 지 확인
            var result:Array = _blockRemover.checkBlocks(row1, col1, row2, col2);
            
            // 삭제될 블럭이 있으면 삭제하고 없으면 블럭을 다시 원위치
            if( !removeBlocks(result) )
            {
                exchangeBlock(row1, col1, row2, col2, true);
            }
        }
            
        /**
         * 블럭 및 보드들의 정보를 갱신 
         */
        private function updateInfo(row1:uint, col1:uint, row2:uint, col2:uint):void
        {
            // block의 row, col 정보 갱신
            _blockArray[row1][col1].row = row2;
            _blockArray[row1][col1].col = col2;
            
            _blockArray[row2][col2].row = row1;
            _blockArray[row2][col2].col = col1;
            
            // BlockArray 정보 갱신
            var tmp:Block = _blockArray[row1][col1];
            _blockArray[row1][col1] = _blockArray[row2][col2];
            _blockArray[row2][col2] = tmp;
            
            // Board 정보 갱신
            GameBoard.instance.boardArray[row1][col1] = _blockArray[row1][col1].type;
            GameBoard.instance.boardArray[row2][col2] = _blockArray[row2][col2].type;
        }
        
        /**
         * 블럭을 삭제합니다. 
         * @param result    블럭 제거 알고리즘의 결과값
         * @return 연결된 블럭이 없어 제거되지 않을 경우 false 리턴, 그렇지 않으면 true 
         */
        private function removeBlocks(result:Array):Boolean
        {
            // 연결된 블럭이 없을 경우 
            if( result[0] == null && result[1] == null )
                return false;
            
            var point:Point = new Point();
            for(var i:uint=0; i<2; ++i)
            {
                if( result[i] == null )
                    continue;
                    
                var removerResult:BlockRemoverResult = result[i] as BlockRemoverResult;
                var stringArray:Array = removerResult.removePos.split(",");
                
                
                var length:uint = stringArray.length;
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
                        removeSpecialBlock(_blockArray[point.x][point.y]);
                    }
                    // 옮겨진 블럭인 경우 타입을 확인해서 다른 블럭으로 변환할 지 확인
                    else if( removerResult.row == point.x && removerResult.col == point.y )
                    {
                        makeSpecialBlock(point.x, point.y, removerResult.type);
                    }
                    else
                    {
                        removeBlockAt(point.x, point.y);
                    }
                }
            }
            
            point= null
            return true;
        }
        
        private function removeBlockAt(x:uint, y:uint):void
        {
            // Block 제거
            removeBlock(_blockArray[x][y]);
            
            // Board 정보 갱신
            GameBoard.instance.boardArray[x][y] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
        }
        
        private function makeSpecialBlock(row:uint, col:uint, type:uint):void
        {
            switch( type )
            {
                case BlockRemoverResult.TYPE_RESULT_5_BLOCKS_LINEAR:
                    _blockArray[row][col].type = Resources.BLOCK_TYPE_STAR;
                    break;
                
                case BlockRemoverResult.TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:
                    _blockArray[row][col].type *= Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_HEART_INDEX;
                    break;
                
                case BlockRemoverResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX;
                    break;
                
                case BlockRemoverResult.TYPE_RESULT_4_BLOCKS_UP_DOWN:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX;
                    break;
                
                case BlockRemoverResult.TYPE_RESULT_3_BLOCKS:
                    removeBlockAt(row, col);
                    break;
            }
            
            if( type != BlockRemoverResult.TYPE_RESULT_3_BLOCKS )
            {
                GameBoard.instance.boardArray[row][col] = _blockArray[row][col].type
                _blockPainter.changeTexture(_blockArray[row][col], _blockArray[row][col].type);
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

        
        private function removeSpecialBlock(block:Block):void
        {
            trace(block.type % Resources.BLOCK_TYPE_PADDING);
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
        
        private function removeHorizontal(row:uint, col:uint):void
        {
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            for(var i:uint=0; i<colCount; ++i)
            {
                if( _blockArray[row][i] == null )
                    continue;
                
                if( i != col &&
                    _blockArray[row][i].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                    _blockArray[row][i].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                {
                    removeSpecialBlock(_blockArray[row][i]);
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
                    removeSpecialBlock(_blockArray[i][col]);
                }
                else
                {
                    removeBlockAt(i, col);
                }
            }
        }
        
        private function removeHexagon(row:uint, col:uint):void
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
                    removeBlockAt(row, col);
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
                if( _blockArray[row+rowAlpha][col+colAlpha] != null )
                {
                    if( _blockArray[row+rowAlpha][col+colAlpha].type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START &&
                        _blockArray[row+rowAlpha][col+colAlpha].type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                    {
                        removeSpecialBlock(_blockArray[row+rowAlpha][col+colAlpha]);
                    }
                    else
                    {
                        removeBlockAt(row+rowAlpha, col+colAlpha);
                    }
                }
            }
            
        }
        
        //DEBUGGING
        public function debugging(block:Block):void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            var rowCount:uint = Resources.BOARD_ROW_COUNT;
            var colCount:uint = Resources.BOARD_ROW_COUNT;
            
            trace("");
            trace("board");
            for(var i:uint = 0; i<rowCount; ++i)
            {
                var str:String = "";
                for(var j:uint = 0; j<colCount; ++j)
                {
                    str += board[i][j].toString() + ", ";
                }
                trace( str );
            }
            trace("block");
            for(var i:uint = 0; i<rowCount; ++i)
            {
                var str:String = "";
                for(var j:uint = 0; j<colCount; ++j)
                {
                    if(_blockArray[i][j] == null )
                        str += "0, ";
                    else
                        str += _blockArray[i][j].type.toString() + ", ";
                }
                trace( str );
            }
        }
    }
}