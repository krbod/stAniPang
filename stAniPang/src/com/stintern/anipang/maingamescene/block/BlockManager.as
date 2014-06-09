package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import flash.display.Bitmap;
    
    import starling.display.QuadBatch;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    public class BlockManager
    {
        // 싱글톤 관련
        private static var _instance:BlockManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _blockArray:Vector.<Vector.<Block>>;
        
        private var _quadBatch:QuadBatch;
        private var _textureAtlas:TextureAtlas;
        private var _blockPool:BlockPool;
        
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
            // 블럭들을 그릴 배치 객체 생성
            _quadBatch = new QuadBatch();
            layer.addChild(_quadBatch);
            
            // TextureAtlas 생성
            var bitmap:Bitmap = AssetLoader.instance.getTextureBitmap( Resources.PATH_IMAGE_BLOCK_SPRITE_SHEET );
            _textureAtlas = new TextureAtlas(
                Texture.fromBitmap( bitmap ), 
                AssetLoader.instance.loadXML( Resources.PATH_XML_BLOCK_SPRITE_SHEET )
            );
            
            // 블럭을 저장할 풀 생성
            _blockPool = new BlockPool();
            
            // 블럭 배치 알고리즘 생성기 
            _locateBlockAlgorithm = new LocateBlockAlgorithm();
            
            _blockArray = new Vector.<Vector.<Block>>();
            
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
                    colVector.push( BlockManager.instance.createBlock(board[i][j]) );
                }
                _blockArray.push( colVector );
            }
            
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
            
            var texture:Texture = getTextureByType(Resources.BLOCK_TYPE_ANI);
            block  = new Block();
            block.init(type, texture);
            
            if( autoRegister)
            {
                registerBlock(block);
            }
            
            return block;
            
        }
        
        public function registerBlock(block:Block):void
        {
            _quadBatch.addImage(block.image);
        }
        
        public function removeBlock(block:Block):void
        {
            _blockPool.push(block);
        }
        
        private function getTextureByType(type:uint):Texture
        {
            switch(type)
            {
                case Resources.BLOCK_TYPE_ANI:
                    return _textureAtlas.getTexture("ani");
                    
                default:
                    return null;
            }
        }
    }
}