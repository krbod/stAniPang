package com.stintern.anipang.maingamescene.block.algorithm
{
    public class ConnectedShape
    {
        public static var SHAPE_COUNT:uint = 16;
        
        public static function getShapeIndiceAt(shapeNo:uint):Array
        {
            switch( shapeNo )
            {
                case 0:
                    return new Array(-3, 0, -2, 0); //TTXB
                    
                case 1:
                    return new Array(0, 2, 0, 3);   //LXRR
                    
                case 2:
                    return new Array(2, 0, 3, 0);   //TXBB
                    
                case 3:
                    return new Array(0, -3, 0, -2); //LLXR
                    
                case 4:
                    return new Array(1, -2, 1, -1); //LLXT
                    
                case 5:
                    return new Array(-1, -2, -1, -1);   //LLXB
                    
                case 6:
                    return new Array(1, 1, 1, 2);   //TXRR
                    
                case 7:
                    return new Array(-1, 1, -1, 2); //BXRR
                    
                case 8:
                    return new Array(-2, 1, -1, 1); //LXTT
                    
                case 9:
                    return new Array(1, 1, 2, 1);   //LXBB
                    
                case 10:
                    return new Array(-2, -1, -1, -1);   //TTXR
                    
                case 11:
                    return new Array(1, -1, 2, -1);     //BBXR
                    
                case 12:
                    return new Array(-1, -1, 1, -1);    //LT, LB
                    
                case 13:
                    return new Array(-1, -1, -1, 1);    //LT, RT
                    
                case 14:
                    return new Array(-1, 1, 1, 1);      //RT, RB
                    
                case 15:
                    return new Array(1, -1, 1, 1);      //LB, RB
            
                default:
                    return null;
            }
            
                
            
        }
    }
}