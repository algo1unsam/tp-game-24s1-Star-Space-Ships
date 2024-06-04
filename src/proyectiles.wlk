import wollok.game.*
import extras.*
import naves.*
import niveles.*

//Superclase disparo heredan todos los proyectiles
class Disparo
{
	var property position=game.origin()
	var property imagen=""
	
	method etiquetaTickMovement() = "mover"+self.toString()  
	method image() = "assets/"+imagen
	method danio() = 10
	method esEnemigo()=false
	
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
	
	//Los disparos de armamento de nave llevan asociado movimiento izquierda o derecha
	method colocarProyectil(_chara)
	{
		
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("assets/blaster.mp3")
			})
			self.evaluarComportamiento(_chara)	
		
	}
	
	//Métodos movimiento de proyectiles
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
	
	//Dos disparos diagonales superior e inferior
	const property arriba= new DisparoDiagonal(position=self.position(), imagen=self.imagen())
	const property abajo=new DisparoDiagonalInferior(position=self.position(), imagen=self.imagen())
	
	//Cambia comportamiento del disparo normal
	override method colocarProyectil(_chara)
	{
		abajo.evaluarComportamiento(_chara)
		arriba.evaluarComportamiento(_chara)
		game.schedule(100,
			{=>	game.addVisual(arriba)
				game.addVisual(abajo)
				self.sonido("assets/blaster.mp3")})
	}
	
	override method automaticSelfDestruction()
	{//Elimina los dos ticks de movimiento asociados para los dos
			game.schedule(1500,{arriba.detenerMovimiento()
								abajo.detenerMovimiento()
			})
	}
}

class Explosivo inherits Disparo{
	//Proyectil del misil
	
	override method danio()=30
	
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
				self.sonido("assets/misil2.mp3")})
	}
	
	//Explosion visual
	method explotar(positionX, positionY){
		(positionX-2..positionX+2).forEach({n => new Explosion().explotar(n,positionY)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY+1)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY-1)})
		new Explosion().explotar(positionX, positionY+2)
		new Explosion().explotar(positionX, positionY-2)
	}	
}

class Explosion {
	
	const property explos = game.sound("assets/explosion.mp3")
	
	method esEnemigo()=false
	
	method image(){return "assets/explosion.png"}
	
	method interaccionCon(jugador){}
	method position()=game.origin()
	
	method explotar(positionX, positionY){
		game.addVisualIn(self, game.at(positionX,positionY))
		explos.shouldLoop(false)
		explos.volume(0.5)
		game.schedule(150, {explos.play()})
		game.schedule(500,({game.removeVisual(self)}))
	}
}


class ProyectilTeledirigido inherits Disparo {
	
	method seleccionarEnemigo(nave)=nave.jugador().enemigo()
	
	//Si esta alineado se mueve en el eje alineado, caso contrario busca eje con menor distancia absoluta
	method teledirigido(enemigo)=if(self.alineado(enemigo)){self.acortoDistanciaAlineado(enemigo)}else{self.acortoMenorDistanciaAbsoluta(enemigo)}
	
	method mayorAbsolutaEnX(enemigo)=(self.position().x() -enemigo.position().x()).abs() >= (self.position().y() - enemigo.position().y()).abs()
	
	method acortoMenorDistanciaAbsoluta(enemigo)=if(self.mayorAbsolutaEnX(enemigo)){self.direccionY(enemigo).mover(self)}else{self.direccionX(enemigo).mover(self)}
	
	method alineado(enemigo)=self.alineadoY(enemigo) or self.alineadoX(enemigo)	
	
	method acortoDistanciaAlineado(enemigo)=if(self.alineadoY(enemigo)){self.direccionX(enemigo).mover(self)}else{self.direccionY(enemigo).mover(self)}
	
	method alineadoX(personaje)=self.position().x() - personaje.position().x().abs()==0
 	
 	method alineadoY(personaje)= self.position().y() - personaje.position().y().abs()==0
	
	//Sentidos de la dirección del enemigo
	method direccionX(enemigo)=if(self.aIzquierda(enemigo)){izquierda}else{derecha}

	method direccionY(enemigo)=if(self.haciaAbajo(enemigo)){abajo}else{ arriba}
		
	method haciaAbajo(enemigo)=self.position().y() > enemigo.position().y()
	
	method aIzquierda(enemigo)=	self.position().x() > enemigo.position().x()
  
  //No tiene comportamiento direccional fijo sigue al enemigo 
  override method colocarProyectil(_chara)
	{	
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("assets/misil.mp3")
			})
			self.seguir(self.seleccionarEnemigo(_chara).nave())	
	}
    
	method seguir(nave){				
		game.onTick(50,self.identity().toString(),{self.teledirigido(nave)})
	}
	
	//Solo tiene un tiempo en panatalla antes de impactar para que pueda eludirse
	override method automaticSelfDestruction(){
		game.schedule(2000,{if(game.allVisuals().contains(self)){self.detenerMovimiento()}})
	}
	
	override method interaccionCon(jugador)	
		{
			game.removeTickEvent(self.identity().toString())
			game.removeVisual(self)	
			self.haceDanio(jugador)
			
		}
	
	override method detenerMovimiento(){
		game.removeTickEvent(self.identity().toString())
		game.removeVisual(self)
	}	
	
	//Suma los daños de arma de la colección del jugador que lo lanzó
	method danio(jugador)=jugador.nave().armamento().sum({arma=>arma.danioArma()})
	
	override method haceDanio(jugador){
		//Pasa como parámetro a daño al jugador que lo lanzó, el enemigo del que recibe daño
		jugador.recibeDanio(self.danio(jugador.enemigo()))
	}
	
	
}



