package com.stintern.anipang.maingamescene.block.algorithm
{
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
        
        public static function getStringAt(type:uint):String
        {
            switch(type)
            {
                case 0:                 return "T2,T,M,B,B2";
                case 1:                 return "L2,L,M,R,R2";
                case 2:                 return "L2,L,M,T,T2";
                case 3:                 return "L2,L,M,B,B2";
                case 4:                 return "R2,R,M,B,B2";
                case 5:                 return "T2,T,M,R,R2";
                case 6:                 return "L,T,M,R,B";
                    
                case 7:                 return "L2,L,M,T,B";
                case 8:                 return "T2,T,M,L,R";
                case 9:                 return "T,B,M,R,R2";
                case 10:                return "L,R,M,B,B2";
                    
                case 11:                 return "T2,T,M,B";
                case 12:                 return "T,M,B,B2";
                case 13:                 return "L2,L,M,R";
                case 14:               return "L,M,R,R2";
                case 15:               return "T2,T,M";
                case 16:               return "L2,L,M";
                case 17:               return "M,B,B2";
                case 18:               return "M,R,R2";
                case 19:               return "T,M,B";
                case 20:               return "L,M,R";
                    
                default:
                    return null;
            }
        }
    }
}







