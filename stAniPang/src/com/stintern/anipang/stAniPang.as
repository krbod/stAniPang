package com.stintern.anipang
{
    import com.stintern.anipang.maingamescene.layer.MainGameScene;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import starling.core.Starling;
    
    
    public class stAniPang extends Sprite
    {
        private var mStarling:Starling;
        
        public function stAniPang()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            // create our Starling instance
            mStarling = new Starling(MainGameScene, stage);
            
            // set anti-aliasing (higher the better quality but slower performance)
            mStarling.antiAliasing = 1;
            
            // start it!
            mStarling.start();
        }
    }
}