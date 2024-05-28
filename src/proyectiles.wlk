import wollok.game.*
import extras.*
import naves.*

class Disparo
{
	var property position
	const property imagen
	
	method etiquetaTickMovement() = "mover"+self.toString()  
	method image() = imagen
	method danio() = 10
	method tieneVida()=false
	method haceDanio(jugador)
	{
		jugador.recibeDanio(self.danio())
	}
	method interaccionCon(jugador)
	{
		self.haceDanio(jugador)
	}
	
	/*if(game.colliders(self).any({objeto => objeto.golpeable()}))
			{
			impacto.impactar(self)
			self.explotar(self.position().x(), self.position().y())
			game.removeTickEvent(evento)
			game.removeVisual(self)
			}})}*/
	
	method impacto(){
		game.onCollideDo(self,{objeto=>if(objeto.tieneVida()){self.interaccionCon(objeto)}})
	}

	method sonido(sonidoDeFondo)
	{
		game.sound(sonidoDeFondo).shouldLoop(false)
		game.sound(sonidoDeFondo).play()
	}
	method colocarProyectil(_chara)
	{
		
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("blaster.mp3")
			})
			self.evaluarComportamiento(_chara)	
		
	}
	
	method moverIzquierda()
	{ 	
		position = self.position().left(1)
		
		
	}
	method moverDerecha()
	{
		position = self.position().right(1)
		
	}
	
	method moverArriba()
	{
		position = self.position().up(1)
		
	}
	method moverAbajo()
	{
		position = self.position().down(1)
		
	}
	
	
	//Detiene el movimiento de los tiros
	method detenerMovimiento()
	{
		game.removeTickEvent(self.etiquetaTickMovement())
		game.removeVisual(self)
	}
	
	//Si un tiro no impacta, se autodestruye en 1500 ticks
	method automaticSelfDestruction()
	{
			game.schedule(1500,{self.detenerMovimiento()})
	}
	
	
	method evaluarComportamiento(_chara)
	{
		_chara.direccion().comportamientoDireccional(self)
		
	}
	method comportamientoIzquierda()
	{
		game.onTick(50,self.etiquetaTickMovement(),{=> self.moverIzquierda()})
		
	}
	method comportamientoDerecha()
	{
		game.onTick(50,self.etiquetaTickMovement(),{=> self.moverDerecha()})
	}
	
	method comportamientoArriba()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverArriba()})
	}
	
	method comportamientoAbajo()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverAbajo()})
	}
	
	
}

//IMPORTANTE Ver que le podemos poner para que sea una opción viable que dispare vertical=> Unifico métodos de disparo vertical 
//en class Disparo y cambio los especiales

class DisparoDiagonal inherits Disparo
{
	override method comportamientoDerecha()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverDerecha() self.moverArriba()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverIzquierda() self.moverArriba()})
	}
	override method evaluarComportamiento(_chara)
	{
		_chara.direccion().comportamientoDireccional(self)
	}
}

class DisparoDiagonalInferior inherits DisparoDiagonal
{
	override method comportamientoDerecha()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverDerecha() self.moverAbajo()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverIzquierda() self.moverAbajo()})
	}
}

class DisparoEspecial inherits Disparo{
	
	var property arriba= new DisparoDiagonal(position=self.position(), imagen=self.imagen())
	var property abajo=new DisparoDiagonalInferior(position=self.position(), imagen=self.imagen())
	override method colocarProyectil(_chara)
	{
		abajo.evaluarComportamiento(_chara)
		arriba.evaluarComportamiento(_chara)
		game.schedule(100,
			{=>	game.addVisual(arriba)
				game.addVisual(abajo)
				self.sonido("blaster.mp3")})
	}
	
	override method automaticSelfDestruction()
	{
			game.schedule(1500,{arriba.detenerMovimiento()
								abajo.detenerMovimiento()
			})
	}
}


//Armas
