package com.stintern.anipang.maingamescene.block
{
	import com.stintern.anipang.maingamescene.board.GameBoard;
	import com.stintern.anipang.utils.Resources;

	public class BlockCreator
	{
		private var _row, _col;
		private var _blockPool:BlockPool;    
		
		public function BlockCreator()
		{
			// 제거한 블럭을 저장할 풀 생성
			_blockPool = new BlockPool();
		}
		
		/**
		 * 로드한 보드의 정보를 바탕으로 새로운 블럭들을 배치합니다. 
		 */
		public function createBlocks(blockPainter:BlockPainter, moveCallback:Function):void
		{
			var rowCount:uint = GameBoard.instance.rowCount;
			var colCount:uint = GameBoard.instance.colCount;
			
			var blockArray:Vector.<Vector.<Block>> = BlockManager.instance.blockArray;
			blockArray.length = rowCount;
			for(var i:uint = 0; i<rowCount; ++i)
			{
				blockArray[i] = new Vector.<Block>();
				blockArray[i].length = colCount
				for(var j:uint = 0; j<colCount; ++j)
				{
					// 보드 정보를 보고 블럭의 타입을 받아옴
					var type:uint = getTypeOfBlock(i, j);
					
					var block:Block = createBlock(type, blockPainter, moveCallback);	//보드가 빈공간이면  null을 반환
					if(block != null)	
					{
						block.row = i;
						block.col = j;
						
						// 블럭 이미지 위치를 설정
						blockPainter.setImagePosition(block.image, i, j);
					}
					
					blockArray[i][j] = block;
				}
			}
		}
		
		/**
		 * 새로운 블럭을 생성합니다.  
		 * @param type 생성할 블럭의 타입
		 * @return 생성한 블럭
		 */
		public function createBlock(type:uint, blockPainter:BlockPainter, moveCallback:Function):Block
		{
			//투명 블럭등 동물 블럭이 아닌 경우
			if( type > Resources.BLOCK_TYPE_SPECIAL_BLOCK_END )
				return null;
			
			// 풀에 블럭이 있으면 새로 만들지 않음.
			var block:Block = _blockPool.getBlock(type);
			if( block != null )
			{
				return block;
			}
			
			block  = new Block();
			block.init(type, blockPainter.getTextureByType(type), moveCallback);
			
			blockPainter.addBlock(block.image);
			
			return block;
		}
		
		private function getTypeOfBlock(row:uint, col:uint):uint
		{
			var board:Vector.<Vector.<uint>> = GameBoard.instance.boardArray; 
			
			var blockType:uint;
			switch(board[row][col])
			{
				case GameBoard.TYPE_OF_CELL_EMPTY:
					return GameBoard.TYPE_OF_CELL_EMPTY;
					
				case GameBoard.TYPE_OF_CELL_ANIMAL:
				case GameBoard.TYPE_OF_CELL_ICE:
					return makeNewType(BlockManager.instance.blockArray, row, col);
					
				default:
					return board[row][col];
			}
			
			return blockType;
		}
		
		
		/**
		 * 블럭 보드의 좌측 및 상단의 블럭을 확인하여 연결되지 않도록 블럭의 새로운 타입을 생성합니다. 
		 * @param blockArray 블럭 배열
		 * @param row 생성할 블럭의 row Index
		 * @param col 생성할 블럭의 col Index
		 * @return 
		 * 
		 */
		public function makeNewType(blockArray:Vector.<Vector.<Block>>, row:uint, col:uint):uint
		{
			_row = row;
			_col = col;
			
			switch( row )
			{
				case 0:
				case 1:
					return inCaseRow0_1(blockArray);
					
				default:
					return inCaseRow2(blockArray);
			}
		}
		
		private function inCaseRow0_1(blockArray:Vector.<Vector.<Block>>):uint
		{
			switch(_col)
			{
				case 0:
				case 1:
					return getRandom();
					
				default:
					return getRandom( checkLeftSide(blockArray) );
			}
		}
		
		private function inCaseRow2(blockArray:Vector.<Vector.<Block>>):uint
		{
			switch(_col)
			{
				case 0:
				case 1:
					return getRandom( checkUpSide(blockArray) );
					
				default:
					return getRandom( checkUpSide(blockArray), checkLeftSide(blockArray) ); 
			}
		}
		
		private function checkLeftSide(blockArray:Vector.<Vector.<Block>>):uint
		{
			if( blockArray[_row][_col-2] == null || blockArray[_row][_col-1] == null)
				return -1;
			
			var first:uint = getAnimalType(blockArray[_row][_col-2].type);
			var second:uint = getAnimalType(blockArray[_row][_col-1].type);
			if( first == second )
				return first
			
			return -1;
		}
		
		private function checkUpSide(blockArray:Vector.<Vector.<Block>>):uint
		{
			if( blockArray[_row-2][_col] == null || blockArray[_row-1][_col] == null )
				return -1;
			
			var first:uint = getAnimalType(blockArray[_row-2][_col].type);
			var second:uint = getAnimalType(blockArray[_row-1][_col].type);
			if( first == second )
				return first
			
			return -1;
		}
		
		private function getRandom(... except):uint
		{
			var result:uint = uint(Math.random() * Resources.BLOCK_TYPE_COUNT) + Resources.BLOCK_TYPE_START;
			for(var i:uint=0; i<except.length; ++i)
			{
				if( except[i] == result )
				{
					return getRandom(except[0], except[1]);
				}
			}
			
			return result;
		}
		
		private function getAnimalType(type:uint):uint
		{
			if( type >= 10 )
			{
				return uint(type * 0.1);
			}
			else
			{
				return type;
			}
		}
		
		public function get blockPool():BlockPool
		{
			return _blockPool;
		}
	}
}