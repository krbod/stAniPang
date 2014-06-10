package com.stintern.anipang.maingamescene.block.algorithm
{
    public class BlockRemoverResult
    {
        private var _row:uint, _col:uint;
        private var _type:uint;
        private var _removePos:String;
        
        public static var TYPE_RESULT_5_BLOCKS_LINEAR:uint = 0;
        public static var TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:uint = 1;
        public static var TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:uint = 2;
        public static var TYPE_RESULT_4_BLOCKS_UP_DOWN:uint = 3;
        public static var TYPE_RESULT_3_BLOCKS:uint = 4;
        
        public function BlockRemoverResult(row:uint, col:uint, type:uint, removePos:String)
        {
            switch( type )
            {
                case RemoveShape.TTMBB:
                case RemoveShape.LLMRR:
                    _type = TYPE_RESULT_5_BLOCKS_LINEAR;
                    break;
                
                case RemoveShape.LLMTT: 
                case RemoveShape.LLMBB:
                case RemoveShape.RRMBB:
                case RemoveShape.TTMRR: 
                case RemoveShape.LTMRB:
                    _type = TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE;
                    break;
                
                case RemoveShape.TTMB: 
                case RemoveShape.TMBB:
                    _type = TYPE_RESULT_4_BLOCKS_LEFT_RIGHT;
                    break;
                
                case RemoveShape.LLMR: 
                case RemoveShape.LMRR:
                    _type = TYPE_RESULT_4_BLOCKS_UP_DOWN;
                    break;
                
                default:
                    _type = TYPE_RESULT_3_BLOCKS;
                    break;
            }
            
            _row = row;
            _col = col;
            _removePos = removePos;
        }
        
        public function get row():uint
        {
            return _row;
        }
        
        public function get col():uint
        {
            return _col;
        }
        
        public function get type():uint
        {
            return _type;
        }
        
        public function get removePos():String
        {
            return _removePos;
        }
    }
}
