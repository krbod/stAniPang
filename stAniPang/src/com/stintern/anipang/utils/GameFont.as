package com.stintern.anipang.utils
{
	import flash.text.Font;

	public class GameFont
	{
		[Embed(source = "./HUHappy.ttf", fontName = "HUHappy",
			        mimeType = "application/x-font", fontWeight="Bold",
			        fontStyle="Bold", advancedAntiAliasing = "true",
			        embedAsCFF="false")]
		private static const HUHappyFont:Class;
		public static var font:Font = new HUHappyFont();
		
	}
}