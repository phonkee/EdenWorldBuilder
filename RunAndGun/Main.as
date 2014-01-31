package {
	import flash.geom.*;

	import flash.events.*;
	import flash.display.*;

	public class Main {





		var dir: Point = new Point();
		var sgun1: gun_sound = new gun_sound();

		var speed = 5;
		var JUMP_SPEED = 4;
		var gravity = .2;
		var acceleration: Point = new Point(0, gravity);
		var left = false;
		var right = false;
		var up = false;
		var down = false;
		var space = false;
		var jump_request = false;
		var gsx;
		var pmouse: Point = new Point();
		var mdown = false;
		var mdown1 = false;
		var gun_delay = 0;
		var stage: Stage;
		var lvl1: MovieClip;
		var gun1: MovieClip;
		var ball1: MovieClip;
		public function Main(st: Stage) {
			stage = st;
			trace("main init");

			stage.addEventListener(Event.ENTER_FRAME, fl_EnterFrameHandler);


		}
		function initAll() {
			var root1: MovieClip = stage.getChildByName("root1") as MovieClip;
			//for (var i:int=0;i<root1.numChildren;i++) trace(root1.getChildAt(i).name);

			lvl1 = root1.getChildByName("lvl1") as MovieClip;
			gun1 = root1.getChildByName("gun1") as MovieClip;
			ball1 = root1.getChildByName("ball1") as MovieClip;

			gsx = gun1.scaleX;

			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_KeyboardUpHandler);
			//lvl1=gun1=new MovieClip();

		}


		function mouseDownHandler(evt: MouseEvent): void {
			mdown = true;
			mdown1 = true;
			pmouse.x = evt.stageX;
			pmouse.y = evt.stageY;

		}
		function mouseMoveHandler(evt: MouseEvent): void {

			pmouse.x = evt.stageX;
			pmouse.y = evt.stageY;

		}
		function mouseUpHandler(evt: MouseEvent): void {
			mdown = false;
			//mdown1=false;
			pmouse.x = evt.stageX;
			pmouse.y = evt.stageY;

		}
		var bullets: Array = new Array();
		var frameCount = 0;
		function fl_EnterFrameHandler(event: Event): void {
			if (frameCount < 100)
				frameCount++;
			if (frameCount < 3) {
				if (frameCount == 2) {
					initAll();
					return;
				}
				return;


			}
			//return;


			handleInput();

			var p1: Point = new Point(ball1.x - lvl1.x + ball1.width / 2, ball1.y - lvl1.y + ball1.height / 2);
			var p2: Point = new Point(pmouse.x - lvl1.x, pmouse.y - lvl1.y);
			var angleToMouse = Math.atan2(p2.y - p1.y, p2.x - p1.x);

			if (mdown) {
				gun_delay++;
				if (mdown1 || gun_delay == 10) {
					gun_delay = 0;
					mdown1 = false;
					var b: Particle = new Particle();
					b.graphics.beginFill(0x0000FF);
					//	
					//circle.graphics.drawCircle(3, 3, 30);
					//circle.x = pmouse.x-lvl1.x;
					//circle.y= pmouse.y-lvl1.y;

					//circle.x = ball1.x-lvl1.x;
					//circle.y= ball1.y-lvl1.y;
					b.graphics.lineStyle(2, 0x111111, 1);





					b.bm = (new Point(p2.x - p1.x, p2.y - p1.y));
					b.bm.normalize(1);
					var bullet_length: Number = 10;
					var bullet_offset: Number = 35;
					p1.x = b.bm.x * bullet_offset + p1.x;
					p1.y = b.bm.y * bullet_offset + p1.y;
					b.graphics.moveTo(p1.x, p1.y);
					p2.x = b.bm.x * bullet_length + p1.x;
					p2.y = b.bm.y * bullet_length + p1.y;
					b.graphics.lineTo(p2.x, p2.y);
					b.lvlp = new Point(ball1.x, ball1.y);
					bullets.push(b);

					lvl1.addChild(b);
					sgun1.play();
				}



			}
			var bl: Particle;
			var bullet_speed: Number = 1;
			for (var i = 0; i < bullets.length; i++) {
				bl = bullets[i] as Particle;
				if (bl != null) {
					bl.x += bl.bm.x * bullet_speed;
					bl.y += bl.bm.y * bullet_speed;
					if (i == 0) {
						var ncol = lvl1.numChildren;
						for (var colidx = 0; colidx < ncol; colidx++) {
							m = DisplayObject(lvl1.getChildAt(colidx));
							if(m.name=="instance3")continue;
							if(m is Particle)continue ;

								if (bl.hitTestObject(m)) {
									bullets[i].parent.removeChild(bullets[i]);
									bullets.splice(i,1);
									i--;
									break;
									
								}
							
							
						}
						//if(bl.y<0||bl.y>stage.stageHeight){
						//	bullets.splice(i,1);
						//	i--;
						//trace("bullet removed "+bl.y);
						//}
					}
				}
			}
			//Start your custom code
			// This example code displays the words "Entered frame" in the Output panel.
			var lp: Point = new Point(ball1.x, ball1.y);
			ball1.x += dir.x * speed;
			ball1.y += dir.y * speed;
			dir = dir.add(acceleration);
			if (ball1.x < 0) {
				ball1.x = 0;
				dir.x = 0;
			}
			if (ball1.y < 0) {
				ball1.y = 0;
				dir.y = 0;
			}

			if (ball1.x + ball1.width > stage.stageWidth) {
				ball1.x = stage.stageWidth - ball1.width;

				dir.x = 0;
			}
			if (ball1.x > 3 * stage.stageWidth / 5) {
				var shift = ball1.x - 3 * stage.stageWidth / 5
				ball1.x -= shift;
				lvl1.x -= shift;

			}
			if (ball1.x < 2 * stage.stageWidth / 5) {
				var shift2 = 2 * stage.stageWidth / 5 - ball1.x;
				ball1.x += shift2;
				lvl1.x += shift2;
			}
			var on_ground = false;
			if (ball1.y + ball1.height > stage.stageHeight) {
				ball1.y = stage.stageHeight - ball1.height;
				dir.y = 0;
				on_ground = true;
			}

			var m: DisplayObject;
			lvl1.getChild
			var ncol = lvl1.numChildren;
			for (var colidx = 0; colidx < ncol; colidx++) {
				m = DisplayObject(lvl1.getChildAt(colidx));
				if(m.name=="instance3")continue;



				if (ball1.hitTestObject(m)) {
					
					var p1x = ball1.x + ball1.width / 2;
					var p1y = ball1.y + ball1.height;
					var circle2: Shape = new Shape();
					circle2.graphics.beginFill(0x0000FF);
					//ball1.alpha=.5;
					var foundcp = false;
					if (m.hitTestPoint(p1x, p1y, true)) {

						//	ball1.alpha=.25;
						//	circle.graphics.beginFill(0x00FF00);


						var lp1: Point = new Point(lp.x + ball1.width / 2, lp.y + ball1.height);
						if (m.hitTestPoint(p1x, lp1.y, true)) {
							lp1.y -= 5;
						}
						for (var iter = 0; iter < 10; iter++) {
							//p1x=(lp1.x+p1x)/2;
							p1y = (lp1.y + p1y) / 2;
							if (!m.hitTestPoint(p1x, p1y, true)) {
								foundcp = true;
								break;
							}
						}

					}
					if (dir.y > 0 && foundcp) {
						dir.y = 0;
						ball1.y = p1y + -ball1.height;
						on_ground = true;

					}
					//	circle2.graphics.drawCircle(3, 3, 3);
					//circle2.x = p1x;
					//circle2.y=p1y;
					//addChild(circle2);

				}
			}

			if (on_ground) {
				if (jump_request) {
					//trace("jump attempt");
					jump_request = false;
					dir.y = -JUMP_SPEED;
				}
			}

			gun1.x = ball1.x + ball1.width / 2;
			gun1.y = ball1.y + ball1.height / 2;
			//var gw=gun1.scaleX;
			//trace(gun1.scaleX);
			gun1.rotation = angleToMouse * 57.2957795;
			if (gun1.rotation > 90 || gun1.rotation < -90) {
				gun1.scaleX = -gsx;
				gun1.rotation = (gun1.rotation + 180);

			} else {
				gun1.scaleX = gsx;

			}
			// End your custom code

		}
		function handleInput() {
			dir.x = 0;
			if (left) {

				dir.x = -1;
			}

			/*dir.y=0;
	if(up){
		dir.y=-1;
	}
	if(down){
		dir.y=1;
	}/**/
			/*var p:Point=new Point(dir.x,dir.y);
	p.normalize(1);
	dir.x=p.x;
	dir.y=p.y;*/

			if (right) {
				dir.x = 1;
			}


			if (space || up) {
				jump_request = true;
			} else {
				jump_request = false;
			}

		}




		function fl_KeyboardDownHandler(event: KeyboardEvent): void {
			if (event.keyCode == 37 || event.keyCode == 65) {

				left = true;
			}
			if (event.keyCode == 38 || event.keyCode == 87) {
				up = true;
			}
			if (event.keyCode == 39 || event.keyCode == 68) {
				right = true;
			}
			if (event.keyCode == 40 || event.keyCode == 83) {
				down = true;
			}
			if (event.keyCode == 32) {
				space = true;
			}

			//	trace("Key Code Pressed: " + event.keyCode);
		}
		function fl_KeyboardUpHandler(event: KeyboardEvent): void {
			if (event.keyCode == 37 || event.keyCode == 65) {

				left = false;
			}
			if (event.keyCode == 38 || event.keyCode == 87) {
				up = false;
			}
			if (event.keyCode == 39 || event.keyCode == 68) {
				right = false;
			}
			if (event.keyCode == 40 || event.keyCode == 83) {
				down = false;
			}
			if (event.keyCode == 32) {
				space = false;
			}


		}



	}
}