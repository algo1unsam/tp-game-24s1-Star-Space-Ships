import wollok.game.*
import naves.*
import niveles.*

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

object reposo
{
	method nombre()=""
}

object suelo{
	method comportamientoDireccional(disparo){disparo.comportamientoArriba()}
}

object aire{
	method comportamientoDireccional(disparo){disparo.comportamientoAbajo()}
}


object ataque
{
	method nombre()="_ataque"
}

class PocionEnergia
{
	const energiaQueRestaura = 10
	var posicionInicial = 0
	method cambiarPosicionEnX() = 0.randomUpTo(game.width())
	method cambiarPosicionEnY() = 0.randomUpTo(game.height())
	method image() = "pocion.png"
	method position() = posicionInicial
	method agregarPocion()
	{
		posicionInicial =game.at(self.cambiarPosicionEnX(),self.cambiarPosicionEnY())
		game.addVisual(self)
	}
	method regenerarPocion()
	{
		game.schedule(5000,{=>self.agregarPocion()})
	}
	method removerPng() 
	{
		game.removeVisual(self)
		self.regenerarPocion()
	}
	method recarga(jugador)
	{
		jugador.recargaEnergia(energiaQueRestaura)
		self.removerPng()
	}
	method interaccionCon(jugador)
	{
		self.recarga(jugador)
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

