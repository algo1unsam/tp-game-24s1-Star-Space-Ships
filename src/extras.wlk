import wollok.game.*
import naves.*
import niveles.*
import proyectiles.*
import armas.*
//
class Vida
{
	const jugador
	method image() = "assets/"+jugador.vidas().toString()+"corazones.png"
	method esEnemigo()=false
	method interaccionCon(unJugador){}
}
object vida1 inherits Vida(jugador = jugador1) {
	method position()= game.at(1, 9)
}

object vida2 inherits Vida(jugador = jugador2) {
	method position()= game.at(17, 9)
}
object color
{
	method blanco()	= "FFFFFF"
}

class Energia
{
	const jugador
	const life
	method position() = life.position().down(1).right(1)
	method textColor() = color.blanco()
	method text() = jugador.energia().toString()
	method tieneVida()=false
	method esEnemigo()=false
	method interaccionCon(unJugador){}
}



object energia1 inherits Energia(jugador = jugador1, life = vida1){}
object energia2 inherits Energia(jugador = jugador2, life = vida2){}

object derecha
{
	method nombre() = "der"
	method comportamientoDireccional(disparo){disparo.comportamientoDerecha()}
	method nuevaPosicion(personaje){return personaje.position().right(1)}
	method repelerADireccionOpuesta(personaje){personaje.moverIzquierda()}
	method mover(personaje){personaje.moverDerecha()}
	
}
object izquierda
{
	method nombre() = "izq"
	method comportamientoDireccional(disparo){disparo.comportamientoIzquierda()}
	method nuevaPosicion(personaje){return personaje.position().left(1)}
	method mover(personaje){personaje.moverIzquierda()}
}

object arriba{
	method mover(personaje){personaje.moverArriba()}
	method nuevaPosicion(personaje){return personaje.position().up(1)}
}

object abajo{
	method mover(personaje){personaje.moverAbajo()}
	method nuevaPosicion(personaje){return personaje.position().down(1)}
}

class Orbe{
	
	var property posicionInicial = 0
	method randomXP1() = 0.randomUpTo(9)
	method randomXP2()=11.randomUpTo(20)
	method randomY() = 0.randomUpTo(game.height())
	method image() 
	method position() = posicionInicial
	method esEnemigo()=false
	
	method agregarOrbeP1()
	{
		posicionInicial =game.at(self.randomXP1(),self.randomY())
		game.addVisual(self)
		game.schedule(7000,{self.quitarOrbe(jugador1)})
	}
	
	method agregarOrbeP2(){
		posicionInicial =game.at(self.randomXP2(),self.randomY())
		game.addVisual(self)
		game.schedule(7000,{self.quitarOrbe(jugador2)})
	}
	
	method quitarOrbe(pantallaJugador){
		if(game.allVisuals().contains(self)){
			game.removeVisual(self)
			self.regenerarOrbe(pantallaJugador)
		}
	}
	
	method regenerarOrbe(jugador)
	
	method removerPng(jugador) 
	{
		game.removeVisual(self)
		self.regenerarOrbe(jugador)
	}
	method recarga(jugador)

	method interaccionCon(jugador)
	{	if(not jugador.nave().esEnemigo())
		self.recarga(jugador)
	}
	
	method pantallaJugador1(jugador)=jugador.nave().position().x()<10
	
	method seleccionPantalla(jugador)=if(self.pantallaJugador1(jugador)){self.agregarOrbeP1()}
	else {self.agregarOrbeP2()}
	
	
	
}

class OrbeEnergia inherits Orbe
{
	const energiaQueRestaura = 10
	
	override method image() = "assets/orbe-azul.png"
	
	override method regenerarOrbe(jugador)
	{
		game.schedule(15000,{=>self.seleccionPantalla(jugador)})
	}
	
	override method recarga(jugador)
	{
		jugador.recargaEnergia(energiaQueRestaura)
		self.removerPng(jugador)
	}
	
}

class OrbeVida inherits Orbe
{
	const property recargaVida = 10
	
	override method image() = "assets/llave.png"
	
	override method regenerarOrbe(jugador)
	{
		game.schedule(15000,{=>self.seleccionPantalla(jugador)})
	}
	
	override method recarga(jugador)
	{
		jugador.recargaVida(recargaVida)
		self.removerPng(jugador)
	}
	
}


class OrbeArma inherits Orbe{
		
	method recarga() 
	method arma()
	method armaInstancia()
	
	method recargarArma(arma)=arma.carga(arma.carga()+self.recarga())
	
	method armaEnUso(jugador)=jugador.nave().armamento().last()==self.armaInstancia()
	
	method tieneArma(jugador)=jugador.nave().armamento().any({arma=>self.seleccionarArma(arma)})
	
	method seleccionarArma(arma)=self.arma().equals(arma.toString())
	
	method armaARecargar(jugador)=jugador.nave().armamento().find({arma=>self.seleccionarArma(arma)})
	
	override method recarga(jugador)
	{
		////Colecciones
		if(self.tieneArma(jugador)){//Si tiene el arma la recarga, caso contrario la añade a la lista cargada y queda como arma actual
			self.recargarArma(self.armaARecargar(jugador))
		}
		else{
		jugador.nave().armamento().add(self.armaInstancia())
		jugador.nave().armaActual(jugador.nave().armamento().last())
		jugador.nave().armaActual().carga(self.recarga())
		}	
		self.removerPng(jugador)
	}	
}

class OrbeRafaga inherits OrbeArma{
	
	override method recarga()=12
	override method image() = "assets/orbe-naranja.png"
	override method arma()="un/a  Rafaga"
	override method armaInstancia()=new Rafaga()
	
	
	override method regenerarOrbe(jugador)//Distinto tiempo que el orbe Energia
	{
		game.schedule(20000,{=>self.seleccionPantalla(jugador)})
	}
	
}

class OrbeMisil inherits OrbeArma{
	
	override method recarga()=3
	override method image() = "assets/orbe-violeta.png"
	override method arma()="un/a  Misil"
	override method armaInstancia()=new Misil()
	
	
	override method regenerarOrbe(jugador)
	{
		game.schedule(30000,{=>self.seleccionPantalla(jugador)})
	}
}

class OrbeDirigido inherits OrbeArma{
	
	override method recarga()=1
	override method image() = "assets/orbeDirigido.png"
	override method arma()="un/a  ArmaTeledirigida"
	override method armaInstancia()=new ArmaTeledirigida()
	
	
	override method regenerarOrbe(jugador)
	{
		game.schedule(40000,{=>self.seleccionPantalla(jugador)})
	}
}


object reguladorDeEnergia
{
	var check = 0
	method maxEnergia(jugador)
	{
		check = jugador.energia()
		if(check > 100){
			jugador.energia(100)
		}
	}
	method minEnergia(jugador)
	{
		check = jugador.energia()
		if(check < 0){
			jugador.energia(0)
		}
	}
	method validarEnergia(jugador)
	{
		self.minEnergia(jugador)
		self.maxEnergia(jugador)
	}
}

class EnergiaPng{
	const position
	method position()= position.position().left(1)
	method image()="assets/energiaPng.png"
	method interaccionCon(unJugador){}
}

object energia1Png inherits EnergiaPng(position = energia1){}
object energia2Png inherits EnergiaPng(position = energia2){}

