import wollok.game.*
import extras.*
import naves.*
import enemigo.*
import proyectiles.*

class Armamento
{	
	var cooldown=1
	method image(_chara) = 	_chara.nombre() + "spell_" + _chara.direccion().nombre() + ".png"
	method danioArma()=10
	method dispararProyectil(_chara,proyectil)
	{
		proyectil.colocarProyectil(_chara)
		proyectil.automaticSelfDestruction()
	}
	
	method dispararProyectil1(_chara)
	{
		self.dispararProyectil(_chara,new Disparo(position = _chara.position(),imagen=self.image(_chara)))
	}
	
	//Controla limpieza y apuntador de coleccion armamento durante la ejecución
	method notCooldown(nave)=if(cooldown==0){}else{nave.armamento().remove(nave.armamento().last())
												   nave.armaActual(nave.armamento().last())}
}

class Rafaga inherits Armamento{
	var property carga = 12
	
	
	
	method balaInit(nave)=if(nave.direccion()==derecha){return new Disparo(position=nave.position().right(1),imagen=self.image(nave))}
	else{return new Disparo(position=nave.position().left(1),imagen=self.image(nave))}
	
	
	 method dispararProyectil2(nave){
		
			cooldown = 1
			if((not self.vacio()) and cooldown == 1)
			{
			cooldown=0
			self.dispararProyectil(nave,self.balaInit(nave))
			game.schedule(100,{
				self.dispararProyectil(nave,self.balaInit(nave))
				game.schedule(100,{
					self.dispararProyectil(nave,self.balaInit(nave))
					game.schedule(100,{ 
						self.dispararProyectil(nave,self.balaInit(nave))
						self._cooldown()
					})
				})
			})
			}
			else{
				self.notCooldown(nave)
			}
	}
	
	override method dispararProyectil( nave,proyectil){
		carga = carga - 1
		super(nave,proyectil)
			
	}
	
	method vacio()=carga<=0
					
	method _cooldown(){
		game.schedule(600,{=> cooldown = 1})
	}

}


class Misil inherits Armamento{
	
	var property carga = 3
	
	override method danioArma()=50
	override method image(_chara)="Misil"+_chara.direccion()+".png"
	
	method init(nave)=if(nave.direccion()==derecha){return new Explosivo(position=nave.position().right(1),imagen =self.image(nave))}
	else{return new Explosivo(position=nave.position().left(1),imagen =self.image(nave))}
	
	method dispararProyectil2(nave){
		if((not self.vacio()) and cooldown == 1){
			cooldown = 0
			self.dispararProyectil(nave,self.init(nave))
			carga = carga - 1
			self._cooldown()
		}
		else{
			self.notCooldown(nave)			
		}
	
	}
	
	
	override method dispararProyectil1(nave){
		new Armamento().dispararProyectil1(nave)
	}
	
	method vacio(){return carga == 0}
	
	method _cooldown(){
		game.schedule(2500,{=> cooldown = 1})
	}
	
}

class Explosivo inherits Disparo{
	
	
	override method danio()=50
	
	override method interaccionCon(jugador)
	{	
		game.removeTickEvent(self.etiquetaTickMovement())	
		self.explotar(jugador.nave().position().x(),jugador.nave().position().y())
		game.schedule(600,({self.haceDanio(jugador) game.removeVisual(self)}))	
			
	}
	
	
	override method automaticSelfDestruction(){
		game.schedule(2500,{if(game.allVisuals().contains(self)){self.detenerMovimiento()}})
	}
	
	override method colocarProyectil(_chara)
	{
		self.evaluarComportamiento(_chara)
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("misil.mp3")})
	}
	
	
	method explotar(positionX, positionY){
		(positionX-2..positionX+2).forEach({n => new Explosion().explotar(n,positionY)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY+1)})
		(positionX-1..positionX+1).forEach({n => new Explosion().explotar(n,positionY-1)})
		new Explosion().explotar(positionX, positionY+2)
		new Explosion().explotar(positionX, positionY-2)
	}	
}

class Explosion {
	method image(){return "explosion.png"}
	
	method interaccionCon(jugador){}
	method position()=game.origin()
	
	method explotar(positionX, positionY){
		game.addVisualIn(self, game.at(positionX,positionY))
		game.schedule(500,({game.removeVisual(self)}))
	}
}




object especialNave1 inherits Armamento
{
	method dispararProyectil2(_chara)
	{
		3.times({iter=>_chara.disparo()})
		const proyectil = new DisparoEspecial(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
		self.dispararProyectil1(_chara)
		
	}
}

object especialNave2 inherits Armamento
{
	method dispararProyectil2(_chara)
	{	
		3.times({iter=>_chara.disparo()})
		const proyectil1 = new Disparo(position = _chara.position().up(3), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(3),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
		game.schedule(200,{self.dispararProyectil1(_chara)})
	}
}
object especialNave3 inherits Armamento
{
	method dispararProyectil2(_chara)
	{	
		3.times({iter=>_chara.disparo()})
		self.dispararProyectil1(_chara)
		const proyectil1 = new Disparo(position = _chara.position().up(1), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(1),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
	}
}

object armamentoEnemigo inherits Armamento{
	
	
}

class ArmaTeledirigida inherits Armamento{
	
	var property carga = 1
	
	method init(nave)=if(nave.direccion()==derecha){return new ProyectilTeledirigido(position=nave.position().right(1),imagen =self.image(nave))}
	else{return new ProyectilTeledirigido(position=nave.position().left(1),imagen =self.image(nave))}
	
    method dispararProyectil2(nave){
		if(not self.vacio() and cooldown == 1){
			cooldown = 0
			self.dispararProyectil(nave,self.init(nave))//new ProyectilTeledirigido().disparo(direc, personaje)
			carga = carga - 1
			self._cooldown()
		}
		else{
			self.notCooldown(nave)			
		}
	}
	
	method vacio(){return carga == 0}
	
	method _cooldown(){
		game.schedule(500,{=> cooldown = 1})
	}
	
	
	
}

class ProyectilTeledirigido inherits Disparo {
    
   
    override method image(){return "teledirigido.png"}
   
   
   method colocarProyectil(_chara)
	{
		
		game.schedule(100,
			{=>	game.addVisual(self)
				self.sonido("blaster.mp3")
			})
			self.seguir(self.seleccionarEnemigo(_chara).nave())
			//self.evaluarComportamiento(_chara)	
		
	}
    
	method seguir(enemigo){		
		
		game.onTick(50,self.identity().toString(),{self.teledirigido(enemigo)})
	
	}
	
	override method automaticSelfDestruction(){
		game.schedule(1500,{if(game.allVisuals().contains(self)){self.detenerMovimiento()}})
	}
	
	override method interaccionCon(jugador)	
		{
			self.haceDanio(jugador)
			game.removeTickEvent(self.identity().toString())
			game.removeVisual(self)	
		}
	
	override method detenerMovimiento(){
		game.removeTickEvent(self.identity().toString())
		game.removeVisual(self)
	}
	/* 	
	method seleccionarEnemigo(personaje){
		return game.allVisuals().filter({elemento=>elemento.esEnemigo()}).sortedBy(
			   {enemigoA,enemigoB=>personaje.position().distance(enemigoA.position())<personaje.position().distance(enemigoB.position())}).get(0)
			
	}
	*/
	method danio(jugador)=self.seleccionarEnemigo(jugador.nave()).nave().armamento().sum({arma=>arma.danioArma()})
	//Recorre la lista de armamento del enemigo del enemigo es decir del jugador y suma los daños
	override method haceDanio(jugador){
		
		jugador.recibeDanio(self.danio(jugador))
	}
	
	method seleccionarEnemigo(jugador)=if(jugador.jugador()==jugador1){return jugador2}else{return jugador1}
	
	method teledirigido(personaje){
		
		if(self.distanciaEnEjeY(personaje) or self.distanciaEnEjeX(personaje)){
			
			if(self.distanciaEnEjeY(personaje)){
				return self.direccionX(personaje).mover(self)
			} 	
			else{
				return self.direccionY(personaje).mover(self)}
			}
	   else {
		   if((self.position().x() - personaje.position().x()).abs() >= (self.position().y() - personaje.position().y()).abs()){
				return self.direccionY(personaje).mover(self)
			}
		   else{
		   		return self.direccionX(personaje).mover(self)
		   }
		}
	}
	
   method distanciaEnEjeX(personaje){
   		return self.position().x() - personaje.position().x().abs()==0
   }
   
   method distanciaEnEjeY(personaje){
   	return self.position().y() - personaje.position().y().abs()==0
   }
   
   method direccionX(personaje){
		if(self.position().x() > personaje.position().x()){
			return izquierda}
		else{return derecha}
		}
		
	
	method direccionY(personaje){
		if(self.position().y() > personaje.position().y()){
			return abajo}
		else{return arriba}
	}
}

