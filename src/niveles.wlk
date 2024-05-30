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
	const testeo = new Fondo(image="assets/portada.png")
	const property intros = game.sound("assets/track6.mp3")
	method iniciar(){
		game.addVisual(testeo)
		keyboard.enter().onPressDo{instrucciones.iniciar()}
		intros.shouldLoop(true)
		intros.volume(0.5)
		game.schedule(150, {intros.play()})

			}
		}

object instrucciones{
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="assets/controles.png"))
		keyboard.enter().onPressDo{seleccionEscenarios.iniciar()}
		
		
	}//
}

object seleccionEscenarios{
	var property cualFondo
	const property marco3 = new Marco(position = game.at(2,3), image = "assets/marco3.png", x1 = 2, x2 = 16)
	method space()		  = new Escenario( position = game.at(2,3), image = "assets/spaceSmall.png", sonidoDeFondo = game.sound("assets/track1.mp3") )
	method clouds()	  = new Escenario( position = game.at(6,3), image = "assets/cloudsSmall.png", sonidoDeFondo = game.sound("assets/track2.mp3"))
	method pinkNebula()	  = new Escenario( position = game.at(10,3), image = "assets/pinknebulaSmall.png", sonidoDeFondo = game.sound("assets/track3.mp3"))
	method futuro() 	  = new Escenario( position = game.at(14,3), image = "assets/futureSmall.png", sonidoDeFondo = game.sound("assets/track4.mp3"))
	
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="assets/escenario.png"))
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
		self.controlMovimiento()
		
	}
	
	method controlMovimiento(){
		keyboard.left().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().left(4))}}
		keyboard.right().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().right(4))}}
	}
	
}

object seleccionNaves{
	var property n1 = new Nave1(position=game.at(7,4), jugador = "")
	var property n2 = new Nave2(position=game.at(9,4), jugador = "")
	var property n3 = new Nave3(position=game.at(11,4), jugador = "")
	
	var property marco1 = new Marco(position = game.at(7,4), image = "assets/marco1.png", x1 = 7, x2 = 12)
	var property marco2 = new Marco(position = game.at(9,4), image = "assets/marco2.png", x1 = 7, x2 = 12)
	
	var property jugador1Ok = false
	var property jugador2Ok = false
	
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="assets/instrucciones.png"))
		self.agregarNaves()
		self.agregarTeclas()
		
	}
	
	method agregarNaves(){
		game.addVisual(new Fondo(image="assets/seleccion.png"))
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
		
	method navesSeleccionadas()=if(self.seleccionNavesOk()){
		portada.intros().stop()
		batalla.iniciar()
	}else{}
	
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
	
	method validarEnemigo(enemigo){
	        if(game.allVisuals().contains(enemigo.nave())){
			game.onCollideDo(enemigo.nave(),{objeto => objeto.interaccionCon(enemigo)})
			}
		
		game.onTick(100,enemigo.nave().identity().toString()+"Validar",{=>if(final.muertos([enemigo])){final.remover([enemigo])}})
	}
	
}


object visualesGeneral
{

	
	
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
			game.schedule(time*2,{new OrbeRafaga().agregarOrbeP1() new OrbeRafaga().agregarOrbeP2() 
				new Enemigo().iniciarEnemigo(jugador1) new Enemigo().iniciarEnemigo(jugador2)
				game.schedule(time*3,{new OrbeMisil().agregarOrbeP1() new OrbeMisil().agregarOrbeP2()})
				game.schedule(time*4,{new OrbeDirigido().agregarOrbeP1() new OrbeDirigido().agregarOrbeP2()})
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
	
	method limpiarLista(jugadores){
		jugadores.clear()
		jugadores.add(jugador1)
		jugadores.add(jugador2)
	}
	
	// IMPORTANTE unificar validar vida, tiene que ser uno solo y el jugador/imagen sea por parametro
	//Modificado
	method remover(jugadores) {
		
		var muerto=self.elMuerto(jugadores)
		
		if (not muerto.nave().esEnemigo()){
			jugadores.remove(self.elMuerto(jugadores))
			final = new Fondo(image="assets/final"+self.win(jugadores))
			self.limpiarLista(jugadores)			
			self.finalizarBatalla(escenario)
		}
		else{//Si es enemigo no termina la partida
			muerto.nave().muerte()
			game.removeVisual(muerto.nave())
			jugadores.remove(muerto)
		}
	}
	
	method elMuerto(jugadores)=jugadores.find({jugador=>jugador.vidas()<=0})//seleccional al muerto
		
	method muertos(jugadores)=not jugadores.filter({jugador=>jugador.vidas()<=0}).isEmpty()//Controla muertos, usa colecciones
	
	method win(jugadores)=jugadores.find({jugador=>jugador.vidas()>0}).toString().drop(7)+".png"//Asigna número jugador ganador

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
		
		jugador1.naveSeleccionada(false)
		jugador2.naveSeleccionada(false)
		
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

		method bmarco1() = new Marco(position = game.at(7,4), image = "assets/marco1.png", x1 = 7, x2 = 12)
		method bmarco2() = new Marco(position = game.at(9,4), image = "assets/marco2.png", x1 = 7, x2 = 12)
		
		method bjugadorOk() = false
		
		method bvida() = 100
		method benergia()= 100
	}
