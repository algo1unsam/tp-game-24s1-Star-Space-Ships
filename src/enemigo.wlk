import wollok.game.*
import extras.*
import naves.*
import proyectiles.*
import niveles.*
import armas.*

class Enemigo inherits Jugador{
	
	method direccionInicial(){}
	method posicionInicial(){}
	method controles(){}
	
	
	method setearVidas(){
		vidas=30
	}
	
	method iniciarEnemigo(jugadorEnemigo){
		nave=new naveEnemigo(jugador=self,enemigo=jugadorEnemigo)		
		nave.jugador().setearVidas()
		nave.iniciar()
		
	}
}

class naveEnemigo inherits Nave(armamento=[armamentoEnemigo])
 {
	
	var enemigo
	override method nombre()="Enemigo_"
	override method image()= self.toString().drop(10)+ direccion.nombre() + ".png"
	override method esEnemigo()=true
    
    method randomY() = 0.randomUpTo(game.height())
    method x()=if(enemigo==jugador1){return jugador2.nave().position().x()}else{jugador1.nave().position().x()}
    method posicionar(){position=game.at(self.x(),0)}
    
   method pantallaJugador()=if(enemigo==jugador1){return jugador2.direccionInicial()}else{jugador1.direccionInicial()}
	
	method seleccionarDireccion(){direccion=self.pantallaJugador()}
	
	method nuevoEnemigo()=if(enemigo==jugador1){return jugador1}else{return jugador2}
	
	method iniciar(){
		
		self.seleccionarDireccion()
		self.posicionar()
		game.addVisual(self)	
		//colisiones.jugadores().add(jugador)
		colisiones.validarEnemigo(jugador)	
		self.perseguir()
	}
	
	method perseguir(){
		game.onTick(500,self.identity().toString(),({
			if(self.alineadoX(enemigo.nave())){
				armaActual.dispararProyectil1(self)
			}// si se alinea con el jugador, dispara 
			else{
				
				self.haciaJugador().mover(self)
			}
		}))}
	
	//Muerte del enemigo, remueve perseguir y validar vida de enemigo. Se regenera del otro lado a los 10 seg.
	method muerte(){
		game.removeTickEvent(self.identity().toString())
		game.removeTickEvent(self.identity().toString()+"Validar")
		self.regenerar()
	}
	method regenerar(){game.schedule(10000,{new Enemigo().iniciarEnemigo(self.nuevoEnemigo())})}
		
	method haciaJugador(){ //busca la manera mas rapida de ponerse en linea con el jugador
		if((position.x() - enemigo.nave().position().x()).abs() >= (position.y() - enemigo.nave().position().y()).abs())
			{return self.direccionY()}	
		else{return self.direccionX()}
		}
	
	method direccionX(){									//Devuelve el sentido de la direccion en x
		if(position.x() > enemigo.nave().position().x()){
			return izquierda}
		else{return derecha}
	}
		
	
	method direccionY(){									//Idem anterior en y
		if(position.y() > enemigo.nave().position().y()){
			return abajo}
		else{return arriba}
	}
	
	
	method alineadoX(personaje){
		return self.position().y() == personaje.position().y() 		
	}
}

