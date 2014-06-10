package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.block.algorithm.BlockLocater;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockRemover;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockRemoverResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
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
        private var _isBlockExchaning:Boolean = false;
        private var _blockRemover:BlockRemover;

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
            
            _blockRemover = new BlockRemover();
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
                        block.image.x = i*60;
                        block.image.y = j*60;
						
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
            }
            
            return blockType;
        }
        
        /**
         * 새로운 블럭을 생성합니다.  
         * @param type 생성할 블럭의 타입
         * @param autoRegister 블럭 매니저에 등록하여 바로 화면에 출력할 지 여부
         * @return 생성한 블럭
         */
        private function createBlock(type:uint, autoRegister:Boolean = true):Block
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
            _blockPool.push(block);
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

            function onStartExchangeBlock():void
            {
                _isBlockExchaning = true;
                _blockPainter.turnOnFlatten(false);
            }
            function onCompleteExchangeBlock():void
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
        
        private function removeBlocks(result:Array):Boolean
        {
            if( result[0] == null && result[1] == null )
                return false;
            
            for(var i:uint=0; i<2; ++i)
            {
                if( result[i] == null )
                    continue;
                    
                var removerResult:BlockRemoverResult = result[i] as BlockRemoverResult;
                
                var stringArray:Array = removerResult.removePos.split(",");
                
                var length:uint = stringArray.length;
                for(var j:uint=0; j<length; ++j)
                {
                    var row:uint = removerResult.row;
                    var col:uint = removerResult.col;
                    
                    if( stringArray[j] == "T2" )
                    {
                        row -= 2;
                    }
                    else if( stringArray[j] == "L2")
                    {
                        col -= 2;
                    }
                    else if( stringArray[j] == "B2")
                    {
                        row += 2;   
                    }
                    else if( stringArray[j] == "R2")
                    {
                        col += 2;
                    }
                    else if( stringArray[j] == "T" )
                    {
                        row -= 1;   
                    }
                    else if( stringArray[j] == "L")
                    {
                        col -= 1;  
                    }
                    else if( stringArray[j] == "B")
                    {
                        row += 1;
                    }
                    else if( stringArray[j] == "R")
                    {
                        col += 1;  
                    }
                    
                    // Block 제거
                    removeBlock(_blockArray[row][col]);
                    
                    // Board 정보 갱신
                    GameBoard.instance.boardArray[row][col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
                }
                

            }
            
            return true;
               
        }
    }
}