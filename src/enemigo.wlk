import wollok.game.*
import extras.*
import naves.*
import proyectiles.*


class Enemigo inherits Nave(armamento=[armamentoEnemigo]){
	
	var enemigo
	override method nombre()="Enemigo_"
	override method image()= self.toString().drop(6)+ direccion.nombre() + ".png"
    
    method randomY() = 0.randomUpTo(game.height())
    method x()=if(enemigo==jugador1){return 20}else{return 0}
    //method esEnemigo()=true
    method posicionar(){position=game.at(jugador.nave().position().x(),0)}
    
	
	method seleccionarEnemigo()= if(jugador==jugador1){enemigo= jugador2} else {enemigo= jugador1}
	
	method seleccionarDireccion(){direccion=jugador.direccionInicial()}
	
	method iniciar(){
		self.seleccionarEnemigo()
		self.seleccionarDireccion()
		self.posicionar()
		game.addVisual(self)
		self.perseguir()
	}
	
	method perseguir(){
		game.onTick(1000,self.identity().toString(),({
			if(self.alineadoX(enemigo.nave())){
				
				armaActual.dispararProyectil1(self)
			}// si se alinea con el jugador, dispara 
			else{
				
				self.haciaJugador().mover(self)
			}
		}))}
	
		
	method haciaJugador(){ //busca la manera mas rapida de ponerse en linea con el jugador
		if((position.x() - enemigo.nave().position().x()).abs() >= (position.y() - enemigo.nave().position().y()).abs())
			{return self.direccionY()}	
		else{return self.direccionX()}
		}
	/* 	
	method disparaHaciaJugador(){ //busca la manera mas rapida de ponerse en linea con el jugador
		if((self.position().x() - jugador.position().x()).abs() == 0){
			return self.direccionY()
		}
		else{return self.direccionX()}		
	}
	*/
	
	method direccionX(){
		if(position.x() > enemigo.nave().position().x()){
			return izquierda}
		else{return derecha}
	}
		
	
	method direccionY(){
		if(position.y() > enemigo.nave().position().y()){
			return abajo}
		else{return arriba}
	}
	
	
	method alineadoX(personaje){
		return self.position().y() == personaje.position().y() 		
	}
}

