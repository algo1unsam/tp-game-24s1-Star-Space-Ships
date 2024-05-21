import wollok.game.*
import proyectiles.*
import pantallas.*
import niveles.*
import extras.*

//JUGADORES
class Jugador
{
	var property nave
	var property vidas = 100
	var property energia = 100
	method direccionInicial()
	method posicionInicial()
	method controles()
	
	method asignarNave() {
		nave.jugador(self)
		nave.position(self.posicionInicial())
		nave.direccion(self.direccionInicial())
	}
	method recibeDanio(danio)
	{
		vidas -= danio
	}
	method gastarEnergia(gasto)
	{
		energia -= gasto
	}
	method sinEnergia() = energia <= 0
	
	method validarEnergia(){
		game.errorReporter(self.nave())
		if (self.sinEnergia()) {throw new Exception(message="Sin Energia")}
	}
	
	method recargaEnergia(pocion) 
	{
		energia += pocion
	}
}

object jugador1 inherits Jugador(nave = null){
	const property boundsPlayer=boundsP1
	override method posicionInicial() = game.at(0,0)
	override method direccionInicial() = derecha
	override method controles()
	{
		keyboard.a().onPressDo({if(boundsPlayer.left(nave))nave.moverIzquierda()})
		keyboard.d().onPressDo({if(boundsPlayer.right(nave))nave.moverDerecha()})
		keyboard.w().onPressDo({if(boundsPlayer.up(nave))nave.moverArriba()})
		keyboard.s().onPressDo({if(boundsPlayer.down(nave))nave.moverAbajo()})
		keyboard.z().onPressDo({nave.disparo1()})
		keyboard.x().onPressDo({nave.disparo2()})
	}
	
	override method asignarNave() {
		nave = seleccionNaves.quienJugador1()
		super()}
}

object jugador2 inherits Jugador(nave = null){
	
	const property boundsPlayer=boundsP2
	override method posicionInicial() = game.at(game.width()-1,0)
	override method direccionInicial() = izquierda
	override method controles()
	{
		keyboard.left().onPressDo({if(boundsPlayer.left(nave))nave.moverIzquierda()})
		keyboard.right().onPressDo({if(boundsPlayer.right(nave))nave.moverDerecha()})
		keyboard.up().onPressDo({if(boundsPlayer.up(nave))nave.moverArriba()})
		keyboard.down().onPressDo({if(boundsPlayer.down(nave))nave.moverAbajo()})
		keyboard.j().onPressDo({nave.disparo1()})
		keyboard.k().onPressDo({nave.disparo2()})
	}
	
	override method asignarNave() {
		nave = seleccionNaves.quienJugador2()
		super()
	}
}


class Nave
{
	var property direccion = derecha //La orientacion a donde la nave está apuntando. Puede ser izquierda (izq) o derecha (der)
	var property estado = reposo
	var property estadoVertical = suelo
	var property position = game.origin()
	const property armamento
	var property jugador
	
	method nombre()
	
	method image()= self.nombre() + direccion.nombre() + estado.nombre() + ".png"
	
	method moverDerecha()
	{	
				
			position = self.position().right(1)			
		
	}
	
	method moverIzquierda()
	{
	
			position = self.position().left(1)
		
	}
	
	method moverAbajo()
	{
			position = self.position().down(1)
			
		
	}
	
	method moverArriba()
	{
	
			position = self.position().up(1)			
		
	}
		
	method interaccionCon(otroJugador){}
	
	method gastarEnergia(gastoEnergetico){
		    jugador.validarEnergia()
			jugador.gastarEnergia(gastoEnergetico)
	}
	
	method disparo()
	{
		self.gastarEnergia(20)
		estado = ataque
	}
	method disparo1()
	{
		self.disparo()
		armamento.dispararProyectil1(self)
	}
	method disparo2()
	{
		self.disparo()
		armamento.dispararProyectil2(self)
	}
	
}


class Nave1 inherits Nave(armamento = armamentoNave1)
{
	override method nombre() = "nave1_"
}

class Nave2 inherits Nave(armamento = armamentoNave2)
{
	override method nombre() = "nave2_"
}

class Nave3 inherits Nave(armamento = rifle)// lleva el rifle en disparo Base.
{
	override method nombre() = "nave3_"
}
