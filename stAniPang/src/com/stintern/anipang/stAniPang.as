package com.stintern.anipang
{
    import com.stintern.anipang.utils.AssetLoader;
    import com.stintern.anipang.utils.Resources;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    
    import starling.core.Starling;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
    
    [SWF(frameRate="60")]
    public class stAniPang extends Sprite
    {
        private var mStarling:Starling;
        
        public function stAniPang()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
            Starling.handleLostContext = !iOS;  
            
            var stageWidth:int  = 720;
            var stageHeight:int = 1280;
            
            var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, stageWidth, stageHeight), 
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), 
                ScaleMode.SHOW_ALL, iOS);
            
            var scaleFactor:int = viewPort.width < 900 ? 1 : 2;		// 900 = (720(SD) + 1080(HD)) / 2
            
            AssetLoader.instance.init(scaleFactor);
            Resources.setScaleFactor(scaleFactor);
           
            mStarling = new Starling(SceneManager, stage, viewPort);
			
			//mStarling = new Starling(SceneManager, stage, new Rectangle(0, 0, 768, 1024));
            
            mStarling.antiAliasing = 1;
            mStarling.showStats = true;
			
			//mStarling.viewPort = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
            
            mStarling.start();
        }
    }
}