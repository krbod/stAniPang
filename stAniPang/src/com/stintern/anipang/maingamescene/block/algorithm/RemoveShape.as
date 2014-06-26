package com.stintern.anipang.maingamescene.block.algorithm
{
    import flash.geom.Point;

    public class RemoveShape
    {
        //5개 일직선
        public static var TTMBB:uint = 0;     // ' │'
        public static var LLMRR:uint = 1;     // ' ─ '
        
        // 5개 교차
        public static var LLMTT:uint = 2;     // ' ┘' 
        public static var LLMBB:uint = 3;     // ' ┐'
        public static var RRMBB:uint = 4;     // '┌'
        public static var TTMRR:uint = 5;     // ' └ ' 
        public static var LTMRB:uint = 6;       // '┼' 
        
        public static var LLTMB:uint = 7;       // '┤'
        public static var TTLMR:uint = 8;       //'┴'
        public static var RRTMB:uint = 9;       //'├'
        public static var LMRBB:uint = 10;      //'┬'
        
        public static var TTMB:uint = 11;
        public static var TMBB:uint = 12;
        public static var LLMR:uint = 13;
        public static var LMRR:uint = 14;
        public static var TTM:uint = 15;
        public static var LLM:uint = 16;
        public static var MBB:uint = 17;
        public static var MRR:uint = 18;
        public static var TMB:uint = 19;
        public static var LMR:uint = 20;
		
		public static var SHAPE_START:uint = 0;
		public static var SHAPE_END:uint = 20;
        
        public static var SHAPE_COUNT:uint = SHAPE_END - SHAPE_START + 1;
        
        // Special Blocks
        public static var EXCHANGE_ARROWS:uint = 30;
        public static var EXCHANGE_GOGGLE_ARROW:uint = 31;
        public static var EXCHANGE_GOGGLES:uint = 32;
        
        public static var EXCHANGE_GHOST_NORMAL:uint = 33;
        public static var EXCHANGE_GHOST_ARROWS:uint = 34;
        public static var EXCHNAGE_GHOST_HEART:uint = 35;
        public static var EXCHANGE_GHOSTS:uint = 36; 
        
		// Points
        public static var T2:Point = new Point(-2, 0);
        public static var T:Point = new Point(-1, 0);
        public static var B2:Point = new Point(2, 0);
        public static var B:Point = new Point(1, 0);
        public static var R2:Point = new Point(0, 2);
        public static var R:Point = new Point(0, 1);
        public static var L2:Point = new Point(0, -2);
        public static var L:Point = new Point(0, -1);
        public static var M:Point = new Point(0, 0);
        
        public static function getPositionArrayByType(type:uint):Array
        {
            switch(type)
            {
                case TTMBB:                 return new Array(T2, T, M, B, B2);
                case LLMRR:                 return new Array(L2, L, M, R, R2);
                    
                case LLMTT:                 return new Array(L2, L, M, T, T2);
                case LLMBB:                 return new Array(L2, L, M, B, B2);
                case RRMBB:                 return new Array(R2, R, M, B, B2);
                case TTMRR:                 return new Array(T2, T, M, R, R2);
                case LTMRB:                 return new Array(L, T, M, R, B);
                    
                case LLTMB:                 return new Array(L2, L, M, T, B);
                case TTLMR:                 return new Array(T2, T, M, L, R);
                case RRTMB:                 return new Array(T, B, M, R, R2);
                case LMRBB:               	return new Array(L, R, M, B, B2);
                    
                case TTMB:               	return new Array(T2, T, M, B);
                case TMBB:               	return new Array(T, M, B, B2);
                case LLMR:               	return new Array(L2, L, M, R);
                case LMRR:               	return new Array(L, M, R, R2);
                    
                case TTM:               return new Array(T2, T, M);
                case LLM:               return new Array(L2, L, M);
                case MBB:               return new Array(M, B, B2);
                case MRR:               return new Array(M, R, R2);
                case TMB:               return new Array(T, M, B);
                case LMR:               return new Array(L, M, R);
                    
                default:
                    return null;
            }
        }
    }
}







