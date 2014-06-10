package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import flash.display.Bitmap;
    import flash.geom.Point;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    public class BlockPainter extends Sprite
    {
        private var _container:Sprite;
        private var _textureAtlas:TextureAtlas;
        
        public function BlockPainter()
        {
            _container = new Sprite();
            addChild(_container);
            
            // TextureAtlas 생성
            var bitmap:Bitmap = AssetLoader.instance.getTextureBitmap( Resources.PATH_IMAGE_BLOCK_SPRITE_SHEET );
            _textureAtlas = new TextureAtlas(
                Texture.fromBitmap( bitmap ), 
                AssetLoader.instance.loadXML( Resources.PATH_XML_BLOCK_SPRITE_SHEET )
            );
        }
        
        public function addBlock(image:Image):void
        {
            _container.addChild(image);
        }
        
        public function drawBlocks(blocks:Vector.<Vector.<Block>>):void
        {
            var rowCount:uint = blocks.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = blocks[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    if(blocks[i][j] == null)
                        continue;
                    
                    var pos:Point = getBlockPosition(i, j, blocks[i][j].image.texture);
                    blocks[i][j].image.x = pos.x;
                    blocks[i][j].image.y = pos.y;
                }
            }
            
            _container.flatten();
        }
        
        public function draw():void
        {
            _container.flatten();
        }
        
        private function getBlockPosition(row:uint, col:uint, texture:Texture):Point
        {
			return new Point(
				col * texture.width + Starling.current.stage.stageWidth  * 0.5 - texture.width * 4,
				texture.height * row + 200
			);
        }
        
        public function getTextureByType(type:uint):Texture
        {
            switch(type)
            {
                case Resources.BLOCK_TYPE_ARI:
                    return _textureAtlas.getTexture("ari");
                    
                case Resources.BLOCK_TYPE_MICKY:
                    return _textureAtlas.getTexture("micky");
                    
                case Resources.BLOCK_TYPE_LUCY:
                    return _textureAtlas.getTexture("lucy");
                    
                case Resources.BLOCK_TYPE_BLUE:
                    return _textureAtlas.getTexture("blue");
                    
                case Resources.BLOCK_TYPE_PINKY:
                    return _textureAtlas.getTexture("pinky");
                    
                case Resources.BLOCK_TYPE_ANI:
                    return _textureAtlas.getTexture("ani");
                    
                case Resources.BLOCK_TYPE_PANG:
                    return _textureAtlas.getTexture("pang");
                    
                case Resources.BLOCK_TYPE_MONGYI:
                    return _textureAtlas.getTexture("mongyi");
                    
                    
                default:
                    return null;
            }
        }
        
        public function turnOnFlatten(turnOn:Boolean):void
        {
            if( turnOn )
                _container.flatten();
            else
                _container.unflatten();
        }
        
    }
}