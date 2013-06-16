package
{
	import com.adam.mediaplayers.YouTubePlayerWrapper;
	
	import flash.display.Sprite;
	
	[SWF(width='800', height='600', backgroundColor='#000000', frameRate='30')]
	
	public class YouTubePlayerDev extends Sprite
	{
		
		private var ytpw:YouTubePlayerWrapper;
		
		public function YouTubePlayerDev()
		{
			ytpw=new YouTubePlayerWrapper();
			addChild(ytpw);
			
			ytpw.loadVideo("N4RsU8o-9Hk");
		}
	}
}