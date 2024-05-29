import wollok.game.*
import extras.*
import naves.*
import enemigo.*
import proyectiles.*

class Armamento
{	
	var cooldown=1
	method image(_chara) = _chara.nombre() + "spell_" + _chara.direccion().nombre() + ".png"
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
				self.sonido("assets/misil.mp3")})
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
	method image(){return "assets/explosion.png"}
	
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
	
	method init(nave)=if(nave.direccion()==derecha){return new Disparo(position=nave.position().right(1),imagen =self.image(nave))}
	else{return new Disparo(position=nave.position().left(1),imagen =self.image(nave))}
	
	override method dispararProyectil1(_chara)
	{
		self.dispararProyectil(_chara,self.init(_chara))
	}
	
}

class ArmaTeledirigida inherits Armamento{
	
	var property carga = 1
	
	
	
	method init(nave)=if(nave.direccion()==derecha){return new ProyectilTeledirigido(position=nave.position().right(1),imagen ="Dirigidoderecha.png")}
	else{return new ProyectilTeledirigido(position=nave.position().left(1),imagen ="Dirigidoizquierda.png")}
	
    method dispararProyectil2(nave){
    		if(carga==1){
			self.dispararProyectil(nave,self.init(nave))//new ProyectilTeledirigido().disparo(direc, personaje)
			carga = carga - 1
			nave.armamento().remove(nave.armamento().last())
			nave.armaActual(nave.armamento().last())}
			else{
				self.notCooldown(nave)
			}		
	}
	
	method vacio(){return carga == 0}
	
	method _cooldown(){
		game.schedule(500,{=> cooldown = 1})
	}
	
	
	
}

