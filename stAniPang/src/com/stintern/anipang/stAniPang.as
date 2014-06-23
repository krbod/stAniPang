package com.stintern.anipang
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;
    
    import starling.core.Starling;
    
    [SWF(frameRate="60")]
    public class stAniPang extends Sprite
    {
        private var mStarling:Starling;
        
        public function stAniPang()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
			
            var viewPort:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
            mStarling = new Starling(SceneManager, stage, viewPort);
            
            mStarling.antiAliasing = 1;
            mStarling.showStats = true;
            
            mStarling.start();
        }
    }
}