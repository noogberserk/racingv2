package entities 
{
	import flash.display.BitmapData;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author noogberserk
	 */
	public class DestructibleWall extends Actor 
	{
		private var g:Image;
		
		public function DestructibleWall(x:Number, y:Number)
		{
			g = new Image(new BitmapData(16, 16, false, 0x000000));
			graphic = g;
			super(x, y);
			type = "destructible_wall";
			collidable = true;
			setHitbox(16, 16);
		}
		
	}

}