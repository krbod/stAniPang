package com.stintern.anipang.maingamescene.block
{
    import com.greensock.TweenLite;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockLocater;
    import com.stintern.anipang.maingamescene.block.algorithm.ConnectedBlockFinder;
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;

    public class BlockManager
    {
        // 싱글톤 관련
        private static var _instance:BlockManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _blockPool:BlockPool;                               // 제거된 블럭들을 저장하는 풀
        private var _blockLocater:BlockLocater;                     // 블럭을 배치알고리즘
        private var _blockArray:Vector.<Vector.<Block>>;    // 생성된 블럭들이 저장되어 있는 벡터
        
        private var _blockRemover:BlockRemover;              // 블럭삭제 알고리즘에 의해 삭제할 블럭들을 없앰
        private var _connectedBlockFinder:ConnectedBlockFinder;
        
        private var _blockPainter:BlockPainter;                     // 블럭들을 그리는 객체
        private var _isBlockExchaning:Boolean = false;      // 블럭을 교환하고 있을 때 다른 블럭을 교환할 수 없게 하기 위해
        
        private var _movingBlockCount:uint = 0;
        
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
        
        /**
         * 블럭관리에 필요한 여러 객체를 초기화합니다. 
         * @param layer 블럭을 출력할 레이어
         */
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
            
            // 삭제 알고리즘의 결과값을 통해 블럭을 삭제
            _blockRemover = new BlockRemover(_blockArray, _blockPool);
            
            //  블럭을 옮기면 연결될 블럭을 찾는 객체 생성 
            _connectedBlockFinder = new ConnectedBlockFinder(callbackConnectedBlock);
        }
        
        /**
         * 매프레임당 블럭들의 아래쪽을 확인하면서 비워 있으면 낙하하도록 합니다. 
         */
        public function stepBlocks():void
        {
            // 다음 블럭의 위치를 확인하고 옮겨야 하면 블럭 정보를 변경
            moveBlocks();
			
			// 1행에 있던 블럭들이 내려간 자리로 새로운 블럭을 생성
			fillWithNewBlocks();
            			
            // 변경된 블럭의 정보를 바탕으로 블럭을 새로 그림
            _blockPainter.drawBlocks(_blockArray);
            						
            // 블럭이 낙하한 뒤 연결된 블럭이 있는 지 확인
            if( _movingBlockCount == 0 )
            {				
                // 낙하한 뒤 새로운 보드에서 연결된 블럭이 있으면 삭제
                _blockRemover.removeConnectedBlocks();

                // 블럭을 하나 옮기면 연결될 블럭이 있는 지 확인 후 없으면 보드를 재배열
                var result:Array = _connectedBlockFinder.process();
                if( result == null )
                {
                   	GameBoard.instance.recreateBoard(_blockArray, _blockLocater, _blockPainter);     
                }
            }
        }
        
        /**
         * 블럭의 아랫칸을 확인하고 내려가야 하면 블럭의 정보를 갱신합니다. 
         */
        private function moveBlocks():void
        {
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
            var rowCount:uint = _blockArray.length;
            for(var i:int=rowCount-1; i>=0; --i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    // 블럭이 null (비어있는 칸)이거나 맨 아랫줄이면 낙하시키지 않음
                    var block:Block = _blockArray[i][j];    
                    if(block == null || block.row == GameBoard.instance.rowCount - 1)
                    {
                        continue;
                    }
                    
                    if(block.isMoving)
                        continue;
                        
                    // 아래가 블록으로 채워져야하는 칸이면 낙하
                    if( boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED ||
                        boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
                    {
                        moveBlock(block, block.row+1, block.col);
                    }
					// 왼쪽이 블럭이 없는 곳이고 대각선 왼쪽이 비어 있으면 대각선 왼쪽으로 옮김
                    else if( checkDiagonal(block.row, block.col, true) )
                    {
                        moveBlock(block, block.row+1, block.col-1);
                    }
					// 오른쪽 대각선 체크
					else if( checkDiagonal(block.row, block.col, false) )
					{
						moveBlock(block, block.row+1, block.col+1);
					}
                    
                }
            }
            
        }
		
		/**
		 * 대각선으로 블럭이 이동할 수 있는 지 확인하고 블럭을 이동시킵니다. 
		 * @param row 현재 블럭의 위치 row
		 * @param col 현재 블럭의 위치 col
		 * @param isLeft 왼쪽 대각선이면 true, 그렇지 않으면 false
		 * @return 이동할 수 있으면 true, 그렇지 않으면 false
		 */
		private function checkDiagonal(row:uint, col:uint, isLeft:Boolean):Boolean
		{
			var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			if( isLeft )
			{
				if( col-1 < 0 )
					return false;
				
				// 대각선에 다른 블럭이 있을 경우 옮기지 않음
				if( boardArray[row+1][col-1] != GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED  ||
                    boardArray[row+1][col-1] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
					return false;
				
				// 왼쪽에 보드 정보를 확인하고 블럭을 옮겨야 하면 옮김
				switch( boardArray[row][col-1] )
				{
					case GameBoard.TYPE_OF_CELL_EMPTY:
					case GameBoard.TYPE_OF_CELL_BOX:
						return true;
					
					default:
						return false;
				}
					
			}
			else
			{
				if( col+1 > GameBoard.instance.colCount - 1 )
					return false;
				
				if( boardArray[row+1][col+1] != GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED || 
                    boardArray[row+1][col+1] != GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
					return false;
				
				switch( boardArray[row][col+1] )
				{
					case GameBoard.TYPE_OF_CELL_EMPTY:
					case GameBoard.TYPE_OF_CELL_BOX:
						return true;
						
					default:
						return false;
				}	
			}
			return true;
		}
		
        /**
         * 블럭이 낙하함으로 인해 첫 행이 비워졌을 때 
         * 새로운 블럭을 생성합니다. 
         */
		private function fillWithNewBlocks():void
		{
			var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			var colCount:uint = boardArray[0].length;
			for(var i:uint=0; i<colCount; ++i)
			{
                // 맨 윗행이 채워져야하는 공간이면 새로운 블럭을 생성하여 배치함
				if( boardArray[0][i] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED || 
                    boardArray[0][i] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
				{
					var block:Block = createBlock( uint(Math.random() * Resources.BLOCK_TYPE_COUNT) + Resources.BLOCK_TYPE_START);	
					block.row = 0;
					block.col = i;
					
					block.image.x = i * block.image.texture.width + Starling.current.stage.stageWidth  * 0.5 - block.image.texture.width * 4;
					block.image.y = block.image.texture.height * -1 + Starling.current.stage.stageHeight  * 0.5 - block.image.texture.height * 4;

                    boardArray[0][i] = GameBoard.TYPE_OF_CELL_ANIMAL;
                    _blockArray[block.row][block.col] = block;
                    
                    block.drawRequired = true;
				}
			}
		}
        
        /**
         * 블럭을 입력한 인덱스 위치로 이동시킵니다. 
         */
        private function moveBlock(block:Block, row:uint, col:uint):void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            
            // 정보 갱신
            if(board[block.row][block.col] == GameBoard.TYPE_OF_CELL_ICE )
            {
                board[block.row][block.col] = GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED;
            }
            else
            {
                board[block.row][block.col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
            }
            
            _blockArray[block.row][block.col] = null;
            
            block.row = row;
            block.col = col;
            
            // 옮겨갼 위치가 얼음이 아닐경우에는 게임 보드 정보를 동물로 변경
            if( board[row][col] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
            {
                board[row][col] = GameBoard.TYPE_OF_CELL_ICE;
            }
            else if( board[row][col] != GameBoard.TYPE_OF_CELL_ICE )
            {
                board[row][col] = GameBoard.TYPE_OF_CELL_ANIMAL;
            }
                
            _blockArray[row][col] = block;
            
            // 다음 프레임 때 BlockPainter 에 의해서 갱신된 위치로 블럭을 Tween
            block.drawRequired = true;
        }

        /**
         * 로드한 보드의 정보를 바탕으로 새로운 블럭들을 배치합니다. 
         */
        public function createBlocks():void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            var rowCount:uint = GameBoard.instance.rowCount;
            var colCount:uint = GameBoard.instance.colCount;
            
			_blockArray.length = rowCount;
            for(var i:uint = 0; i<rowCount; ++i)
            {
				_blockArray[i] = new Vector.<Block>();
				_blockArray[i].length = colCount
                for(var j:uint = 0; j<colCount; ++j)
                {
                    // 보드 정보를 보고 블럭의 타입을 받아옴
                    var type:uint = getTypeOfBlock(board, i, j);
                    
                    var block:Block = createBlock(type);	//보드가 빈공간이면  null을 반환
                    if(block != null)	
                    {
						block.row = i;
						block.col = j;
                        
                        // 블럭 이미지 위치를 설정
                        _blockPainter.setImagePosition(block.image, i, j);
                    }
                    
					_blockArray[i][j] = block;
                }
            }
        }
        
        private function getTypeOfBlock(board:Vector.<Vector.<uint>>, row:uint, col:uint):uint
        {
            var blockType:uint;
            switch(board[row][col])
            {
                case GameBoard.TYPE_OF_CELL_EMPTY:
                    return GameBoard.TYPE_OF_CELL_EMPTY;
                    
                case GameBoard.TYPE_OF_CELL_ANIMAL:
                case GameBoard.TYPE_OF_CELL_ICE:
                    return _blockLocater.makeNewType(BlockManager.instance.blockArray, row, col);
                    
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
            if( type > Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
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
       
        public function moveCallback(row1:int, col1:int, row2:int, col2:int):void
        {
            if( !nextPosAvailable(row2, col2) || _isBlockExchaning )
                return;
            
            exchangeBlock(_blockArray[row1][col1], _blockArray[row2][col2], false);
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
            if( row < 0 || col < 0 || row >= GameBoard.instance.rowCount || col >= GameBoard.instance.colCount )
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
        private function exchangeBlock(lhs:Block, rhs:Block, isReturn:Boolean):void
        {
            var image1:Image = lhs.image;
            var image2:Image = rhs.image;
            
            TweenLite.to(image1, 0.15, {x:image2.x, y:image2.y, onComplete:onCompleteExchangeBlock});
            TweenLite.to(image2, 0.15, {x:image1.x, y:image1.y, onComplete:onCompleteExchangeBlock});
            
            _isBlockExchaning = true;
            
            // 2개의 트윈이 모드 완료한 뒤에 블럭의 정보를 갱신
            var completeCount:uint = 0;
            function onCompleteExchangeBlock():void
            {
                ++completeCount;
                if(completeCount == 2)
                    updateBlocks(lhs, rhs, isReturn);
                
                // 블럭을 움직였을 경우에 연결된 블럭을 찾는 것을 리셋
                _connectedBlockFinder.reset();
                _blockPainter.disposeHint();
            }
        }
        
        private function updateBlocks(lhs:Block, rhs:Block, isReturn:Boolean):void
        {
            _isBlockExchaning = false; 
            
            // 변경한 블럭들로 정보 변경
            updateInfo(lhs, rhs);
            
            // 다시 돌아오는 경우에는 삭제될 블럭을 찾는 알고리즘을 실행시키지 않음
            if( isReturn )
                return;
            
            // 변경된 보드에서 삭제될 블럭이 있는 지 확인 후
            // 삭제될 블럭이 있으면 삭제하고 없으면 블럭을 다시 원위치
            if( !_blockRemover.removeBlocks(lhs, rhs) )
            {
                exchangeBlock(lhs, rhs, true);
            }
        }
            
        /**
         * 블럭 및 보드들의 정보를 갱신 
         */
        private function updateInfo(lhs:Block, rhs:Block):void
        {
            // block의 row, col 정보 갱신
            lhs.swapIndex(rhs);
            
            // BlockArray 정보 갱신
            var tmp:Block = _blockArray[lhs.row][lhs.col];
            _blockArray[lhs.row][lhs.col] = _blockArray[rhs.row][rhs.col];
            _blockArray[rhs.row][rhs.col] = tmp;
        }
        
        public function makeSpecialBlock(row:uint, col:uint, type:uint):void
        {
            switch( type )
            {
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_LINEAR:
                    _blockArray[row][col].type = Resources.BLOCK_TYPE_GHOST;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:
                    _blockArray[row][col].type *= Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_GOGGLE_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_UP_DOWN:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX;
                    break;
            }
            
            GameBoard.instance.updateBoard(row, col, false);
            _blockPainter.changeTexture(_blockArray[row][col], _blockArray[row][col].type);
        }
        
        public function exchangeBlockType(block:Block, type:uint, requiredTextureChange:Boolean):void
        {
            block.type = type;
            
            if( requiredTextureChange )
            {
                _blockPainter.changeTexture(block, type);
            }
        }
        
        public function getBlocksByType(type:uint):Array
        {
            var result:Array = new Array();
            var rowCount:uint = _blockArray.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    if( _blockArray[i][j].type == type)
                    {
                        result.push( _blockArray[i][j]);
                    }
                }
            }
            
            return result;
        }
        
        public function drawBoard():void
        {
            _blockPainter.initBoard();
        }
        
        
        public function callbackConnectedBlock(connectedBlock:Array):void
        {
            _blockPainter.showHint(connectedBlock);
        }
        
        public function get blockArray():Vector.<Vector.<Block>>
        {
            return _blockArray;
        }
        
        public function get blockPainter():BlockPainter
        {
            return _blockPainter;
        }
        
        public function get movingBlockCount():uint
        {
            return _movingBlockCount;
        }
        public function set movingBlockCount(count:uint):void
        {
            _movingBlockCount = count;
        }

        //DEBUGGING
        public function debugging(block:Block=null):void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
			
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
            
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
            for(i = 0; i<rowCount; ++i)
            {
                str = "";
                for(j = 0; j<colCount; ++j)
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