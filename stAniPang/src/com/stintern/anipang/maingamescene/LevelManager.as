package com.stintern.anipang.maingamescene
{
    import com.stintern.anipang.maingamescene.block.BlockManager;
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.LevelLoader;
    import com.stintern.anipang.utils.Resources;

    public class LevelManager
    {
        // 싱글톤 관련
        private static var _instance:LevelManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _currentStageLevel:uint;
        private var _levelLoader:LevelLoader = null;
        
        public function LevelManager()
        {
            if (!_creatingSingleton){
                throw new Error("[LevelManager] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():LevelManager
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new LevelManager();
                _creatingSingleton = false;
            }
            return _instance;
        }
                
        public function loadStageInfo(level:uint):StageInfo
        {
            if( _levelLoader == null )
            {
                _levelLoader = new LevelLoader();
            }
            
            _currentStageLevel = level;
            
            var filePath:String = Resources.PATH_LEVEL_XML + level.toString() + ".xml";
            return _levelLoader.getStageInfo( AssetLoader.instance.loadXML(filePath) );
        }
        
        public function get currentStageLevel():uint
        {
            return _currentStageLevel;
        }
        public function set currentStageLevel(level:uint):void
        {
            _currentStageLevel = level;
        }
        
    }
}