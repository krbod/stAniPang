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
    import com.stintern.anipang.scenemanager.SceneManager;
    
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
            
            var viewPort:Rectangle = RectangleUtil.fit(
                new Rectangle(0, 0, Resources.IMAGE_WIDTH_SD, Resources.IMAGE_HEIGHT_SD), 
                new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight), 
                ScaleMode.SHOW_ALL, iOS);
            
            var scaleFactor:int = viewPort.width < (Resources.IMAGE_WIDTH_SD + Resources.IMAGE_HEIGHT_SD)*0.5 ? 1 : 2;		// X = (720(SD) + 1080(HD)) / 2
            
            AssetLoader.instance.init(scaleFactor);
            Resources.setScaleFactor(scaleFactor);
           
            mStarling = new Starling(SceneManager, stage, viewPort);
			
            mStarling.antiAliasing = 1;
            mStarling.showStats = true;
			
            mStarling.start();
        }
    }
}