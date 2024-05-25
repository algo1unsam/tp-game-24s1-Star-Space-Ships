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
		game.onTick(50,self.etiquetaTickMovement(),{=> self.moverIzq()})
	}
	method comportamientoDerecha()
	{
		game.onTick(50,self.etiquetaTickMovement(),{=> self.moverDer()})
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
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverDer() self.moverArriba()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverIzq() self.moverArriba()})
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
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverDer() self.moverAbajo()})
	}
	override method comportamientoIzquierda()
	{
		game.onTick(100,self.etiquetaTickMovement(),{=> self.moverIzq() self.moverAbajo()})
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
class Armamento
{
	method image(_chara) = 	_chara.nombre() + "spell_" + _chara.direccion().nombre() + ".png"
	method dispararProyectil(_chara,proyectil)
	{
		proyectil.colocarProyectil(_chara)
		proyectil.automaticSelfDestruction()
		//game.schedule(100,{=>_chara.estado(reposo)})
	}
	
	method dispararProyectil1(_chara)
	{
		const proyectil = new Disparo(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
	}
}

class Rafaga inherits Armamento{
	var property carga = 18
	var cooldown = 1
	
	
	method balaInit(nave)=if(nave.direccion()==derecha){return new Disparo(position=nave.position().right(1),imagen=self.image(nave))}
	else{return new Disparo(position=nave.position().left(1),imagen=self.image(nave))}
	
	
	 method dispararProyectil2(nave){
		
			cooldown = 1
			if((not self.vacio()) and cooldown == 1)
			{
			cooldown=0
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
			else{
				nave.armamento().remove(nave.armamento().last())
				nave.armaActual(nave.armamento().last())
			}
	}
	
	override method dispararProyectil( nave,proyectil){
		carga = carga - 1
		super(nave,proyectil)
			
	}
	
	method vacio()=carga<=0
					
	method _cooldown(){
		game.schedule(600,{=> cooldown = 1})
	}

}


class Misil inherits Armamento{
	
	var property contador = 3
	var cooldown = 1
	
	override method image(_chara)="Misil"+_chara.direccion()+".png"
	
	method init(nave)=if(nave.direccion()==derecha){return new Explosivo(position=nave.position().right(1),imagen =self.image(nave))}
	else{return new Explosivo(position=nave.position().left(1),imagen =self.image(nave))}
	
	method dispararProyectil2(nave){
		if((not self.vacio()) and cooldown == 1){
			cooldown = 0
			self.dispararProyectil(nave,self.init(nave))
			contador = contador - 1
			self._cooldown()
		}
		
	
	}
	
	override method dispararProyectil1(nave){
		super(nave)
		//new Armamento().dispararProyectil1(nave)
	}
	
	method vacio(){return contador == 0}
	
	method _cooldown(){
		game.schedule(2500,{=> cooldown = 1})
	}
	
}

class Explosivo inherits Disparo{
	
	
	override method danio()=50
	
	override method interaccionCon(jugador)
	{	
		game.removeTickEvent(self.etiquetaTickMovement())	
		self.explotar(jugador.nave().position().x(),jugador.nave().position().y())
		game.schedule(600,({self.haceDanio(jugador) game.removeVisual(self)}))	
			
	}
	
	override method automaticSelfDestruction(){
		game.schedule(2500,{if(game.allVisuals().contains(self)){self.detenerMovimiento()}})
	}
	
	override method colocarProyectil(_chara)
	{
		self.evaluarComportamiento(_chara)
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("misil.mp3")})
	}
	
	
	method explotar(positionX, positionY){
		(positionX-2..positionX+2).forEach({n => new Explosion().explotar(n,positionY)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY+1)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY-1)})
		new Explosion().explotar(positionX, positionY+2)
		new Explosion().explotar(positionX, positionY-2)
	}	
}

class Explosion {
	method image(){return "explosion.png"}
	
	method position()=game.origin()
	
	method explotar(positionX, positionY){
		game.addVisualIn(self, game.at(positionX,positionY))
		game.schedule(500,({game.removeVisual(self)}))
	}
}




object especialNave1 inherits Armamento
{
	method dispararProyectil2(_chara)
	{
		3.times({iter=>_chara.disparo()})
		const proyectil = new DisparoEspecial(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
		self.dispararProyectil1(_chara)
		
	}
}

object especialNave2 inherits Armamento
{
	method dispararProyectil2(_chara)
	{	
		3.times({iter=>_chara.disparo()})
		const proyectil1 = new Disparo(position = _chara.position().up(3), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(3),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
		game.schedule(200,{self.dispararProyectil1(_chara)})
	}
}
object especialNave3 inherits Armamento
{
	method dispararProyectil2(_chara)
	{	
		3.times({iter=>_chara.disparo()})
		self.dispararProyectil1(_chara)
		const proyectil1 = new Disparo(position = _chara.position().up(1), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(1),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
	}
}

object armamentoEnemigo inherits Armamento{
	
	
}

object rafaga inherits Rafaga{
}

object misil inherits Misil{}