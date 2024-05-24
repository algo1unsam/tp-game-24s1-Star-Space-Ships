import wollok.game.*
import naves.*
import niveles.*
import proyectiles.*

class Vida
{
	const jugador
	method image() = jugador.vidas().toString()+"corazones.png"
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
	method interaccionCon(unJugador){}
}



object energia1 inherits Energia(jugador = jugador1, life = vida1){}
object energia2 inherits Energia(jugador = jugador2, life = vida2){}

object derecha
{
	method nombre() = "der"
	method comportamientoDireccional(disparo){disparo.comportamientoDerecha()}
	method repelerADireccionOpuesta(personaje){personaje.moverIzquierda()}
	method repeler(personaje){personaje.moverDerecha()}
	
}
object izquierda
{
	method nombre() = "izq"
	method comportamientoDireccional(disparo){disparo.comportamientoIzquierda()}
	method repelerADireccionOpuesta(personaje){personaje.moverDerecha()}
	method repeler(personaje){personaje.moverIzquierda()}
}

class OrbeEnergia
{
	const energiaQueRestaura = 10
	var posicionInicial = 0
	method randomXP1() = 0.randomUpTo(10)
	method randomXP2()=10.randomUpTo(20)
	method randomY() = 0.randomUpTo(game.height())
	method image() = "pocion.png"
	method position() = posicionInicial
	
	method agregarOrbeP1()
	{
		posicionInicial =game.at(self.randomXP1(),self.randomY())
		game.addVisual(self)
	}
	
	method agregarOrbeP2(){
		posicionInicial =game.at(self.randomXP2(),self.randomY())
		game.addVisual(self)
	}
	
	method regenerarOrbe(pantallaJugador)
	{
		game.schedule(15000,{=>self.orbeJugador(pantallaJugador)})
	}
	
	method removerPng(pantallaJugador) 
	{
		game.removeVisual(self)
		self.regenerarOrbe(pantallaJugador)
	}
	method recarga(jugador)
	{
		jugador.recargaEnergia(energiaQueRestaura)
		self.removerPng(jugador)
	}
	method interaccionCon(jugador)
	{
		self.recarga(jugador)
	}
	
	method orbeJugador(pantallaJugador)=if(pantallaJugador.nave().position().x()<10){self.agregarOrbeP1()}
	else self.agregarOrbeP2()
}

class OrbeArma inherits OrbeEnergia{
		
	method recarga() 
	method arma()
	method armaInstancia()
	
	method recargarArma(arma){
		arma.carga(arma.carga()+self.recarga())
	}
	
	override method recarga(jugador)
	{
		//Colecciones
		if(jugador.nave().armamento().contains(self.arma())){
			self.recargarArma(jugador.nave().armamento().find({arma=>arma.toString().equals(self.arma())}))
			
		}
		else{jugador.nave().armamento().add(self.armaInstancia())
		jugador.nave().armaActual(jugador.nave().armamento().last())
		}
		
		self.removerPng(jugador)
	}	
}

class OrbeRafaga inherits OrbeArma{
	
	override method recarga()=18
	override method image() = "orbe-naranja.png"
	override method arma()="un/a  Rafaga"
	override method armaInstancia()=new Rafaga()
	
	
	override method regenerarOrbe(pantallaJugador)//Distinto tiempo que el orbe Energia
	{
		game.schedule(20000,{=>self.orbeJugador(pantallaJugador)})
	}
	
}

class OrbeMisil inherits OrbeArma{
	
	override method recarga()=3
	override method image() = "orbe-violeta.png"
	override method arma()="un/a  Misil"
	override method armaInstancia()=new Misil()
	
	
	override method regenerarOrbe(pantallaJugador)
	{
		game.schedule(30000,{=>self.orbeJugador(pantallaJugador)})
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
	method image()="energiaPng.png"
	method interaccionCon(unJugador){}
}

object energia1Png inherits EnergiaPng(position = energia1){}
object energia2Png inherits EnergiaPng(position = energia2){}

