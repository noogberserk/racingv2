package entities 
{
	import net.flashpunk.utils.*;
	import net.flashpunk.FP;
	/**
	 * ...
	 * @author noogberserk
	 */
	public class Player2 extends PlayerCar 
	{
		public static var id:Player2;
		
		public function Player2(x:Number, y:Number) 
		{
			id = this;
			super(x, y);
		}
		
		override public function checkDirection():void 
		{
			if (Input.check(Key.A)) {
				if (!(FrontWalls.id.getTileAtPosition(topLeftCorner.x + x, topLeftCorner.y + y) || FrontWalls.id.getTileAtPosition(bottomRightCorner.x + x, bottomRightCorner.y + y))) {
					g.angle+=1.5;
				}
			}
			if (Input.check(Key.D)) {
				if (!(FrontWalls.id.getTileAtPosition(topRightCorner.x + x, topRightCorner.y + y) || FrontWalls.id.getTileAtPosition(bottomLeftCorner.x + x, bottomLeftCorner.y + y))) {
					g.angle-=1.5;
				}
			}
			if (isRunning) {
				x -= v.x * FP.elapsed;
			}
		}
		override public function checkVerticalInput():void 
		{
			//Checking INPUT for Speed (y)
			if (Input.check(Key.W)) {
				playerSpeed += GC.PLAYER_Y_ACCELERATION * FP.elapsed;
				
				if (playerSpeed > GC.PLAYER_Y_SPEED) {
					playerSpeed = GC.PLAYER_Y_SPEED;
				}
			}
			else if (Input.check(Key.S)) {
				playerSpeed -= GC.PLAYER_Y_ACCELERATION * 2 * FP.elapsed;
				
				if (playerSpeed < -GC.PLAYER_Y_SPEED / 2) {
					playerSpeed = -GC.PLAYER_Y_SPEED / 2;
				}
			}
			else {
				if (playerSpeed > 0) playerSpeed--;
				if (playerSpeed < 0) playerSpeed++;
			}
		}
	}

}