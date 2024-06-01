import wollok.game.*
import extras.*
import naves.*
import proyectiles.*
import niveles.*
import armas.*

class Enemigo inherits Jugador{
	
	var property enemigo=null
	method direccionInicial(){}
	method posicionInicial(){}
	method controles(){}
	
	
	method recibeDanio(danio)= if(vidas-danio>0){vidas-= danio}else{nave.muerte()} 
	
	method setearVidas(){
		vidas=30
	}
	
	method iniciarEnemigo(jugadorEnemigo){
		enemigo=jugadorEnemigo
		nave=new naveEnemigo(jugador=self)		
		nave.jugador().setearVidas()
		nave.iniciar()
		
	}
}

class naveEnemigo inherits Nave(armamento=[armamentoEnemigo])
 {
		
	override method nombre()="Enemigo_"
	override method image()= "assets/"+self.toString().drop(10)+ direccion.nombre() + ".png"
	override method esEnemigo()=true
    
   // method randomY() = 0.randomUpTo(game.height())
   
   
   method jugador1aliado()=self.aliado()==jugador1
   
    method x()=self.aliado().nave().position().x()
   
    method posicionar(){position=game.at(self.x(),0)}
    
    method aliado()=jugador.enemigo().enemigo()
    
    method pantallaJugador()=self.aliado().direccionInicial()
	
	method seleccionarDireccion(){direccion=self.pantallaJugador()}
	
	method nuevoEnemigo()=self.aliado().enemigo()//if(self.jugador1Enemigo()){return jugador1}else{return jugador2}
	
	//Controla movimiento en límite de pantalla media
	method limitePantallaAliado()=if(self.jugador1aliado()){jugador1.boundsPlayer().right(self)}else{jugador2.boundsPlayer().left(self)}
	
	method alineadoX()=self.position().y() == jugador.enemigo().nave().position().y() 		
	
	method noHayJugador(direction)=not game.getObjectsIn(direction.nuevaPosicion(self)).contains(self.aliado())
	
	method moverse(direccion)=direccion.mover(self)
	
	method controlarEjeX(direccion)=self.noHayJugador(direccion) and self.limitePantallaAliado()
	
	//En caso de estar en el límite de pantalla media controla que no este el aliado en la posición Y para moverse, o espera el proximo tick
	method moveOrWait()=if(self.noHayJugador(self.direccionY())){self.moverse(self.direccionY())}else{}
	
	method regenerar(){game.schedule(10000,{new Enemigo().iniciarEnemigo(self.nuevoEnemigo())})}
	
	method menorDistanciaEjeY()=(position.x() - jugador.enemigo().nave().position().x()).abs() >= (position.y() - jugador.enemigo().nave().position().y()).abs()
	
	method buscarAlineoHorizontal()=self.menorDistanciaEjeY() and self.noHayJugador(self.direccionY())
	
	method buscarAcercarseEnX()=if(self.controlarEjeX(self.direccionX())){self.moverse(self.direccionX())}else{self.moveOrWait()}
		
	method haciaJugador()=if(self.buscarAlineoHorizontal()){self.moverse(self.direccionY())}else{self.buscarAcercarseEnX()}
	
	method aIzquierda()=position.x() > jugador.enemigo().nave().position().x()
	
	method haciaAbajo()=position.y() > jugador.enemigo().nave().position().y()
	
	method direccionX()=if(self.aIzquierda()){izquierda}else{return derecha}
		
	method direccionY()=if(self.haciaAbajo()){abajo}else{arriba}
	
	
	
	method iniciar(){
		
		self.seleccionarDireccion()
		self.posicionar()
		game.addVisual(self)	
		colisiones.validarEnemigo(jugador)	
		self.perseguir()
	}
	
	method perseguir(){
		
		game.onTick(500,self.identity().toString(),{
			if(self.alineadoX()){
				armaActual.dispararProyectil1(self)
			}// si se alinea con el jugador, dispara 
			else{
				self.haciaJugador()	
			}
		})
	}
		
	//Muerte del enemigo, remueve perseguir y validar vida de enemigo. Se regenera del otro lado a los 10 seg.
	method muerte(){
		game.removeTickEvent(self.identity().toString())
		game.removeVisual(self)
		//game.removeTickEvent(self.identity().toString()+"Validar")
		self.regenerar()
	}
}

