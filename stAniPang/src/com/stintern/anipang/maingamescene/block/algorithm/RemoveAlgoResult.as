package com.stintern.anipang.maingamescene.block.algorithm
{
    public class RemoveAlgoResult
    {
        private var _row:uint, _col:uint;
        private var _type:uint;
        private var _removePos:Array;
        private var _cleanRequired:Boolean;
        
        public static var TYPE_RESULT_5_BLOCKS_LINEAR:uint = 0;
        public static var TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:uint = 1;
        public static var TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:uint = 2;
        public static var TYPE_RESULT_4_BLOCKS_UP_DOWN:uint = 3;
        public static var TYPE_RESULT_3_BLOCKS:uint = 4;
        public static var TYPE_RESULT_EXCHANGE_SPECIAL_BLOCKS:uint = 5;
        public static var TYPE_RESULT_EXCHANGE_GHOST:uint = 6;
        
        public function RemoveAlgoResult(row:uint, col:uint, type:uint, removePos:Array, cleanRequired:Boolean)
        {
            switch( type )
            {
                case RemoveShape.LLMRR:
                case RemoveShape.TTMBB:
                    _type = TYPE_RESULT_5_BLOCKS_LINEAR;
                    break;
                
                case RemoveShape.LLMTT: 
                case RemoveShape.LLMBB:
                case RemoveShape.RRMBB:
                case RemoveShape.TTMRR: 
                case RemoveShape.LTMRB:
                case RemoveShape.LLTMB:
                case RemoveShape.TTLMR:
                case RemoveShape.RRTMB:
                case RemoveShape.LMRBB:
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
                
                case RemoveShape.EXCHANGE_ARROWS:
                case RemoveShape.EXCHANGE_GOGGLE_ARROW:
                case RemoveShape.EXCHANGE_GOGGLES:
                    _type = TYPE_RESULT_EXCHANGE_SPECIAL_BLOCKS;
                    break;
                
                case RemoveShape.EXCHANGE_GHOST_NORMAL:
                    _type = TYPE_RESULT_EXCHANGE_GHOST;
                
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
        
        public function get removePos():Array
        {
            return _removePos;
        }
        
        public function get cleanRequired():Boolean
        {
            return _cleanRequired;
        }
    }
}
