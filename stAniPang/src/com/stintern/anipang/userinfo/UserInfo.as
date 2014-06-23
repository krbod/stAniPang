package com.stintern.anipang.userinfo
{
	public class UserInfo
	{
		// 싱글톤 관련
		private static var _instance:UserInfo;
		private static var _creatingSingleton:Boolean = false;
		
		private var _currentStage:uint;
		
		private var _stageScore:Vector.<uint>;
		private var _stageStarCount:Vector.<uint>;
		
		public function UserInfo()
		{
			if (!_creatingSingleton){
				throw new Error("[UserInfo] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
			}
		}
		
		public static function get instance():UserInfo
		{
			if (!_instance){
				_creatingSingleton = true;
				_instance = new UserInfo();
				_creatingSingleton = false;
			}
			return _instance;
		}
		
		public function init():void
		{
			_stageScore = new Vector.<uint>();
			_stageStarCount = new Vector.<uint>();
		}
		
		public function loadUserInfo(xml:XML):void
		{
			_currentStage = xml.child("currentStage")[0];
			var stageList:XMLList= xml.child("stageClearInfo").child("stage");
			
			for(var i:uint=0; i<_currentStage-1; ++i)
			{
				_stageScore.push(stageList[i].score);
				_stageStarCount.push(stageList[i].star);
			}
		}
		
		public function saveUserInfo():Boolean
		{
			return true;
		}
		
		public function get currentStage():uint
		{
			return _currentStage;
		}
        
        public function getStarCountAt(stage:uint):uint
        {
            return _stageStarCount[stage-1];
        }
        
        public function getScoreAt(stage:uint):uint
        {
            return _stageScore[stage-1];
        }
        
	}
}