package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.utils.Resources;
    
    import flash.utils.Dictionary;

    public class BlockPool
    {
        private var _blockPool:Dictionary;
        
        public function BlockPool()
        {
            // 각 Type 에 따라서 Pool 생성
            _blockPool = new Dictionary();
            for(var i:uint = Resources.BLOCK_TYPE_START; i<=Resources.BLOCK_TYPE_END; ++i)
            {
                _blockPool[i] = new Vector.<Block>();
				_blockPool[i * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_GOGGLE_INDEX] = new Vector.<Block>();
				_blockPool[i * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX] = new Vector.<Block>();
				_blockPool[i * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX] = new Vector.<Block>();
            }
            _blockPool[Resources.BLOCK_TYPE_GHOST] = new Vector.<Block>();
        }
        
        public function push(block:Block):void
        {
            _blockPool[block.type].push(block);
            
            block.visible = false;
        }

        
        public function getBlock(type:uint):Block
        {
            if( _blockPool[type].length == 0 )
            {
                return null;
            }
            
            var block:Block = _blockPool[type].pop();
            block.visible = true;
            
            return block;
        }
    }
}