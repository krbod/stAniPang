package com.stintern.anipang.maingamescene.block.algorithm
{
    import com.stintern.anipang.utils.Resources;

    public class BlockLocater
    {
        private var _board:Vector.<Vector.<uint>>;
        private var _row:uint;
        private var _col:uint;
        
        public function BlockLocater()
        {
        }
        
        public function makeNewType(board:Vector.<Vector.<uint>>, row:uint, col:uint):uint
        {
            _board = board;
            _row = row;
            _col = col;
            
            switch( row )
            {
                case 0:
                case 1:
                    return inCaseRow0_1();
                    
                default:
                    return inCaseRow2();
            }
        }
        
        private function inCaseRow0_1():uint
        {
            switch(_col)
            {
                case 0:
                case 1:
                    return getRandom();
                
                default:
                    return getRandom( checkUpSide() );
            }
        }
        
        private function inCaseRow2():uint
        {
            switch(_col)
            {
                case 0:
                case 1:
                    return getRandom( checkLeftSide() );

                default:
                    return getRandom( checkLeftSide(), checkUpSide() ); 
            }
        }
        
        private function checkUpSide():uint
        {
            var first:uint = _board[_row][_col-2];
            var second:uint = _board[_row][_col-1];
            if( first == second )
                return first
            
            return -1;
        }
        
        private function checkLeftSide():uint
        {
            var first:uint = _board[_row-2][_col];
            var second:uint = _board[_row-1][_col];
            if( first == second )
                return first
            
            return -1;
        }
        
        private function getRandom(... except):uint
        {
            var result:uint = uint(Math.random() * Resources.BLOCK_TYPE_COUNT);
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