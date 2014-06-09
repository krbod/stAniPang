package com.stintern.anipang.maingamescene.block
{
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
        
        private var _quadBatch:QuadBatch;
        private var _textureAtlas:TextureAtlas;
        private var _blockPool:BlockPool;
        
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
        }

        
        /**
         * 새로운 블럭을 생성합니다.  
         * @param type 생성할 블럭의 타입
         * @param autoRegister 블럭 매니저에 등록하여 바로 화면에 출력할 지 여부
         * @return 생성한 블럭
         */
        public function createBlock(type:uint, autoRegister:Boolean = true):Block
        {
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