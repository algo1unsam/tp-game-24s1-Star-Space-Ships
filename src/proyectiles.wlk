import wollok.game.*
import extras.*

class Disparo
{
	var property position
	const property etiquetaTickMovement = "mover"+self.toString()  
	const imagen
	method image() = imagen
	method danio() = 10
	method haceDanio(jugador)
	{
		jugador.recibeDanio(self.danio())
	}
	method interaccionCon(jugador)
	{
		self.haceDanio(jugador)
	}
	method sonido(sonidoDeFondo)
	{
		game.sound(sonidoDeFondo).shouldLoop(false)
		game.sound(sonidoDeFondo).play()
	}
	method colocarProyectil(_chara)
	{
		self.evaluarComportamiento(_chara)
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("blaster.mp3")})
	}
	
	method moverIzq()
	{
		position = self.position().left(1)
	}
	method moverDer()
	{
		position = self.position().right(1)
	}
	
	//Detiene el movimiento de los tiros
	method detenerMovimiento()
	{
		game.removeTickEvent(etiquetaTickMovement)
		game.removeVisual(self)
	}
	
	//Si un tiro no impacta, se autodestruye en 1000 ticks
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
		game.onTick(50,etiquetaTickMovement,{=> self.moverIzq()})
	}
	method comportamientoDerecha()
	{
		game.onTick(50,etiquetaTickMovement,{=> self.moverDer()})
	}
	method subir(nave){}
}

class DisparoVertical inherits Disparo
{
	override method danio() = 30

	method moverArriba()
	{
		position = self.position().up(1)
	}
	method moverAbajo()
	{
		position = self.position().down(1)
	}
	method comportamientoArriba()
	{
		game.onTick(100,etiquetaTickMovement,{=> self.moverArriba()})
	}
	method comportamientoAbajo()
	{
		game.onTick(100,etiquetaTickMovement,{=> self.moverAbajo()})
	}
	override method evaluarComportamiento(_chara)
	{
		_chara.estadoVertical().comportamientoDireccional(self)
	}
	
}
//IMPORTANTE Ver que le podemos poner para que sea una opción viable que dispare vertical
class DisparoDiagonal inherits DisparoVertical
{
	override method comportamientoDerecha()
	{
		game.onTick(100,etiquetaTickMovement,{=> self.moverDer() self.moverArriba()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,etiquetaTickMovement,{=> self.moverIzq() self.moverArriba()})
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
		game.onTick(100,etiquetaTickMovement,{=> self.moverDer() self.moverAbajo()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,etiquetaTickMovement,{=> self.moverIzq() self.moverAbajo()})
	}
}




//Armas
class Armamento
{
	method image(_chara) = 	_chara.nombre() + "spell_" + _chara.direccion().nombre() + ".png"
	method dispararProyectil(_chara,proyectil)
	{
		proyectil.colocarProyectil(_chara)
		proyectil.automaticSelfDestruction()
		game.schedule(100,{=>_chara.estado(reposo)})
	}
	
	method dispararProyectil1(_chara)
	{
		const proyectil = new Disparo(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
	}
}

class Rifle inherits Armamento{
	var property contador = 18
	var cooldown = 1
	
	
	method balaInit(nave)=if(nave.direccion()==derecha){return new Disparo(position=nave.position().right(1),imagen=self.image(nave))}
	else{return new Disparo(position=nave.position().left(1),imagen=self.image(nave))}
	
	
	 method dispararProyectil2(nave){
		
			cooldown = 0
			if(not self.vacio() and cooldown == 1)
			self.dispararProyectil(nave,self.balaInit(nave))
			game.schedule(100,{
				self.dispararProyectil(nave,self.balaInit(nave))
				game.schedule(100,{
					self.dispararProyectil(nave,self.balaInit(nave))
					game.schedule(100,{ 
						self.dispararProyectil(nave,self.balaInit(nave))
						self._cooldown()
					})
				})
			})
	}
	
	override method dispararProyectil( nave,proyectil){
		super(nave,proyectil)
		contador = contador - 1	
	}
	
	method vacio(){return contador == 0}
	
	method _cooldown(){
		game.schedule(600,{=> cooldown = 1})
	}
	
	method recargar(){contador = contador + 12}//

}


object armamentoNave1 inherits Armamento
{
	method dispararProyectil2(_chara)
	{
		const proyectil = new DisparoVertical(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
	}
}

object armamentoNave2 inherits Armamento
{
	method dispararProyectil2(_chara)
	{
		const proyectil = new DisparoDiagonal(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
	}
}
object armamentoC inherits Armamento
{
	method dispararProyectil2(_chara)
	{
		const proyectil = new DisparoDiagonalInferior(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
	}
}

object rifle inherits Rifle{
	
}