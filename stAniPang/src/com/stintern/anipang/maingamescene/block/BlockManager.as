package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.block.algorithm.BlockLocater;
    import com.stintern.anipang.maingamescene.block.algorithm.ConnectedBlockFinder;
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import flash.utils.Dictionary;
    
    import starling.animation.Tween;
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
            
            if( _movingBlockCount == 0 )
            {
                // 블럭이 없어지고 새로운 블럭이 생긴 후 연결되는 블럭이 있는 지 확인 후 삭제
                _blockRemover.removeConnectedBlocks();
                
                var result:Array = _connectedBlockFinder.process();
                if( result == null )
                {
                    trace("연결된 블럭이 없습니다.");
					debugging();
					
                   	recreateBoard();        
					
					debugging();
                }
            }
        }
        
        private function moveBlocks():void
        {
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
            var rowCount:uint = _blockArray.length;
            for(var i:int=rowCount-1; i>=0; --i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    var block:Block = _blockArray[i][j];    // 비워있는 보드칸이면 null 반환
                    if(block == null || block.row == Resources.BOARD_ROW_COUNT - 1)
                    {
                        continue;
                    }
                    
                        
                    // 아래가 블록으로 채워져야하는 칸이면 낙하
                    if( boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED )
                    {
                        moveBlock(block);
                    }
                }
            }
            
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
					block.image.y = block.image.texture.height * -1 + Starling.current.stage.stageHeight  * 0.5 - block.image.texture.height * 4;

                    boardArray[0][i] = block.type;
                    _blockArray[block.row][block.col] = block;
                    
                    block.drawRequired = true;
				}
			}
		}
        
        /**
         * 블럭을 아래로 낙하시킵니다. 
         * @param block 아래로 낙하할 블럭
         */
        private function moveBlock(block:Block):void
        {
            // 정보 갱신
            block.row += 1;
            GameBoard.instance.boardArray[block.row][block.col] = block.type;
            GameBoard.instance.boardArray[block.row-1][block.col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
            
            _blockArray[block.row][block.col] = block;
            _blockArray[block.row-1][block.col] = null;
            
            block.drawRequired = true;
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
                        
                        // 블럭 이미지 위치를 설정
                        _blockPainter.setBlockImage(block.image, i, j);
                    }
                    
                    colVector.push(  block );
                }
                _blockArray.push( colVector );
            }
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
		
		private function recreateBoard():void
		{
			var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
			var rowCount:uint = Resources.BOARD_ROW_COUNT;
			var colCount:uint = Resources.BOARD_ROW_COUNT;
			
			// 보드를 재배열한 후에 특수블럭은 그대로 남아 있어야 되기 때문에
			//기존에 있던 블록중에 특수 블럭의 타입을 저장
			var dic:Dictionary = new Dictionary();
			for(var i:uint = 0; i<rowCount; ++i)
			{
				for(var j:uint = 0; j<colCount; ++j)
				{
					var block:Block = _blockArray[i][j];
					if( block == null )
						return;
					
					if( block.type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START && 
						block.type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
					{
						if( dic[type] == null )
							dic[type] = 1;
						else
							dic[type] += 1;
					}
				}
			}
			
			// 풀에 저장한 블록들을 바탕으로 보드를 재배열
			for(i = 0; i<rowCount; ++i)
			{
				for(j = 0; j<colCount; ++j)
				{
					if(_blockArray[i][j] == null)
						continue;
					
					// 새로운 타입을 생성
					var type:uint = _blockLocater.makeNewType(board, i, j);
					
					// 저장해놓은 특수블럭과 같은 타입이면 특수블럭으로 생성
					if( dic[type*10] != null && dic[type*10] > 0 )
					{
						type = type * 10;
						dic[type*10]--;
					}
					else if( dic[type * 10 + 1] != null && dic[type * 10 + 1] > 0 )
					{
						type = type * 10 + 1;
						dic[type*10+1]--;
					}
					else if( dic[type * 10 + 2] != null && dic[type * 10 + 2] > 0 )
					{
						type = type * 10 + 2;
						dic[type*10+2]--;
					}	
					else if( dic[90] != null && dic[90] > 0 )
					{
						type = 90;
					}
						
					
					// 블럭의 이미지를 변경
					_blockPainter.changeTexture(_blockArray[i][j], type);
					_blockArray[i][j].type = type;
					
					//새롭게 생성한 타입으로 보드를 초기화
					board[i][j] = _blockArray[i][j].type;
				}
			}
			
			dic = null;
		}
        
        public function registerBlock(block:Block):void
        {
            _blockPainter.addBlock(block.image);
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
            }
            
            // 2개의 트윈이 모드 완료한 뒤에 블럭의 정보를 갱신
            var completeCount:uint = 0;
            function onCompleteExchangeBlock():void
            {
                ++completeCount;
                if(completeCount == 2)
                    updateBlocks(row1, col1, row2, col2, isReturn);
                
                tween = null;
                tween2 = null;
                
                // 블럭을 움직였을 경우에 연결된 블럭을 찾는 것을 리셋
                _connectedBlockFinder.reset();
            }
        }
        
        private function updateBlocks(row1:uint, col1:uint, row2:uint, col2:uint, isReturn:Boolean):void
        {
            _isBlockExchaning = false; 
            
            // 변경한 블럭들로 정보 변경
            updateInfo(row1, col1, row2, col2);
            
            // 다시 돌아오는 경우에는 삭제될 블럭을 찾는 알고리즘을 실행시키지 않음
            if( isReturn )
                return;
            
            // 변경된 보드에서 삭제될 블럭이 있는 지 확인 후
            // 삭제될 블럭이 있으면 삭제하고 없으면 블럭을 다시 원위치
            if( !_blockRemover.removeBlocks(row1, col1, row2, col2) )
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
        
        public function makeSpecialBlock(row:uint, col:uint, type:uint):void
        {
            switch( type )
            {
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_LINEAR:
                    _blockArray[row][col].type = Resources.BLOCK_TYPE_STAR;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:
                    _blockArray[row][col].type *= Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_HEART_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_UP_DOWN:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_3_BLOCKS:
                    _blockRemover.removeBlockAt(row, col);
                    break;
            }
            
            if( type != RemoveAlgoResult.TYPE_RESULT_3_BLOCKS )
            {
                GameBoard.instance.boardArray[row][col] = _blockArray[row][col].type
                _blockPainter.changeTexture(_blockArray[row][col], _blockArray[row][col].type);
            }
        }
        
        public function callbackConnectedBlock(connectedBlock:Array):void
        {
            trace(connectedBlock[0], connectedBlock[1], connectedBlock[2], connectedBlock[3], connectedBlock[4], connectedBlock[5] );      
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
//            trace("block");
//            for(i = 0; i<rowCount; ++i)
//            {
//                str = "";
//                for(j = 0; j<colCount; ++j)
//                {
//                    if(_blockArray[i][j] == null )
//                        str += "0, ";
//                    else
//                        str += _blockArray[i][j].type.toString() + ", ";
//                }
//                trace( str );
//            }
            
            
            //for(var i:uint=0; i<10; ++i)
            
//            trace("a : " + block.image.x, block.image.y);
//            
//            TweenLite.to(block.image, 3, {x:block.image.x, y:block.image.y+100, onComplete:onTest});
//            
//            function onTest():void
//            {
//                trace(block.image.x, block.image.y);
//            }
        }

    }
}