package com.stintern.anipang.maingamescene.block
{
    import com.greensock.TweenLite;
    import com.stintern.anipang.maingamescene.LevelManager;
    import com.stintern.anipang.maingamescene.MissionChecker;
    import com.stintern.anipang.maingamescene.block.algorithm.ConnectedBlockFinder;
    import com.stintern.anipang.maingamescene.block.algorithm.RemoveAlgoResult;
    import com.stintern.anipang.maingamescene.board.GameBoard;
    import com.stintern.anipang.maingamescene.layer.MissionClearLayer;
    import com.stintern.anipang.maingamescene.layer.MissionFailureLayer;
    import com.stintern.anipang.maingamescene.layer.PanelLayer;
    import com.stintern.anipang.scenemanager.SceneManager;
    import com.stintern.anipang.userinfo.UserInfo;
    import com.stintern.anipang.utils.Resources;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;

    public class BlockManager
    {
        // 싱글톤 관련
        private static var _instance:BlockManager;
        private static var _creatingSingleton:Boolean = false;
        
        private var _blockArray:Vector.<Vector.<Block>>;    // 생성된 블럭들이 저장되어 있는 벡터
        
        private var _blockRemover:BlockRemover;              // 블럭삭제 알고리즘에 의해 삭제할 블럭들을 없앰
        private var _connectedBlockFinder:ConnectedBlockFinder;
		
		private var _blockCreator:BlockCreator;
        
        private var _blockPainter:BlockPainter;             // 블럭들을 그리는 객체
        private var _isBlockExchaning:Boolean = false;      // 블럭을 교환하고 있을 때 다른 블럭을 교환할 수 없게 하기 위해
        
        private var _missionChecker:MissionChecker;
        
        // Item 
        private var _clickPangClicked:Boolean;
        private var _gogglePangClicked:Boolean;
        private var _changePangClicked:Boolean;
        
        private var _movingBlockCount:uint = 0;
		private var _requiredStepBlocks:Boolean;
        
        public function BlockManager()
        {
            if (!_creatingSingleton){
                throw new Error("[BlockManager] 싱글톤 클래스 - new 연산자를 통해 생성 불가");
            }
        }
        
        public static function get instance():BlockManager
        {
            if (!_instance){
                _creatingSingleton = true;
                _instance = new BlockManager();
                _creatingSingleton = false;
            }
            return _instance;
        }
        
        /**
         * 블럭관리에 필요한 여러 객체를 초기화합니다. 
         * @param layer 블럭을 출력할 레이어
         */
        public function init(layer:Sprite):void
        {
			// 블럭 생성기
			_blockCreator = new BlockCreator();
            
            // 생성한 블럭들을 저장할 벡터 생성
            _blockArray = new Vector.<Vector.<Block>>();
            
            // 블럭을 그리는 Painter 객체 생성
            _blockPainter = new BlockPainter();
            layer.addChild(_blockPainter);
            
            // 삭제 알고리즘의 결과값을 통해 블럭을 삭제
            _blockRemover = new BlockRemover(_blockArray, _blockCreator.blockPool);
            
            //  블럭을 옮기면 연결될 블럭을 찾는 객체 생성 
            _connectedBlockFinder = new ConnectedBlockFinder(callbackConnectedBlock);
            
			// 현재 스테이지의 미션을 체크하는 객체
            _missionChecker = new MissionChecker();
			
			_requiredStepBlocks = true;
        }
        
        /**
         * 매프레임당 블럭들의 아래쪽을 확인하면서 비워 있으면 낙하하도록 합니다. 
         */
        public function stepBlocks():void
        {
			if( !_requiredStepBlocks )
				return;
			
            // 다음 블럭의 위치를 확인하고 옮겨야 하면 블럭 정보를 변경
            moveBlocks();
			
			// 1행에 있던 블럭들이 내려간 자리로 새로운 블럭을 생성
			fillWithNewBlocks();
            			
            // 변경된 블럭의 정보를 바탕으로 블럭을 새로 그림
            _blockPainter.drawBlocks(_blockArray);
            						
            // 블럭이 낙하한 뒤 연결된 블럭이 있는 지 확인
            if( _movingBlockCount == 0 )
            {				
                // 낙하한 뒤 새로운 보드에서 연결된 블럭이 있으면 삭제
                _blockRemover.removeConnectedBlocks();

                // 미션을 클리어했으면 게임 종료
                if( checkMissionClear() )
					return;
                
                // 블럭을 하나 옮기면 연결될 블럭이 있는 지 확인 후 없으면 보드를 재배열
                var result:Array = _connectedBlockFinder.process();
                if( result == null )
                {
                   	GameBoard.instance.recreateBoard(_blockArray, _blockCreator, _blockPainter);     
                }
            }
        }
        
        /**
         * 블럭의 아랫칸을 확인하고 내려가야 하면 블럭의 정보를 갱신합니다. 
         */
        private function moveBlocks():void
        {
            var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
            
            var rowCount:uint = _blockArray.length;
            for(var i:int=rowCount-1; i>=0; --i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    // 블럭이 null (비어있는 칸)이거나 맨 아랫줄이면 낙하시키지 않음
                    var block:Block = _blockArray[i][j];    
                    if(block == null || block.row == GameBoard.instance.rowCount - 1)
                    {
                        continue;
                    }
                    
                    if(block.isMoving)
                        continue;
                        
                    // 아래가 블록으로 채워져야하는 칸이면 낙하
                    if( boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED ||
                        boardArray[block.row+1][block.col] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
                    {
                        moveBlock(block, block.row+1, block.col);
                    }
					// 왼쪽이 블럭이 없는 곳이고 대각선 왼쪽이 비어 있으면 대각선 왼쪽으로 옮김
                    else if( checkDiagonal(block.row, block.col, true) )
                    {
                        moveBlock(block, block.row+1, block.col-1);
                    }
					// 오른쪽 대각선 체크
					else if( checkDiagonal(block.row, block.col, false) )
					{
						moveBlock(block, block.row+1, block.col+1);
					}
                    
                }
            }
            
        }
		
		/**
		 * 대각선으로 블럭이 이동할 수 있는 지 확인하고 블럭을 이동시킵니다. 
		 * @param row 현재 블럭의 위치 row
		 * @param col 현재 블럭의 위치 col
		 * @param isLeft 왼쪽 대각선이면 true, 그렇지 않으면 false
		 * @return 이동할 수 있으면 true, 그렇지 않으면 false
		 */
		private function checkDiagonal(row:uint, col:uint, isLeft:Boolean):Boolean
		{
			if( isLeft )
			{
				if( col-1 < 0 )
					return false;
				
				return checkAt(row+1, col-1);
			}
			else
			{
				if( col+1 > GameBoard.instance.colCount - 1 )
					return false;
				
				return checkAt(row+1, col+1);
			}
		}
		
		private function checkAt(i, j):Boolean
		{
			var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			
			// 대각선에 다른 블럭이 있을 경우 옮기지 않음
			if( boardArray[i][j] != GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED  ||
				boardArray[i][j] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
				return false;
			
			// 왼쪽에 보드 정보를 확인하고 블럭을 옮겨야 하면 옮김
			switch( boardArray[i-1][j] )
			{
				case GameBoard.TYPE_OF_CELL_EMPTY:
				case GameBoard.TYPE_OF_CELL_BOX:
					return true;
					
				default:
					return false;
			}
		}
		
        /**
         * 블럭이 낙하함으로 인해 첫 행이 비워졌을 때 
         * 새로운 블럭을 생성합니다. 
         */
		private function fillWithNewBlocks():void
		{
			var boardArray:Vector.<Vector.<uint>> = GameBoard.instance.boardArray;
			var colCount:uint = boardArray[0].length;
			for(var i:uint=0; i<colCount; ++i)
			{
                // 맨 윗행이 채워져야하는 공간이면 새로운 블럭을 생성하여 배치함
				if( boardArray[0][i] == GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED || 
                    boardArray[0][i] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
				{
					var block:Block = _blockCreator.createBlock( uint(Math.random() * Resources.BLOCK_TYPE_COUNT) + Resources.BLOCK_TYPE_START, _blockPainter, moveCallback);	
					block.row = 0;
					block.col = i;
					
					block.image.x = i * block.image.texture.width + Starling.current.stage.stageWidth  * 0.5 - block.image.texture.width * 4;
					block.image.y = block.image.texture.height * -1 + Starling.current.stage.stageHeight  * 0.5 - block.image.texture.height * 4;

                    boardArray[0][i] = GameBoard.TYPE_OF_CELL_ANIMAL;
                    _blockArray[block.row][block.col] = block;
                    
                    block.drawRequired = true;
				}
			}
		}
        
        /**
         * 블럭을 입력한 인덱스 위치로 이동시킵니다. 
         */
        private function moveBlock(block:Block, row:uint, col:uint):void
        {
            var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
            
            // 정보 갱신
            if(board[block.row][block.col] == GameBoard.TYPE_OF_CELL_ICE )
            {
                board[block.row][block.col] = GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED;
            }
            else
            {
                board[block.row][block.col] = GameBoard.TYPE_OF_CELL_NEED_TO_BE_FILLED;
            }
            
            _blockArray[block.row][block.col] = null;
            
            block.row = row;
            block.col = col;
            
            // 옮겨갼 위치가 얼음이 아닐경우에는 게임 보드 정보를 동물로 변경
            if( board[row][col] == GameBoard.TYPE_OF_CELL_ICE_AND_NEED_TO_BE_FILLED )
            {
                board[row][col] = GameBoard.TYPE_OF_CELL_ICE;
            }
            else if( board[row][col] != GameBoard.TYPE_OF_CELL_ICE )
            {
                board[row][col] = GameBoard.TYPE_OF_CELL_ANIMAL;
            }
                
            _blockArray[row][col] = block;
            
            // 다음 프레임 때 BlockPainter 에 의해서 갱신된 위치로 블럭을 Tween
            block.drawRequired = true;
        }

        /**
         * 로드한 보드의 정보를 바탕으로 새로운 블럭들을 배치합니다. 
         */
        public function createBlocks():void
        {
			_blockCreator.createBlocks(_blockPainter, moveCallback);
        }
		       
        public function moveCallback(row1:int, col1:int, row2:int, col2:int):void
        {
            if( !nextPosAvailable(row2, col2) || _isBlockExchaning )
                return;
            
            exchangeBlock(_blockArray[row1][col1], _blockArray[row2][col2], false);
        }
        
        /**
         * 블럭을 움직일 때 다음 위치로 옮길 수 있는 지 판단 
         * @param row 옮겨갈 다음 위치의 row Index
         * @param col 옮겨갈 다음 위치의 col Index
         * @return 옮길 수 있는 지 여부
         */
        private function nextPosAvailable(row:int, col:int):Boolean
        {
            // 보드 밖이면 FALSE
            if( row < 0 || col < 0 || row >= GameBoard.instance.rowCount || col >= GameBoard.instance.colCount )
                return false;
            
            switch( GameBoard.instance.boardArray[row][col] )
            {
                case GameBoard.TYPE_OF_CELL_EMPTY:
                    return false;
                    
                case GameBoard.TYPE_OF_CELL_BOX:
                    return false;
                    
                default:
                    return true;
            }
        }
        
        /**
         * 블럭을 교환시킵니다. 
         * @param row1 이동시킬 블럭의 row Index
         * @param col1 이동시킬 블럭의 col Index
         * @param row2 이동할 위치의 row Index
         * @param col2 이동할 위치의 col Index
         * @param isReturn 교환한 후 연결되는 블럭이 없어서 다시 돌아오는 경우에는 true, 그렇지 않으면 false
         */
        public function exchangeBlock(lhs:Block, rhs:Block, isReturn:Boolean, onComplete:Function=null):void
        {
            var image1:Image = lhs.image;
            var image2:Image = rhs.image;
            
            TweenLite.to(image1, 0.15, {x:image2.x, y:image2.y, onComplete:onCompleteExchangeBlock});
            TweenLite.to(image2, 0.15, {x:image1.x, y:image1.y, onComplete:onCompleteExchangeBlock});
            
            _isBlockExchaning = true;
            
            // 2개의 트윈이 모드 완료한 뒤에 블럭의 정보를 갱신
            var completeCount:uint = 0;
            function onCompleteExchangeBlock():void
            {
                ++completeCount;
                if(completeCount == 2)
                    updateBlocks(lhs, rhs, isReturn);
                
                // 블럭을 움직였을 경우에 연결된 블럭을 찾는 것을 리셋
                _connectedBlockFinder.reset();
                _blockPainter.disposeHint();
                
                if( completeCount == 2 && onComplete != null )
                    onComplete();
            }
        }
        
        private function updateBlocks(lhs:Block, rhs:Block, isReturn:Boolean):void
        {
            _isBlockExchaning = false; 
            
            // 변경한 블럭들로 정보 변경
            updateInfo(lhs, rhs);
            
            // 다시 돌아오는 경우에는 삭제될 블럭을 찾는 알고리즘을 실행시키지 않음
            if( isReturn )
                return;
            
            // 변경된 보드에서 삭제될 블럭이 있는 지 확인 후
            // 삭제될 블럭이 있으면 삭제하고 없으면 블럭을 다시 원위치
            if( !_blockRemover.removeBlocks(lhs, rhs) )
            {
                // 체인지 팡으로 블럭을 옮긴 경우 연결되는 블럭이 없더라도 다시 돌아가지 않음
                if( !changePangClicked )
                    exchangeBlock(lhs, rhs, true);
            }
            else
            {
                // 블럭을 옮길 수 있는 횟수를 하나 줄임
                var leftStep:int = _missionChecker.step();
				
				// 상단에 패널의 남은 이동 업데이트
				var panelLayerL:PanelLayer = ( (Starling.current.root as SceneManager).getLayerByName(Resources.LAYER_PANEL) as PanelLayer);
				panelLayerL.updateLeftStep(leftStep);
            }
        }
            
        /**
         * 블럭 및 보드들의 정보를 갱신 
         */
        private function updateInfo(lhs:Block, rhs:Block):void
        {
            // block의 row, col 정보 갱신
            lhs.swapIndex(rhs);
            
            // BlockArray 정보 갱신
            var tmp:Block = _blockArray[lhs.row][lhs.col];
            _blockArray[lhs.row][lhs.col] = _blockArray[rhs.row][rhs.col];
            _blockArray[rhs.row][rhs.col] = tmp;
        }
        
        public function makeSpecialBlock(row:uint, col:uint, type:uint, requiredUpdateBoard = true):void
        {
            switch( type )
            {
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_LINEAR:
                    _blockArray[row][col].type = Resources.BLOCK_TYPE_GHOST;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_5_BLOCKS_RIGHT_ANGLE:
                    _blockArray[row][col].type *= Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_GOGGLE_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_LEFT_RIGHT:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_LR_ARROW_INDEX;
                    break;
                
                case RemoveAlgoResult.TYPE_RESULT_4_BLOCKS_UP_DOWN:
                    _blockArray[row][col].type = _blockArray[row][col].type * Resources.BLOCK_TYPE_PADDING + Resources.BLOCK_TYPE_TB_ARROW_INDEX;
                    break;
            }
            
            if( requiredUpdateBoard )
                GameBoard.instance.updateBoard(row, col, false);
            
            _blockPainter.changeTexture(_blockArray[row][col], _blockArray[row][col].type);
        }
        
        public function exchangeBlockType(block:Block, type:uint, requiredTextureChange:Boolean):void
        {
            block.type = type;
            
            if( requiredTextureChange )
            {
                _blockPainter.changeTexture(block, type);
            }
        }
        
        public function getBlocksByType(type:uint):Array
        {
            var result:Array = new Array();
            var rowCount:uint = _blockArray.length;
            for(var i:uint=0; i<rowCount; ++i)
            {
                var colCount:uint = _blockArray[i].length;
                for(var j:uint=0; j<colCount; ++j)
                {
                    if( _blockArray[i][j].type == type)
                    {
                        result.push( _blockArray[i][j]);
                    }
                }
            }
            
            return result;
        }
        
        private function checkMissionClear():Boolean
        {
            switch( _missionChecker.check() )
            {
                case MissionChecker.MISSION_RESULT_SUCCESS:
					UserInfo.instance.updateUserInfo(LevelManager.instance.currentStageLevel, _missionChecker.currentScore);
					
					(Starling.current.root as SceneManager).currentScene.addChild( new MissionClearLayer() );
					_requiredStepBlocks = false;
					return true;
                
                case MissionChecker.MISSION_RESULT_FAILURE:
					(Starling.current.root as SceneManager).currentScene.addChild( new MissionFailureLayer() );
					_requiredStepBlocks = false;
                    return false;
                
                case MissionChecker.MISSION_RESULT_KEEP_PLAYING:
					return false;
					
				default:
					return false;
            }
        }
        
        
        public function drawBoard():void
        {
            _blockPainter.initBoard();
        }
        
        
        public function callbackConnectedBlock(connectedBlock:Array):void
        {
            _blockPainter.showHint(connectedBlock);
        }
        
        public function removeBlockAt(row:uint, col:uint):void
        {
            _blockRemover.removeBlockAt(row, col);
        }
        
        public function resetConnectedBlockFinder():void
        {
            _connectedBlockFinder.reset();
            _blockPainter.disposeHint();
        }
        
        public function get blockArray():Vector.<Vector.<Block>>
        {
            return _blockArray;
        }
        
        public function get blockPainter():BlockPainter
        {
            return _blockPainter;
        }
        
        public function get movingBlockCount():uint
        {
            return _movingBlockCount;
        }
        public function set movingBlockCount(count:uint):void
        {
            _movingBlockCount = count;
        }
		
		public function get missoinChecker():MissionChecker
		{
			return _missionChecker;
		}
        
        public function get clickPangClicked():Boolean
        {
            return _clickPangClicked;
        }
          
        public function set clickPangClicked(isClicked:Boolean):void
        {
            _clickPangClicked = isClicked;
        }
        
        public function get gogglePangClicked():Boolean
        {
            return _gogglePangClicked;
        }
        
        public function set gogglePangClicked(isClicked:Boolean):void
        {
            _gogglePangClicked = isClicked;
        }
        
        public function get changePangClicked():Boolean
        {
            return _changePangClicked;
        }
        
        public function set changePangClicked(isClicked:Boolean):void
        {
            _changePangClicked = isClicked;
        }

    }
}