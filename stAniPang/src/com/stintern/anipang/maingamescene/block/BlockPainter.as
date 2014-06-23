package com.stintern.anipang.maingamescene.block
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import flash.geom.Point;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

	/**
	 * 블럭 및 힌트를 그리는 일을 수행합니다. 
	 */
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
            
			_textureAtlas = AssetLoader.instance.loadTextureAtlas(Resources.ATALS_NAME_BLOCK);
            
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
        
		/**
		 * 블럭 벡터를 매개변수로 받아서 블럭들을 한번에 그립니다. 
		 */
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
        
		/**
		 * 블럭의 현재위치를 기준으로 블럭을 그리게 되고 블럭의 위치가 이전위치과 다르면
		 * TweenLite 를 이용해서 블럭을 이동시킵니다.
		 */
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
        
		/**
		 * 블럭의 텍스쳐를 교환합니다. 
		 * @param block 텍스쳐를 교환할 블럭
		 * @param type 교환할 텍스쳐의 타입
		 */
        public function changeTexture(block:Block, type:uint):void
        {
            _container.removeChild(block.image);
            
            var x:Number = block.image.x;
            var y:Number = block.image.y;
            
            block.disposeImage();
            block.setTexture( getTextureByType(type), x, y );
            
            _container.addChild(block.image);
        }
        
		/**
		 * 힌트를 표시합니다. 
		 * @param positions 힌트를 표시할 인덱스 포지션 배열
		 */
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
        
		/**
		 * 힌트들을 제거합니다. 
		 */
        public function disposeHint():void
        {
            for(var i:uint=0; i<3; ++i)
            {
                _container.removeChild(_hitImages[i]);   
            }
        }
        
		/**
		 * 블럭의 배열 인덱스를 바탕으로 실제 스크린 좌표를 반환합니다. 
		 * @param row row Index
		 * @param col col Index
		 * @param texture 블럭 텍스쳐
		 * @return Point 좌표
		 */
        private function getBlockPosition(row:uint, col:uint, texture:Texture):Point
        {
			return new Point(
				col * texture.width + Starling.current.stage.stageWidth  * 0.5 - texture.width * 4,
				texture.height * row + Starling.current.stage.stageHeight  * 0.5 - texture.height * 4
			);
        }
        
		/**
		 * 블럭의 인덱스를 바탕으로 이미지에 좌표를 입력합니다. 
		 */
        public function setImagePosition(image:Image, row:uint, col:uint):void
        {
            var pos:Point = getBlockPosition(row, col, image.texture);
            image.x = pos.x;
            image.y = pos.y;
            
            pos = null;
        }
        
        /**
         * 보드의 정보에 따라 보드를 그립니다.
         * (얼음이나 박스를 그림)
         */
        public function initBoard():void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            var rowCount:uint = board.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = board[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    initBoardAt(i, j, board[i][j]);
                }
            }
        }
        
        /**
         * 보드의 특정 인덱스의 타입을 보고 이미지를 생성해서
         * 화면에 그립니다. 
         */
        private function initBoardAt( i, j, type:uint ):void
        {
            var texture:Texture = getTextureByType(type);
            if(texture == null)
                return;
            
            var image:Image = new Image(texture);
            var pos:Point = getBlockPosition(i, j, texture);
            image.x = pos.x;
            image.y = pos.y;
            
            GameBoard.instance.boardImageArray[i][j] = image;
            
            _container.addChild(image);
        }
        
        /**
         * 게임 보드에서 특정 인덱스에 있는 이미지를 삭제하고 화면에 그리지 않습니다. 
         */
        public function removeBoardImageAt(i, j):void
        {
            if( GameBoard.instance.boardImageArray[i][j] == null )
                return;
            
            var image:Image = GameBoard.instance.boardImageArray[i][j];
            _container.removeChild(image);
            
            image.dispose();
        }
        
		/**
		 * 블럭의 타입을 바탕으로 텍스쳐를 반환합니다. 
		 * @param type 반환할 텍스쳐의 타입
		 */
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
                case Resources.BLOCK_TYPE_HINT:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_HINT);
                    
                    
                /** 게임 보드 관련 */
                case GameBoard.TYPE_OF_CELL_ICE:
                    return _textureAtlas.getTexture(Resources.TEXTURE_NAME_ICE);
                    
                default:
                    return null;
            }
        }
        
    }
}