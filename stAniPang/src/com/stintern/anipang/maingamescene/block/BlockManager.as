package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.Resources;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class BlockManager
    {
        // 싱글톤 관련
        private static var _instance:BlockManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _blockArray:Vector.<Vector.<Block>>;
        private var _spriteContainer:Sprite;
        
        private var _blockPool:BlockPool;
        private var _drawManager:BlockPainter;
        
        private var _locateBlockAlgorithm:LocateBlockAlgorithm;
		
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
            // 블럭을 저장할 풀 생성
            _blockPool = new BlockPool();
            
            // 블럭 배치 알고리즘 생성기 
            _locateBlockAlgorithm = new LocateBlockAlgorithm();
            
            _blockArray = new Vector.<Vector.<Block>>();
            
            _drawManager = new BlockPainter();
            layer.addChild(_drawManager);
            
        }

        public function createBlocks(board:Vector.<Vector.<uint>>):void
        {
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
            
            _drawManager.drawBlocks(_blockArray);
        }
        
        private function getTypeOfBlock(board:Vector.<Vector.<uint>>, row:uint, col:uint):uint
        {
            var blockType:uint;
            switch(board[row][col])
            {
                case GameBoard.TYPE_OF_BLOCK_EMPTY:
                    return GameBoard.TYPE_OF_BLOCK_EMPTY;
                    
                case GameBoard.TYPE_OF_BLOCK_NONE:
                    return _locateBlockAlgorithm.makeNewType(board, row, col);
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
            block.init(type, _drawManager.getTextureByType(type));
            
            if( autoRegister)
            {
                registerBlock(block);
            }
            
            return block;
            
        }
        
        public function registerBlock(block:Block):void
        {
            _drawManager.addBlock(block.image);
        }
        
        public function removeBlock(block:Block):void
        {
            _blockPool.push(block);
        }
        
    }
}