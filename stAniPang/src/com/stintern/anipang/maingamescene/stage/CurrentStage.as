package com.stintern.anipang.maingamescene.stage
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;

	/**
	 * 현재 스테이지에 대한 정보를 포함하는 클래스 
	 */
    public class CurrentStage
    {
        // 싱글톤 관련
        private static var _instance:CurrentStage;
        private static var _creatingSingleton:Boolean = false;
        
        private var _currentStageLevel:uint;
        private var _stageLoader:StageLoader = null;	//XML 로부터 현재 스테이지 정보를 읽는 객체
        
        private var _stageInfo:StageInfo;
        
        public function CurrentStage()
        {
            if (!_creatingSingleton){
                throw new Error("[LevelManager] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():CurrentStage
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new CurrentStage();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        public function loadStageInfo(level:uint):void
        {
            if( _stageLoader == null )
            {
                _stageLoader = new StageLoader();
            }
            
            _currentStageLevel = level;
            
            var filePath:String = Resources.PATH_LEVEL_XML + level.toString() + ".xml";
            _stageInfo =  _stageLoader.getStageInfo( AssetLoader.instance.loadXMLDirectly(filePath) );
        }
        
        public function get currentStageLevel():uint
        {
            return _currentStageLevel;
        }
        public function set currentStageLevel(level:uint):void
        {
            _currentStageLevel = level;
        }
        
        public function get stageInfo():StageInfo
        {
            return _stageInfo;
        }

    }
}