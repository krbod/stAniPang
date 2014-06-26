package com.stintern.anipang.userinfo
{
    import com.stintern.anipang.utils.Resources;
    
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    
    import starling.display.Image;

	public class UserInfo
	{
		// 싱글톤 관련
		private static var _instance:UserInfo;
		private static var _creatingSingleton:Boolean = false;
		
		private var _currentStage:uint;
		
		private var _stageScore:Vector.<uint>;
		private var _stageStarCount:Vector.<uint>;
        
        private var _userImage:Image;
        private var _userName:String;
		
		private var _userInfoXML:XML;
		    
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
			_userInfoXML = xml;
			
			_currentStage = xml.child(Resources.XML_NODE_CURRENT_STAGE)[0];
			var stageList:XMLList= xml.child(Resources.XML_NODE_STAGE_CLEAR_INFO).child(Resources.XML_NODE_STAGE);
			
			for(var i:uint=0; i<=_currentStage-1; ++i)
			{
				_stageScore.push(stageList[i].score);
				_stageStarCount.push(stageList[i].star);
			}
		}
		
		public function updateUserInfo(stageLevel:uint, score:uint):void
		{
			if( _currentStage > stageLevel )
				return;
			
			_userInfoXML.child(Resources.XML_NODE_CURRENT_STAGE)[0] = stageLevel + 1;
			
			_userInfoXML.currentStage = stageLevel + 1;
			var xmlList:XMLList = _userInfoXML.child(Resources.XML_NODE_STAGE_CLEAR_INFO)[0].child(Resources.XML_NODE_STAGE);
			xmlList[stageLevel-1].star = 2;		// TEST
			xmlList[stageLevel-1].score = score;
			
			var xml:XML = <stage />;
			xml.@[Resources.XML_ATTRIBUTE_LEVEL] = stageLevel + 1;
			xml.star = 0;	
			xml.score = 0;
			
			_userInfoXML.child(Resources.XML_NODE_STAGE_CLEAR_INFO).appendChild(xml);
			exportXML(_userInfoXML);
		}
		
		public function exportXML(xml:XML):Boolean
		{
			var ba:ByteArray = new ByteArray();
			
			try
			{
				ba.writeUTFBytes(xml);
				
				trace(File.applicationStorageDirectory.resolvePath(Resources.XML_USER_INFO).nativePath);
				
				var file:File = new File(File.applicationStorageDirectory.resolvePath(Resources.XML_USER_INFO).nativePath);
				var fileStream:FileStream = new FileStream();
				
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(ba.toString());
				fileStream.close();
				
				ba.clear();
				ba = null;
				fileStream = null;
				
				return true;
			}
			catch(e:Error)
			{
				trace(e);
				throw new Error(e);
				
				ba = null;
				fileStream = null;
				
				return false;
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
        
        public function get userImage():Image
        {
            return _userImage;
        }
        public function set userImage(image:Image):void
        {
            _userImage = image;
        }
        
        public function get userName():String
        {
            return _userName;
        }
        public function set userName(name:String):void
        {
            _userName = name;
        }
	}
}