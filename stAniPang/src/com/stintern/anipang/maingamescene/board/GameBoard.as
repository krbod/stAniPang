package com.stintern.anipang.maingamescene.board
{
    import com.stintern.anipang.scenemanager.SceneManager;
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.StageInfo;
    import com.stintern.anipang.maingamescene.block.Block;
    import com.stintern.anipang.maingamescene.block.BlockManager;
    import com.stintern.anipang.maingamescene.block.BlockPainter;
    import com.stintern.anipang.maingamescene.block.algorithm.BlockLocater;
    import com.stintern.anipang.maingamescene.layer.PanelLayer;
    import com.stintern.anipang.utils.Resources;
    
    import flash.utils.Dictionary;
    
    import starling.core.Starling;
    import starling.display.Image;

    public class GameBoard
    {
        // 싱글톤 관련
        private static var _instance:GameBoard;
        private static var _creatingSingleton:Boolean = false;
        
        private var _boardImage:Vector.<Vector.<Image>>;
        private var _stageInfo:StageInfo; 
                
        public static var TYPE_OF_CELL_ANIMAL:uint = 0;      // 동물만 있는 공간

        public static var TYPE_OF_CELL_EMPTY:uint = 100;     // 아무 것도 없는 공간
        
        public static var TYPE_OF_CELL_ICE:uint = 200;
        public static var TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED:uint = 201;
        
        public static var TYPE_OF_CELL_BOX:uint = 300;
        public static var TYPE_OF_CELL_NEED_TO_BE_FILLED:uint = 400;  // 기존에 블럭이 없어지거나 해서 채워져야할 공간
        
        public function GameBoard()
        {
            if (!_creatingSingleton){
                throw new Error("[GameBoard] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():GameBoard
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new GameBoard();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        public function dispose():void
        {
            _stageInfo.dispose();
        }
        
        /**
         *  스테이지 레벨에 맞는 보드 정보를 입력합니다.
         */
        public function initBoard():void
        {
            // 레벨에 맞는 보드 정보를 불러옵니다.
            _stageInfo = LevelManager.instance.stageInfo;
            
            // 보드 이미지 정보를 저장(얼음, 박스 .. )
            _boardImage = new Vector.<Vector.<Image>>();
            _boardImage.length = _stageInfo.rowCount;
            for(var i:uint=0; i<_stageInfo.rowCount; ++i)
            {
                _boardImage[i] = new Vector.<Image>();
                _boardImage[i].length = _stageInfo.colCount;
            }
        }
        
        
        /**
         * 보드에 더이상 연결될 블럭이 없을 경우에 블럭을 재배열합니다. 
         */
        public function recreateBoard(blockArray:Vector.<Vector.<Block>>, blockLocater:BlockLocater, blockPainter:BlockPainter):void
        {
            // 보드를 재배열한 후에 특수블럭은 그대로 남아 있어야 되기 때문에
            //기존에 있던 블록중에 특수 블럭의 타입을 저장
            var dictionary:Dictionary = storeSpecialBlocks(blockArray);
            
            // 풀에 저장한 블록들을 바탕으로 보드를 재배열
            relocateBoard(dictionary, blockArray, blockLocater, blockPainter);
            dictionary = null;
        }
        
        private function storeSpecialBlocks(blockArray:Vector.<Vector.<Block>>):Dictionary
        {
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
            
            var dic:Dictionary = new Dictionary();
            for(var i:uint = 0; i<rowCount; ++i)
            {
                for(var j:uint = 0; j<colCount; ++j)
                {
                    var block:Block = blockArray[i][j];
                    if( block == null )
                        continue;
                    
                    if( block.type >= Resources.BLOCK_TYPE_SPECIAL_BLOCK_START && 
                        block.type <= Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
                    {
                        if( dic[block.type] == null )
                            dic[block.type] = 1;
                        else
                            dic[block.type] += 1;
                    }
                }
            }
            
            return dic;
        }
        
        private function relocateBoard(dic:Dictionary, blockArray:Vector.<Vector.<Block>>, blockLocater:BlockLocater, blockPainter:BlockPainter):void
        {
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
            
            for(var i:uint = 0; i<rowCount; ++i)
            {
                for(var j:uint = 0; j<colCount; ++j)
                {
                    if(blockArray[i][j] == null)
                        continue;
                    
                    // 새로운 타입을 생성
                    var type:uint = blockLocater.makeNewType(blockArray, i, j);
                    
                    // 저장해놓은 특수블럭과 같은 타입이면 특수블럭으로 생성
                    if( dic[type*10] != null && dic[type*10] > 0 )
                    {
                        type = type * 10;
                        dic[type*10]--;
                    }
                    else if( dic[type * 10 + 1] != null && dic[type * 10 + 1] > 0 )
                    {
                        type = type * 10 + 1;
                        dic[type*10+1]--;
                    }
                    else if( dic[type * 10 + 2] != null && dic[type * 10 + 2] > 0 )
                    {
                        type = type * 10 + 2;
                        dic[type*10+2]--;
                    }	
                    else if( dic[90] != null && dic[90] > 0 )
                    {
                        type = 90;
                    }
                    
                    // 블럭의 이미지를 변경
                    blockPainter.changeTexture(blockArray[i][j], type);
                    blockArray[i][j].type = type;
                }
            }
        }

        public function updateBoard(row:uint, col:uint, requiredToBeFilled:Boolean):void
        {
            // Board 에 이미지 정보 갱신( 얼음 제거 .. )
            switch(boardArray[row][col])
            {
                case GameBoard.TYPE_OF_CELL_ICE:
                    BlockManager.instance.blockPainter.removeBoardImageAt(row, col);
					
					// 상단 패널의  얼음 남은 갯수 업데이트
					var panelLayer:PanelLayer = ( (Starling.current.root as SceneManager).getLayerByName(Resources.LAYER_PANEL) as PanelLayer);
					panelLayer.updateLeftIce();
                    break;
            }
            
            // Board 정보 갱신
            if( requiredToBeFilled )
                boardArray[row][col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
        }
        
        public function get boardArray():Vector.<Vector.<uint>>
        {
            return _stageInfo.boardArray;
        }

        public function get boardImageArray():Vector.<Vector.<Image>>
        {
            return _boardImage;
        }
        
		public function get rowCount():uint
		{
			return _stageInfo.rowCount;
		}
		
		public function get colCount():uint
		{
			return _stageInfo.colCount;
		}
    }
}