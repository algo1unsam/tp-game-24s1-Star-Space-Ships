import wollok.game.*
import naves.*
import pantallas.*
import extras.*
import enemigo.*

class Fondo{
	const property position = game.origin()
	var property image
	method interaccionCon(jugador){}
	method sonido(sonidoDeFondo)
	{
		sonidoDeFondo.shouldLoop(true)
		sonidoDeFondo.volume(0.5)
		game.schedule(150, {sonidoDeFondo.play()})
	}
	
	
}

class Marco{
	var property position
	var property image
	var movimiento = true
	var x1
	var x2
	
	method movimiento() = movimiento
	
	method liberarMovimiento()
	{
		movimiento = true
	}
	
	method bloquearMovimiento(){
		movimiento = false
	}
	
	method irALosLados(nuevaPosicion){
		if (self.validarRango(nuevaPosicion)){
			position = nuevaPosicion
		}
	}
	
	method validarRango(nuevaPosicion){
		return nuevaPosicion.x().between(x1,x2)
	}
	
}

class Escenario{
	var property position
	var property image
	var property sonidoDeFondo
	
}

object portada{
	const testeo = new Fondo(image="portada.png")
	const intros = game.sound("track6.mp3")
	method iniciar(){
		game.addVisual(testeo)
		keyboard.enter().onPressDo{instrucciones.iniciar(intros)}
		intros.shouldLoop(true)
		intros.volume(0.5)
		game.schedule(150, {intros.play()})

			}
		}

object instrucciones{
	method iniciar(intro){
		intro.stop()
		game.clear()
		game.addVisual(new Fondo(image="controles.png"))
		keyboard.enter().onPressDo{seleccionEscenarios.iniciar()}
		
		
	}//
}

object seleccionEscenarios{
	var property cualFondo
	const property marco3 = new Marco(position = game.at(2,3), image = "marco3.png", x1 = 2, x2 = 16)
	method space()		  = new Escenario( position = game.at(2,3), image = "spaceSmall.png", sonidoDeFondo = game.sound("track1.mp3") )
	method clouds()	  = new Escenario( position = game.at(6,3), image = "cloudsSmall.png", sonidoDeFondo = game.sound("track2.mp3"))
	method pinkNebula()	  = new Escenario( position = game.at(10,3), image = "pinknebulaSmall.png", sonidoDeFondo = game.sound("track3.mp3"))
	method futuro() 	  = new Escenario( position = game.at(14,3), image = "futureSmall.png", sonidoDeFondo = game.sound("track4.mp3"))
	
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="escenario.png"))
		self.agregarEscenarios()
		self.agregarTeclas()
	}
	
	method agregarEscenarios(){
		game.addVisual(self.space())
		game.addVisual(self.clouds())
		game.addVisual(self.pinkNebula())
		game.addVisual(self.futuro())
		game.addVisual(marco3)//y agregamos marco ya que estamos
	}
	
	method agregarTeclas(){
		keyboard.enter().onPressDo{if (marco3.movimiento()){
									marco3.bloquearMovimiento()
									cualFondo = game.uniqueCollider(marco3)
									seleccionNaves.iniciar()
									}}
									//IMPORTANTE ponerlo dentro de un method
		keyboard.left().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().left(4))}}
		keyboard.right().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().right(4))}}
	}
	
}

object seleccionNaves{
	var property n1 = new Nave1(position=game.at(7,4))
	var property n2 = new Nave2(position=game.at(9,4))
	var property n3 = new Nave3(position=game.at(11,4))
	
	var property marco1 = new Marco(position = game.at(7,4), image = "marco1.png", x1 = 7, x2 = 12)
	var property marco2 = new Marco(position = game.at(9,4), image = "marco2.png", x1 = 7, x2 = 12)
	
	var property jugador1Ok = false
	var property jugador2Ok = false
	
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="instrucciones.png"))
		self.agregarNaves()
		self.agregarTeclas()
		
	}
	
	method agregarNaves(){
		game.addVisual(new Fondo(image="seleccion.png"))
		game.addVisual(n1)
		game.addVisual(n2)
		game.addVisual(n3)
		game.addVisual(marco1)//y agregamos marcos ya que estamos
		game.addVisual(marco2)
	}

	method escogerNave(_marco,playerSelecc){//unificado
		
		const nave=game.uniqueCollider(_marco)	
	
		if (not (marco1.position()==marco2.position())) {
		 _marco.bloquearMovimiento()
		 playerSelecc.nave(nave)
		 nave.jugador(playerSelecc)
		 playerSelecc.naveSeleccionada(true)
		 }	 
		 self.navesSeleccionadas()
	}
	
	
	method agregarTeclas(){
		keyboard.enter().onPressDo{self.iniciar()}
		keyboard.a().onPressDo{if (marco1.movimiento()){marco1.irALosLados(marco1.position().left(2))}	}
		keyboard.d().onPressDo{if (marco1.movimiento()) {marco1.irALosLados(marco1.position().right(2))}}
		keyboard.e().onPressDo{if (marco1.movimiento()){self.escogerNave(marco1,jugador1)}}
						//IMPORTANTE method con parametros para elección de pjs
						//Modificado	
		keyboard.left().onPressDo{if (marco2.movimiento()) {marco2.irALosLados(marco2.position().left(2))}}
		keyboard.right().onPressDo{if (marco2.movimiento()) {marco2.irALosLados(marco2.position().right(2))}}
		keyboard.l().onPressDo{if (marco2.movimiento()){self.escogerNave(marco2,jugador2)}}
					
		}
		
	method navesSeleccionadas()=if(self.seleccionNavesOk()){batalla.iniciar()}else{}
	
	method seleccionNavesOk()= jugador1.naveSeleccionada() and jugador2.naveSeleccionada()
		
}



object colisiones
{	
	var property jugadores = [jugador1,jugador2]
	
	
	
	method validar()
	{   
		
		
		
		jugadores.forEach{jugador => 
			game.onCollideDo(jugador.nave(),{objeto => objeto.interaccionCon(jugador)})
			game.onTick(100,"validarEnergia",{=>reguladorDeEnergia.validarEnergia(jugador)})
		}
		game.onTick(100,"validarMuerte",{=>if(final.muertos(jugadores)){final.remover(jugadores)}})
	}
}


object visualesGeneral
{
	const enemigos=[new Enemigo(jugador=jugador2)]
	
	method iniciarEnemigos(){enemigos.forEach({enemigo=>enemigo.iniciar()})}
	method agregar()
	{
		const visuales = [jugador1.nave(),jugador2.nave(),vida1,vida2,energia1,energia2,energia1Png,energia2Png]
		
		visuales.forEach{ visual=>
			game.addVisual(visual)
		}
		self.agregarOrbes()
	}
	method agregarOrbes()
	{
		var time = 5000
		
		game.schedule(time,{new OrbeEnergia().agregarOrbeP1() new OrbeEnergia().agregarOrbeP2()
			game.schedule(time*2,{new OrbeRafaga().agregarOrbeP1() new OrbeRafaga().agregarOrbeP2() //self.iniciarEnemigos()
				game.schedule(time*3,{new OrbeMisil().agregarOrbeP1() new OrbeMisil().agregarOrbeP2()})
			})
			
		})
	}
}

object batalla
{
	var escenarioElegido
	var fondoElegido
	method iniciar()
	{
		escenarioElegido=seleccionEscenarios.cualFondo()
		fondoElegido = new Fondo(image=escenarioElegido.image().toString().replace("Small", ""))
		self.asignarNaves()
		game.clear()
		game.addVisual(fondoElegido)
		//game.sound("track0.mp3").pause()
		fondoElegido.sonido(escenarioElegido.sonidoDeFondo())
		
		
		visualesGeneral.agregar()
		jugador1.controles()
		jugador2.controles()
		colisiones.validar()
		final.escenario(escenarioElegido)
		
		
	}
	
	method asignarNaves(){
		jugador1.asignarNave()
		jugador2.asignarNave()		
	}
}
object final
{	
	var property escenario
	var final
	
	method finalizarBatalla(escenarioFin){
		game.clear()
		game.addVisual(final)
		escenarioFin.sonidoDeFondo().stop()
		self.iniciar()
	}
	
	// IMPORTANTE unificar validar vida, tiene que ser uno solo y el jugador/imagen sea por parametro
	//Modificado
	method remover(jugadores) {
		if (not self.elMuerto(jugadores).nave().esEnemigo()){
			jugadores.remove(self.elMuerto(jugadores))
			final = new Fondo(image="final"+self.win(jugadores.get(0)))
			self.finalizarBatalla(escenario)
		}
		else{
			jugadores.remove(self.elMuerto(jugadores))
			game.removeVisual(self.elMuerto(jugadores))
		}
	}
	
	method elMuerto(jugadores)=jugadores.find({jugador=>jugador.vidas()<=0})	
	method muertos(jugadores)=not jugadores.filter({jugador=>jugador.vidas()<=0}).isEmpty()//Controla muertos, usa colecciones
	
	method win(jugador)=jugador.toString().drop(7)+".png"//Asigna número jugador ganador

	method iniciar(){
		self.reiniciar()
		keyboard.enter().onPressDo{portada.iniciar()}
	}
	method reiniciar(){
		seleccionNaves.n1(baseDeDatos.bp1())
		seleccionNaves.n2(baseDeDatos.bp2())
		seleccionNaves.n3(baseDeDatos.bp3())


		seleccionNaves.marco1(baseDeDatos.bmarco1())
		seleccionNaves.marco2(baseDeDatos.bmarco2())
		
		seleccionEscenarios.marco3().liberarMovimiento()
		seleccionNaves.marco1().liberarMovimiento()
		seleccionNaves.marco2().liberarMovimiento()

		seleccionNaves.jugador1Ok(baseDeDatos.bjugadorOk())
		seleccionNaves.jugador2Ok(baseDeDatos.bjugadorOk())
		
		jugador1.vidas(baseDeDatos.bvida())
		jugador2.vidas(baseDeDatos.bvida())
		jugador1.energia(baseDeDatos.benergia())
		jugador2.energia(baseDeDatos.benergia())
	}
}
object  baseDeDatos{
		method bp1() = new Nave1(position=game.at(7,4),jugador=null)
		method bp2() = new Nave2(position=game.at(9,4),jugador=null)
		method bp3() = new Nave3(position=game.at(11,4),jugador=null)

		method bmarco1() = new Marco(position = game.at(7,4), image = "marco1.png", x1 = 7, x2 = 12)
		method bmarco2() = new Marco(position = game.at(9,4), image = "marco2.png", x1 = 7, x2 = 12)
		
		method bjugadorOk() = false
		
		method bvida() = 100
		method benergia()= 100
	}
