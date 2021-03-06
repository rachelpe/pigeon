package br.eng.mosaic.pigeon.web.entities 
{
	import br.eng.mosaic.pigeon.web.world.LevelComplete;
	import br.eng.mosaic.pigeon.web.world.MyWorld;
	import br.eng.mosaic.pigeon.web.world.TelaInicial;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;	
	
	public class Pigeon extends Entity
	{
		private var gritou:Boolean = false;
		private var dead:Boolean=false;
		private var deadCount:int = 0;
		private const deadCountLimit:int = 50;
		
		private var velocity:int = 1;
		
		[Embed(source = 'br/eng/mosaic/pigeon/web/assets/pombo_sprite.png')]
		private const pigeon:Class; 
		
		[Embed(source = 'br/eng/mosaic/pigeon/web/assets/explosao.png')]
		private const EXPLOSAO:Class; 
		
		[Embed(source = 'br/eng/mosaic/pigeon/web/assets/gritao.mp3')]
		private const GRITO:Class;
		public var grito:Sfx = new Sfx(GRITO);
		
		public var sprPigeon:Spritemap;
		
		public function Pigeon()
		{
		
			sprPigeon = new Spritemap(pigeon, 90, 110);
			sprPigeon.add("voo", [1, 0, 2, 0], 10, true); 
			graphic = sprPigeon;
			
			//O tamanho acertável é 10x10 menor, e o centro fica 5x5 desclocado, para 
			//o hitbox continuar central
			setHitbox(80,100, 5, 5);
			
			y=300;
		}
		
		private function die():void{
			//O pombo vira uma nuvem explodida
			var cloud:Cloud = new Cloud();
			cloud.x = x;
			cloud.y = y;
			world.add(cloud);
			
			//e as penas voam. cada uma aparece em uma quina do pombo
			var pena:Pena = new Pena(Pena.PLAYER, x - 10, y);
			world.add(pena);
			pena = new Pena(Pena.PLAYER, x +(this.width), y - 10);
			world.add(pena);
			pena = new Pena(Pena.PLAYER, x, y + (this.height/2));
			world.add(pena);
			pena = new Pena(Pena.PLAYER, x +(this.width/2), y + (this.height/2) + 20);
			world.add(pena);
			
			this.graphic = null;
			dead = true;
			
			//world.remove(this);
		}
		
		public function finalize():void{
			velocity += 5;
		}
		
		override public function update():void {
			super.update();
			
			//Check de colisões
			if (x < FP.width && !dead) {
				sprPigeon.play("voo")
				x+=velocity;
				
				MyWorld.userX = x;
				MyWorld.userY = y;
				
				//Morte do pombo
				if (collide("enemy", x, y)) {
					die();
				}
			
			//Venceu
			} else if (x >= FP.width && !dead){
				FP.world = new TelaInicial;
				TelaInicial.pontuacao += 1;
			}
			
			if (dead) {
				if (!gritou) {
					grito.play();
					gritou = true;
				}
				if (deadCount++ >= deadCountLimit) {
					world.remove(this);
					FP.world = new TelaInicial;
				}
			}
			
			//Movimento do pombo
			if (Input.check(Key.RIGHT)||Input.check(Key.D)){
				x+=1;
			}
			if (Input.check(Key.LEFT)||Input.check(Key.A)){
				x-=1;
			}
			if (Input.check(Key.UP)||Input.check(Key.W)){
				y-=1;
			}
			if (Input.check(Key.DOWN)||Input.check(Key.S)){
				y+=1;
			}

		}
	}
}