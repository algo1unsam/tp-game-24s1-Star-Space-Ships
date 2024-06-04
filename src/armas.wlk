import wollok.game.*
import extras.*
import naves.*
import enemigo.*
import proyectiles.*

//De la clase Armamento heredan los armamentos básicos de la nave y las armas de recarga que se consiguen y recargan con orbes
class Armamento
{	
	var property carga=0
	var property cooldown=1
	method _cooldown()={}//enfriamiento de armas de recarga
	method image(_chara) = _chara.nombre() + "spell_" + _chara.direccion().nombre() + ".png"//calcula la imagen del proyectil base de la nave
	method danioArma()=10
	
	method vacio()=carga<=0 //controla si el arma de recarga esta vacía
	
	method puedeDisparar()=not (self.vacio() and cooldown == 1) //Controla q no este vacía o enfriando para poder disparar
	
	method direccionDerecha(nave)=nave.direccion()==derecha //Controla direccion de la nave para direccionar posición inicial de proyectil
	
	//Los disparos salen en la posicion siguiente a la nave en su dirección
	method disparoADerecha(nave,proyectil){
		proyectil.position(nave.position().right(1))
		proyectil.imagen(self.image(nave))
		return proyectil
	}
	
	method disparoAIzquierda(nave,proyectil){
		proyectil.position(nave.position().left(1))
		proyectil.imagen(self.image(nave))
		return proyectil
	}
	
	//Devuelve proyectil posicionado en la posicion inicial
	method proyectilInit(nave,proyectil)=if(self.direccionDerecha(nave)){self.disparoADerecha(nave,proyectil)}else{self.disparoAIzquierda(nave,proyectil)}
	
	//Disparo de proyectil y control de tiempo en pantalla
	method dispararProyectil(_chara,proyectil)
	{
		proyectil.colocarProyectil(_chara)
		proyectil.automaticSelfDestruction()//Tiempo en pantalla antes del remove
	}
	
	//Disparo base
	method dispararProyectil1(_chara)
	{	
		//Toma el personaje para el calculo del image del proyectil y dispara el proyectil posicionado
		self.dispararProyectil(_chara,self.proyectilInit(_chara,new Disparo()))
	}
	
	//Gasto energía de jugador con disparo especial de la nave
	method gastoEnergiaEspecial(_chara){3.times({iter=>_chara.disparo()})}
	
	//Disparo especial de la nave y las armas de recarga
	method dispararProyectil2(nave)
	
	//Controla que el arma no está enfriando si se descarga y hay que removerla
	method notCooldown(nave)=cooldown==1
	
	//espera fin de enfriamiento si se vuelve a disparar y está cargada, o en caso de estar vacía la quita de la lista
	method waitOrRemove(nave)=if(self.vacio()){self.removerArma(nave)}else{}
	
	
	//quita arma de la lista y asigna la anterior en la colección de armamento de la nave
	method removerArma(nave){
		game.say(nave,nave.armaActual().toString().drop(6)+ " descargada")
		nave.armamento().remove(nave.armaActual())
		nave.armaActual(nave.armamento().last())
	}
}

//Armamento básico especial de las naves. Heredan el disparo Base
object especialNave1 inherits Armamento
{	
	//Disparar proyectil 2 se ejecuta desde los controles de teclado para el armamento básico especial y las armas de recarga
	override method dispararProyectil2(_chara)//Disparo especial nave1: dos proyectiles en diagonal y uno al centro
	{
		self.gastoEnergiaEspecial(_chara)
		const proyectil = new DisparoEspecial(position = _chara.position(),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil)
		self.dispararProyectil1(_chara)
		
	}
}



object especialNave2 inherits Armamento
{
	override method dispararProyectil2(_chara) //uno tres posiciones arriba, otro tres abajo y uno al centro más tarde
	{	
		self.gastoEnergiaEspecial(_chara)//gasto de energía de disparo especial en el armamento básico de la nave
		const proyectil1 = new Disparo(position = _chara.position().up(3), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(3),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
		game.schedule(200,{self.dispararProyectil1(_chara)})
	}
}

object especialNave3 inherits Armamento
{
	override method dispararProyectil2(_chara) //3 proyectiles en vertical
	{	
		self.gastoEnergiaEspecial(_chara)
		self.dispararProyectil1(_chara)
		const proyectil1 = new Disparo(position = _chara.position().up(1), imagen=self.image(_chara))
		const proyectil2 = new Disparo(position = _chara.position().down(1),imagen=self.image(_chara))
		self.dispararProyectil(_chara,proyectil1)
		self.dispararProyectil(_chara,proyectil2)
	}
}


//Armas de recarga. No gastan energía gastan su carga.
class Rafaga inherits Armamento{
		
	const time=100
	
	//Disparo de ráfaga tres proyectiles secuenciados básicos
	 override method dispararProyectil2(nave)=
		
			if(self.puedeDisparar())
			{
			cooldown=0
			self.dispararProyectil(nave,self.proyectilInit(nave,new Disparo()))
			game.schedule(time,{self.dispararProyectil(nave,self.proyectilInit(nave,new Disparo()))})
			game.schedule(2*time,{self.dispararProyectil(nave,self.proyectilInit(nave, new Disparo())) self._cooldown()})			
			
			}
			else{self.waitOrRemove(nave)}
	
	override method dispararProyectil( nave,proyectil){
		//La rafága dispara el proyectil básico de la nave pero gasta su carga por cada disparo
		carga -= 1
		super(nave,proyectil)		
	}
	
	//Enfriamiento				
	override method _cooldown()=game.schedule(1000,{=> cooldown = 1})
	

}


class Misil inherits Armamento{
	
	
	//Las armas de recarga tiene asociado un daño numerico acorde al dano de impacto de su proyectil
	override method danioArma()=30
	override method image(_chara)="Misil"+_chara.direccion()+".png"
	
	override method dispararProyectil2(nave){
		if(self.puedeDisparar()){
			cooldown = 0
			self.dispararProyectil(nave,self.proyectilInit(nave, new Explosivo()))//Dispara proyectil explosivo
			carga -= 1
			self._cooldown()
		}
		else{self.waitOrRemove(nave)}
	}
	//Mantiene disparo base de la nave		
	override method dispararProyectil1(nave){
		nave.armamento().get(0).dispararProyectil1(nave)
	}
	
	override method _cooldown()=game.schedule(2500,{=> cooldown = 1})		
}

//Hereda Misil y lanza u misil teledirigido
class ArmaTeledirigida inherits Misil{
	
	override method image(_chara)="Dirigido"+_chara.direccion()+".png"
	
	override method danioArma()=10//Tiene un daño bajo porque el proyectil teledirigido suma el daño de todsa las armas en la colección al impactar
	
	override method dispararProyectil2(nave){
		if(self.puedeDisparar()){
			cooldown = 0
			self.dispararProyectil(nave,self.proyectilInit(nave, new ProyectilTeledirigido()))//Dispara proyectil explosivo
			carga -= 1
			self._cooldown()
		}
		else{self.waitOrRemove(nave)}
	}	
	
	override method _cooldown()=game.schedule(500,{=> cooldown = 1})
}

//Arma del bot enemigo. Solo tiene el disparo base
object armamentoEnemigo inherits Armamento{
	
	override method dispararProyectil1(_chara)
	{
		self.dispararProyectil(_chara,self.proyectilInit(_chara, new Disparo()))
	}
	
	override method dispararProyectil2(nave){}
	
}


