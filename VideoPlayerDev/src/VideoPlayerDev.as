package
{
	import com.adam.mediaplayers.VideoPlayer;
	
	import flash.display.Sprite;
	
	public class VideoPlayerDev extends Sprite
	{
		
		private var videoPlayer:VideoPlayer;
		
		public function VideoPlayerDev()
		{
			videoPlayer=new VideoPlayer();
			addChild(videoPlayer);
			
			videoPlayer.setSize(221,119);
			videoPlayer.play("vid1.f4v");
		}
	}
}