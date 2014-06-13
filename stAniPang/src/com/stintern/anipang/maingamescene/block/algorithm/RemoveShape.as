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
        
        public static var SHAPE_COUNT:uint = 21;
        
        // Special Blocks
        public static var EXCHANGE_ARROWS:uint = 30;
        public static var EXCHANGE_GOGGLE_ARROW:uint = 31;
        public static var EXCHANGE_GOGGLES:uint = 32;
        
        public static var EXCHANGE_GHOST_NORMAL:uint = 33;
        public static var EXCHANGE_GHOST_ARROWS:uint = 34;
        public static var EXCHNAGE_GHOST_HEART:uint = 35;
        public static var EXCHANGE_GHOSTS:uint = 36; 
        
        public static var T2:Point = new Point(-2, 0);
        public static var T:Point = new Point(-1, 0);
        public static var B2:Point = new Point(2, 0);
        public static var B:Point = new Point(-1, 0);
        public static var R2:Point = new Point(0, 2);
        public static var R:Point = new Point(0, 1);
        public static var L2:Point = new Point(0, -2);
        public static var L:Point = new Point(0, -1);
        public static var M:Point = new Point(0, 0);
        
        public static function getPositionArrayByType(type:uint):Array
        {
            switch(type)
            {
                case 0:                 return new Array(T2, T, M, B, B2);
                case 1:                 return new Array(L2, L, M, R, R2);
                    
                case 2:                 return new Array(L2, L, M, T, T2);
                case 3:                 return new Array(L2, L, M, B, B2);
                case 4:                 return new Array(R2, R, M, B, B2);
                case 5:                 return new Array(T2, T, M, R, R2);
                case 6:                 return new Array(L, T, M, R, B);
                    
                case 7:                 return new Array(L2, L, M, T, B);
                case 8:                 return new Array(T2, T, M, L, R);
                case 9:                 return new Array(T, B, M, R, R2);
                case 10:               return new Array(L, R, M, B, B2);
                    
                case 11:               return new Array(T2, T, M, B);
                case 12:               return new Array(T, M, B, B2);
                case 13:               return new Array(L2, L, M, R);
                case 14:               return new Array(L, M, R, R2);
                    
                case 15:               return new Array(T2, T, M);
                case 16:               return new Array(L2, L, M);
                case 17:               return new Array(M, B, B2);
                case 18:               return new Array(M, R, R2);
                case 19:               return new Array(T, M, B);
                case 20:               return new Array(L, M, R);
                    
                default:
                    return null;
            }
        }
    }
}







