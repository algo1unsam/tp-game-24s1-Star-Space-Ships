import wollok.game.*
import proyectiles.*
import pantallas.*
import niveles.*
import extras.*
import armas.*


class Jugador
{	
	var property nave=null
	var property naveSeleccionada=false
	var property vidas = 100
	var property energia = 100
	
	method direccionInicial()
	method posicionInicial()
	method controles()
	
	//Setea posición y direccion inicial para la nave seleccionada en función del jugador
	method colocarNave() {
		nave.position(self.posicionInicial())
		nave.direccion(self.direccionInicial())
	}
	
	//Daño de proyectiles
	method recibeDanio(danio)= if(vidas-danio<=0){
								vidas=0
								final.remover(colisiones.jugadores())}
								else{
									vidas-= danio
								} 
		
	
	//Gasta la enerfía y controla que la energía no baje de 0
	method gastarEnergia(gasto)
	{
		energia -= gasto
		reguladorDeEnergia.validarEnergia(self)
	}
	method sinEnergia() = energia <= 0
	
	//Si se busca disparar el armamento de la nave sin eneergía lanza una excepción
	method validarEnergia(){
		game.errorReporter(self.nave())
		if (self.sinEnergia()) {throw new Exception(message="Sin Energia")}
	}
	
	method recargaEnergia(orbe) 
	{
		energia += orbe
		reguladorDeEnergia.validarEnergia(self)
	}
	
	//Controla límite rango de vida para la recarga
	method fullVida(orbe)=vidas+orbe>100
	
	//Controla q no se superponga con el enemigo aliado
	method puedeMoverse(dentroLimite,direccion)=dentroLimite and nave.noHayEnemigo(direccion)
	
	method recargaVida(orbe)=if(not self.fullVida(orbe)){vidas+=orbe}else{vidas=100}
}

object jugador1 inherits Jugador(nave = null){
	//Límites de pantalla de jugador uno y dos son distintos a izquierda y derecha por la pantalla media
	//Disparo uno corresponde siempre al disparo base el 2 al especial y las armas de recarga
	const property boundsPlayer=boundsP1
	const property enemigo=jugador2
	override method posicionInicial() = game.at(0,0)
	override method direccionInicial() = derecha
	override method controles()
	{	//Controla la posición siguiente y límites de pantalla antes de moverse
		keyboard.a().onPressDo({if(self.puedeMoverse(boundsPlayer.left(nave),izquierda))nave.moverIzquierda()})
		keyboard.d().onPressDo({if(self.puedeMoverse(boundsPlayer.right(nave),derecha))nave.moverDerecha()})
		keyboard.w().onPressDo({if(self.puedeMoverse(boundsPlayer.up(nave),arriba))nave.moverArriba()})
		keyboard.s().onPressDo({if(self.puedeMoverse(boundsPlayer.down(nave),abajo))nave.moverAbajo()})
		keyboard.z().onPressDo({nave.disparo1()})
		keyboard.x().onPressDo({nave.disparo2()})
	}
	
	
}

object jugador2 inherits Jugador(nave = null){
	
	const property boundsPlayer=boundsP2
	const property enemigo=jugador1
	override method posicionInicial() = game.at(game.width()-1,0)
	override method direccionInicial() = izquierda
	override method controles()
	{
		keyboard.left().onPressDo({if(self.puedeMoverse(boundsPlayer.left(nave),izquierda))nave.moverIzquierda()})
		keyboard.right().onPressDo({if(self.puedeMoverse(boundsPlayer.right(nave),derecha))nave.moverDerecha()})
		keyboard.up().onPressDo({if(self.puedeMoverse(boundsPlayer.up(nave),arriba))nave.moverArriba()})
		keyboard.down().onPressDo({if(self.puedeMoverse(boundsPlayer.down(nave),abajo))nave.moverAbajo()})
		keyboard.j().onPressDo({nave.disparo1()})
		keyboard.k().onPressDo({nave.disparo2()})
	}
	
	}



class Nave
{
	var property direccion = derecha //La orientacion a donde la nave está apuntando. Puede ser izquierda (izq) o derecha (der)
	var property position = game.origin()
	var property armamento=[]
	//El arma actual corresponde siempre al última cuyo orbe se recoge a menos que ya se encuentre en la colección. En ese caso se recarga
	var property armaActual=null
	var property jugador
	var armamentoNave=null
	method esEnemigo()=false
	
	
	method nombre()
	
	method image()= "assets/"+self.nombre() + direccion.nombre() + ".png"
	
	//Movimientos nave
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
		self.gastarEnergia(10)
		
	}
	method disparo1()
	{
		self.disparo()
		armaActual.dispararProyectil1(self)
	}
	method disparo2()
	{
		armaActual.dispararProyectil2(self)
	}
	
	//Elige el equipamiento inicial de la nave
	method iniciarArmamento(){
		armamento.add(armamentoNave)
		armaActual=armamento.last()
	}
	
	//Controla no superponerse con el enemigo aliado
	method noHayEnemigo(direction)=not game.getObjectsIn(direction.nuevaPosicion(self)).any({objeto=>objeto.esEnemigo()})
}


class Nave1 inherits Nave
{	
	override method iniciarArmamento(){
		armamentoNave=especialNave1
		super()
	}
	override method nombre() = "nave1_"
}

class Nave2 inherits Nave
{	
	override method iniciarArmamento(){
		armamentoNave=especialNave2
		super()
	}
	
	override method nombre() = "nave2_"
}
class Nave3 inherits Nave
{	
	override method iniciarArmamento(){
		armamentoNave=especialNave3
		super()
	}
	override method nombre() = "nave3_"
}
