package com.stintern.anipang.utils
{
    public class Resources
    {
        /** Layer name */
        public static var LAYER_MAIN_SCENE:String = "LAYER_MAIN_SCENE";
        public static var LAYER_MAIN_GAME:String = "LAYER_MAIN_GAME";
        public static var LAYER_COMPONENT:String = "LAYER_COMPONENT";
        
        
        
        /** Directory Path */
        public static var PATH_LEVEL_XML:String = "res/dat/";
        

        /** Image Path */
        public static var PATH_IMAGE_BLOCK_SPRITE_SHEET:String = "res/img/block_sprite_sheet.png";
        
        
        /** Image XML */
        public static var PATH_XML_BLOCK_SPRITE_SHEET:String = "res/img/block_sprite_sheet.xml";
        
        
        /** XML */
        
        // XML Element
        public static var ELEMENT_NAME_OF_ROOT:String = "levelInfo";
        public static var ELEMENT_NAME_OF_BOARD_INFO:String = "board";
        public static var ELEMENT_NAME_OF_MOVE_LIMIT:String = "move_limit";
        public static var ELEMENT_NAME_OF_MISSION:String = "misson";
        
        // Mission Property        
        public static var MISSION_PROPERTY_SCORE:String = "score";
        
        
        public static var BLOCK_TYPE_START:uint = 0;
        public static var BLOCK_TYPE_ARI:uint = 0;
        public static var BLOCK_TYPE_MICKY:uint = 1;
        public static var BLOCK_TYPE_LUCY:uint = 2;
        public static var BLOCK_TYPE_BLUE:uint = 3;
        public static var BLOCK_TYPE_PINKY:uint = 4;
        public static var BLOCK_TYPE_ANI:uint = 5;
        public static var BLOCK_TYPE_PANG:uint = 6;
        public static var BLOCK_TYPE_MONGYI:uint = 7;
        public static var BLOCK_TYPE_END:uint = 7;
        public static var BLOCK_TYPE_COUNT:uint = BLOCK_TYPE_END + 1;
        

        /** Game Enviroment */

        public static var BOARD_ROW_COUNT:uint = 8;
        public static var BOARD_COL_COUNT:uint = 8;
        
        public static var SCREEN_WIDTH:uint = 768;
        public static var SCREEN_HEIGHT:uint = 1024; 
        
        public static var LEFT_RIGHT_PADDING:uint = 20; 

    }
}