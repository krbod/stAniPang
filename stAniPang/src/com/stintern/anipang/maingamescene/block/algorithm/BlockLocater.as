package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.maingamescene.block.Block;
    import com.stintern.anipang.utils.Resources;

    public class BlockLocater
    {
        private var _row:uint;
        private var _col:uint;
        
        public function BlockLocater()
        {
        }
        
		/**
		 * 블럭 보드의 좌측 및 상단의 블럭을 확인하여 연결되지 않도록 블럭의 새로운 타입을 생성합니다. 
		 * @param blockArray 블럭 배열
		 * @param row 생성할 블럭의 row Index
		 * @param col 생성할 블럭의 col Index
		 * @return 
		 * 
		 */
        public function makeNewType(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):uint
        {
            _row = row;
            _col = col;
            
            switch( row )
            {
                case 0:
                case 1:
                    return inCaseRow0_1(blockArray);
                    
                default:
                    return inCaseRow2(blockArray);
            }
        }
        
        private function inCaseRow0_1(blockArray:Vector.<Vector.<Block>>):uint
        {
            switch(_col)
            {
                case 0:
                case 1:
                    return getRandom();
                
                default:
                    return getRandom( checkLeftSide(blockArray) );
            }
        }
        
        private function inCaseRow2(blockArray:Vector.<Vector.<Block>>):uint
        {
            switch(_col)
            {
                case 0:
                case 1:
                    return getRandom( checkUpSide(blockArray) );

                default:
                    return getRandom( checkUpSide(blockArray), checkLeftSide(blockArray) ); 
            }
        }
        
        private function checkLeftSide(blockArray:Vector.<Vector.<Block>>):uint
        {
			if( blockArray[_row][_col-2] == null || blockArray[_row][_col-1] == null)
				return -1;
			
            var first:uint = blockArray[_row][_col-2].type;
            var second:uint = blockArray[_row][_col-1].type;
            if( first == second )
                return first
            
            return -1;
        }
        
        private function checkUpSide(blockArray:Vector.<Vector.<Block>>):uint
        {
			if( blockArray[_row-2][_col] == null || blockArray[_row-1][_col] == null )
				return -1;
			
            var first:uint = blockArray[_row-2][_col].type;
            var second:uint = blockArray[_row-1][_col].type;
            if( first == second )
                return first
            
            return -1;
        }
        
        private function getRandom(... except):uint
        {
            var result:uint = uint(Math.random() * Resources.BLOCK_TYPE_COUNT) + Resources.BLOCK_TYPE_START;
            for(var i:uint=0; i<except.length; ++i)
            {
                if( except[i] == result )
                {
                    return getRandom(except[0], except[1]);
                }
            }
            
            return result;
        }
    }
}