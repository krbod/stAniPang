package com.stintern.anipang.maingamescene.block
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
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
        
        private var _hitImages:Array;
        
        private var _textureWidth:Number, _textureHeight:Number;
        
        public function BlockPainter()
        {
            _container = new Sprite();
            addChild(_container);
            
			_textureAtlas = AssetLoader.instance.loadTextureAtlas(Resources.IMAGE_NAME_BLOCK_SPRITE_SHEET);
            
            _hitImages = new Array();
            for(var i:uint=0; i<3; ++i)
            {
                _hitImages.push( new Image(getTextureByType(Resources.BLOCK_TYPE_HINT)) );
                _hitImages[i].touchable = false;
            }
        }
        
        public function addBlock(image:Image):void
        {
            _container.addChild(image);
        }
        public function removeBlock(image:Image):void
        {
            _container.removeChild(image);
        }
        
        public function drawBlocks(blocks:Vector.<Vector.<Block>>):void
        {
            var rowCount:uint = blocks.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = blocks[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    if(blocks[i][j] == null )
                        continue;
                    
                    drawBlock(blocks[i][j]);
                }
            }
            
        }
        
        private function drawBlock(block:Block):void
        {
            if( !block.drawRequired )
                return;
            
            var pos:Point = getBlockPosition(block.row, block.col, block.image.texture);
            
            var speed:Number = 0.2 * ( pos.y - block.image.y ) / block.image.texture.height;
            if( speed < 0.2 )
                speed = 0.2;
            
            block.drawRequired = false;
            TweenLite.to(block.image, speed, {x:pos.x, y:pos.y, onComplete:onMoveComplete, ease:Linear.easeNone});
            
            if( block.isMoving == false)
                BlockManager.instance.movingBlockCount++;
            
            block.isMoving = true;
            
            function onMoveComplete():void
            {
                BlockManager.instance.movingBlockCount--;
                block.isMoving = false;
            }
        }
        
        public function changeTexture(block:Block, type:uint):void
        {
            _container.removeChild(block.image);
            
            var x:Number = block.image.x;
            var y:Number = block.image.y;
            
            block.disposeImage();
            block.setTexture( getTextureByType(type), x, y );
            
            _container.addChild(block.image);
        }
        
        public function showHint(positions:Array):void
        {
            for(var i:uint=0; i<3; ++i)
            {
                var pos:Point = getBlockPosition(positions[i*2], positions[i*2+1], _hitImages[i].texture);
                _hitImages[i].x = pos.x;
                _hitImages[i].y = pos.y;
                
                _container.addChild(_hitImages[i]);
                pos = null;
            }
            
            positions = null;
        }
        
        public function disposeHint():void
        {
            for(var i:uint=0; i<3; ++i)
            {
                _container.removeChild(_hitImages[i]);   
            }
        }
        
        private function getBlockPosition(row:uint, col:uint, texture:Texture):Point
        {
			return new Point(
				col * texture.width + Starling.current.stage.stageWidth  * 0.5 - texture.width * 4,
				texture.height * row + Starling.current.stage.stageHeight  * 0.5 - texture.height * 4
			);
        }
        
        public function setBlockImage(image:Image, row:uint, col:uint):void
        {
            var pos:Point = getBlockPosition(row, col, image.texture);
            image.x = pos.x;
            image.y = pos.y;
            
            pos = null;
        }
        
        public function getTextureByType(type:uint):Texture
        {
            switch(type)
            {
                case Resources.BLOCK_TYPE_ARI:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ARI);
                    
                case Resources.BLOCK_TYPE_MICKY:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MICKY);
                    
                case Resources.BLOCK_TYPE_LUCY:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_LUCY);
                    
                case Resources.BLOCK_TYPE_BLUE:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BLUE);
                    
                case Resources.BLOCK_TYPE_PINKY:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_PINKY);
                    
                case Resources.BLOCK_TYPE_ANI:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ANI);
                    
                case Resources.BLOCK_TYPE_MONGYI:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MONGYI);
                    
                    
                case Resources.BLOCK_TYPE_ARI_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ARI_HEART);
                case Resources.BLOCK_TYPE_ARI_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ARI_LR_ARROW);
                case Resources.BLOCK_TYPE_ARI_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ARI_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_MICKY_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MICKY_HEART);
                case Resources.BLOCK_TYPE_MICKY_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MICKY_LR_ARROW);
                case Resources.BLOCK_TYPE_MICKY_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MICKY_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_LUCY_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_LUCY_HEART);
                case Resources.BLOCK_TYPE_LUCY_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_LUCY_LR_ARROW);
                case Resources.BLOCK_TYPE_LUCY_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_LUCY_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_PINKY_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_PINKY_HEART);
                case Resources.BLOCK_TYPE_PINKY_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_PINKY_LR_ARROW);
                case Resources.BLOCK_TYPE_PINKY_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_PINKY_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_ANI_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ANI_HEART);
                case Resources.BLOCK_TYPE_ANI_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ANI_LR_ARROW);
                case Resources.BLOCK_TYPE_ANI_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ANI_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_MONGYI_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MONGYI_HEART);
                case Resources.BLOCK_TYPE_MONGYI_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MONGYI_LR_ARROW);
                case Resources.BLOCK_TYPE_MONGYI_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_MONGYI_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_BLUE_HEART:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BLUE_HEART);
                case Resources.BLOCK_TYPE_BLUE_LR_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BLUE_LR_ARROW);
                case Resources.BLOCK_TYPE_BLUE_TB_ARROW:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BLUE_TB_ARROW);
                    
                case Resources.BLOCK_TYPE_GHOST:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_STAR);
                case Resources.BLOCK_TYPE_BOX:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BOX);
                case Resources.BLOCK_TYPE_BOX_CROSS_HALF:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_STAR);
                case Resources.BLOCK_TYPE_BOX_CROSS:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_BOX_CROSS);
                case Resources.BLOCK_TYPE_ICE:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ICE);
                       
                case Resources.BLOCK_TYPE_HINT:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_HINT);
                    
                default:
                    return null;
            }
        }
        
    }
}