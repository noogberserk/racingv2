package entities
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.masks.Pixelmask;
	import net.flashpunk.utils.*;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Emitter;
	import flash.display.BitmapData;
	import worlds.Area;
	
	/**
	 * ...
	 * @author noogberserk
	 */
	public class PlayerCar extends Entity 
	{
		public var g:Image;
		private var maskBmp:BitmapData;
		private var maskObj:Pixelmask;
		public static var v:Point;
		public static var playerSpeed:Number = GC.PLAYER_Y_SPEED / 8;
		public static var isRunning:Boolean;
		public static var id:PlayerCar;
		private var sideWall:SideWalls;
		private var frontWalls:FrontWalls;
		private var destructibleWall:DestructibleWall;
		
		private var cornerAngle:Number;
		private var hipotenuse:Number;
		public var topRightCorner:Point;
		public var topLeftCorner:Point;
		public var bottomRightCorner:Point;
		public var bottomLeftCorner:Point;
		
		public function PlayerCar(x:Number, y:Number) 
		{
			id = this;
			g = new Image(GC.CAR_IMAGE);
			g.centerOrigin();
			
			var size:int = Math.ceil(Math.sqrt(g.width * g.width + g.height * g.height));
			maskBmp = new BitmapData(size, size, true, 0);
			
			var offset:Point = new Point(size / 2, size / 2);
			
			maskObj = new Pixelmask(maskBmp, -offset.x, -offset.y);
			g.render(maskBmp, offset, FP.zero);
			
			layer = -1;
			type = GC.TYPE_PLAYER;
			v = new Point();
			
			cornerAngle = Math.atan((g.width / 2) / (g.height / 2)) * 180 / Math.PI;
			hipotenuse = Math.sqrt((g.width / 2) * (g.width / 2) + (g.height / 2) * (g.height / 2)) - 2;
			
			super(x, y, g, maskObj);
			
			topLeftCorner = new Point();
			topRightCorner = new Point();
			bottomLeftCorner = new Point();
			bottomRightCorner = new Point();
		}
		override public function render():void 
		{
			super.render();
		}
		
		private function get area():Area
		{
			return world as Area;
		}
		
		
		override public function update():void 
		{
			super.update();
			
			checkSplitCar();
			
			topLeftCorner.x = hipotenuse * -Math.sin((g.angle + cornerAngle) * Math.PI / 180);
			topLeftCorner.y = hipotenuse * -Math.cos((g.angle + cornerAngle) * Math.PI / 180);
			bottomRightCorner.x = hipotenuse * Math.sin((g.angle + cornerAngle) * Math.PI / 180);
			bottomRightCorner.y = hipotenuse * Math.cos((g.angle + cornerAngle) * Math.PI / 180);
			
			topRightCorner.x = hipotenuse * -Math.sin((g.angle - cornerAngle) * Math.PI / 180);
			topRightCorner.y = hipotenuse * -Math.cos((g.angle - cornerAngle) * Math.PI / 180);
			bottomLeftCorner.x = hipotenuse * Math.sin((g.angle - cornerAngle) * Math.PI / 180);
			bottomLeftCorner.y = hipotenuse * Math.cos((g.angle - cornerAngle) * Math.PI / 180);
			
			if (area.paused) return;
			
			maskBmp.fillRect(maskBmp.rect, 0);
			FP.point.x = maskBmp.width / 2;
			FP.point.y = maskBmp.height / 2;
			g.render(maskBmp, FP.point, FP.zero);
			
			
			checkVerticalInput();
			
			if (playerSpeed == 0) {
				isRunning = false;
			}
			else {
				isRunning = true;
			}
			
			//Velocity Vector
			v.x = Math.sin(g.angle * Math.PI / 180) * playerSpeed;
			v.y = Math.cos(g.angle * Math.PI / 180) * playerSpeed;
			
			y -= v.y * FP.elapsed;
			
			checkDirection();
			
			
			sideWall = collide("side_wall", x, y) as SideWalls;			
			frontWalls = collide("front_wall", x, y) as FrontWalls;
			destructibleWall = collide("destructible_wall", x, y) as DestructibleWall;
			
			
			if (frontWalls) {
				trace("front walls");
				playerSpeed = -playerSpeed * 0.6;
				
				y += v.y * FP.elapsed;
				checkFourDirections();
			}
			
			if (destructibleWall) {
				trace("destructible_wall");
				if (playerSpeed > 150) {
					FP.world.remove(destructibleWall);
				}
				else {
					playerSpeed = -playerSpeed * 0.6;
				}
				/*trace("side walls");
				if (SideWalls.id.getTileAtPosition(topRightCorner.x + x, topRightCorner.y + y) || SideWalls.id.getTileAtPosition(bottomRightCorner.x + x, bottomRightCorner.y + y)) {
					if (isRunning) g.angle = -g.angle;
					else g.angle++
					x-=1
				}
				else if (SideWalls.id.getTileAtPosition(topLeftCorner.x + x, topLeftCorner.y + y) || SideWalls.id.getTileAtPosition(bottomLeftCorner.x + x, bottomLeftCorner.y + y)) {
					if (isRunning) g.angle = -g.angle;
					else g.angle--
					x+=1
				}*/
			}
		}
		public function checkDirection():void {
			//Checking Input for Direction (x)
			if (Input.check(Key.LEFT)) {
				if (!(FrontWalls.id.getTileAtPosition(topLeftCorner.x + x, topLeftCorner.y + y) || FrontWalls.id.getTileAtPosition(bottomRightCorner.x + x, bottomRightCorner.y + y))) {
					g.angle+=1.5;
				}
			}
			if (Input.check(Key.RIGHT)) {
				if (!(FrontWalls.id.getTileAtPosition(topRightCorner.x + x, topRightCorner.y + y) || FrontWalls.id.getTileAtPosition(bottomLeftCorner.x + x, bottomLeftCorner.y + y))) {
					g.angle-=1.5;
				}
			}
			if (isRunning) {
				x -= v.x * FP.elapsed;
			}

		}
		public function checkSplitCar():void {
			if (Input.pressed(Key.SPACE)) {
				FP.world.add(new LeftCar(x - width / 3, y));
				FP.world.add(new RightCar(x + width / 3, y));
				FP.world.remove(this);
			}
		}
		
		private function checkFourDirections():void {
			if (collide("front_wall", x, y)) {
					y -= v.y * FP.elapsed * 2;
					if (collide("front_wall", x, y)) {
						y += v.y * FP.elapsed;
						x -= v.x * FP.elapsed;
						if (collide("front_wall", x, y)) {
							x += v.x * FP.elapsed * 2;
						}
					}
				}
		}
		
		public function checkVerticalInput():void {
			//Checking INPUT for Speed (y)
			if (Input.check(Key.UP)) {
				playerSpeed += GC.PLAYER_Y_ACCELERATION * FP.elapsed;
				
				if (playerSpeed > GC.PLAYER_Y_SPEED) {
					playerSpeed = GC.PLAYER_Y_SPEED;
				}
			}
			else if (Input.check(Key.DOWN)) {
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