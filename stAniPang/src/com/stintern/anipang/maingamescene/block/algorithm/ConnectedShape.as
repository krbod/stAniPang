package com.stintern.anipang.maingamescene.block.algorithm
{
    public class ConnectedShape
    {
        public static var SHAPE_COUNT:uint = 16;
        
		/**
		 * 연결될 수 있는 모양의 다른 블럭들의 상대좌표를 리턴합니다. 
		 * @param shapeNo 연결될 수 있는 모양의 번호
		 * @return Array(x1, y1, x2, y2);
		 * 
		 */
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