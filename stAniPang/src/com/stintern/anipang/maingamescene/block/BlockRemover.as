package com.stintern.anipang.maingamescene.block
{
    import com.stintern.anipang.utils.Resources;

    public class BlockRemover
    {
        private var _blockPool:BlockPool;
        
        public function BlockRemover(pool:BlockPool)
        {
            _blockPool = pool;
        }
        
        public function removeBlock(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):void
        {
            var block:Block = blockArray[row][col];
            
            if( block == null )
                return;
            
            if( block.type > Resources.BLOCK_TYPE_END )
            {
                blockArray[block.row][block.col] = null;
                
                block.dispose();
                block = null;
                
                return;
            }
            
            _blockPool.push(block);
            blockArray[block.row][block.col] = null;
        }
    }
}