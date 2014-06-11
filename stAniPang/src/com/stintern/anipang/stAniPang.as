package com.stintern.anipang
{
    import com.stintern.anipang.maingamescene.layer.MainGameScene;
    
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
			
            // create our Starling instance
            var viewPort:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
            mStarling = new Starling(MainGameScene, stage, viewPort);
            
            // set anti-aliasing (higher the better quality but slower performance)
            mStarling.antiAliasing = 1;
            
            mStarling.showStats = true;
            
            // start it!
            mStarling.start();
        }
    }
}