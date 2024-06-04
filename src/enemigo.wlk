import wollok.game.*
import extras.*
import naves.*
import proyectiles.*
import niveles.*
import armas.*
//
class Enemigo inherits Jugador{
	
	var property enemigo=null
	method direccionInicial(){}
	method posicionInicial(){}
	method controles(){}
	
	method muerto(danio)=vidas-danio<=0
	
	//A diferencia del jugador cuando muere ejectua método para quitar el evento de movimiento asociado y quitarse de pantalla
	override method recibeDanio(danio)= if(not self.muerto(danio)){vidas-= danio}else{nave.muerte()} 
	
	//Solo tiene 30 de vida
	method setearVidas(){
		vidas=30
	}
	
	//Se inicia seleccionando un enemigo, se asigna una nave enemiga y setea las vidas. Inicia la nave enemiga
	method iniciarEnemigo(jugadorEnemigo){
		enemigo=jugadorEnemigo
		nave=new naveEnemigo(jugador=self)		
		nave.jugador().setearVidas()
		nave.iniciar()
		
	}
}

class naveEnemigo inherits Nave(armamento=[armamentoEnemigo])
 {	
 	//Controla que es un jugador
	method tieneVida()=true
	
	override method nombre()="Enemigo_"
	
	//Para calcular la imagen quita "un/a  nave" del string
	override method image()= "assets/"+self.toString().drop(10)+ direccion.nombre() + ".png"
	
	//method esEnemigo controla interacción con orbes para que no los cargue
	override method esEnemigo()=true
   
   //Controla si jugador1 es aliado
	method jugador1aliado()=self.aliado()==jugador1
   
   //Controla posición en x de la nave del jugador aliado para aparecer en pantalla
    method x()=self.aliado().nave().position().x()
   
   //Se incializa en posición x del aliado e y=0
    method posicionar(){position=game.at(self.x(),0)}
    
    //Setea aliado
    method aliado()=jugador.enemigo().enemigo()
    
    //Controla pantalla de jugador aliado para setear su dirección
    method pantallaJugador()=self.aliado().direccionInicial()
	
	//setea direccion
	method seleccionarDireccion(){direccion=self.pantallaJugador()}
	
	//Cuando muere controla el enemigo actual para regenerarse
	method nuevoEnemigo()=self.aliado().enemigo()
	
	//Controla movimiento en límite de pantalla media del aliado
	method controlarEjeX()=if(self.jugador1aliado()){jugador1.boundsPlayer().right(self)}else{jugador2.boundsPlayer().left(self)}
	
	//Controla si el enemigo esta alineado en x para dispararle 
	method alineadoX()=self.position().y() == jugador.enemigo().nave().position().y() 		
	
	//Toma un objeto dirección y se mueve una posición en esa dirección
	method moverse(direccion)=direccion.mover(self)
	
	//Se regenera a los 10 segundos seleccioanando nuevamente al enemigo que lo destruye
	method regenerar(){game.schedule(10000,{new Enemigo().iniciarEnemigo(self.nuevoEnemigo())})}
	
	//Controla si es menor la distancia absoluta en eje Y
	method menorDistanciaEjeY()=(position.x() - jugador.enemigo().nave().position().x()).abs() >= (position.y() - jugador.enemigo().nave().position().y()).abs()
	
	//Busca acercarse en eje X
	method buscarAcercarseEnX()=if(self.controlarEjeX()){self.moverse(self.direccionX())}else{self.moverse(self.direccionY())}
	
	//Busca alinearse priemro en Y para evitar que siempre se dirija a la pantalla media. Aprovecha las dimensiones de pantalla del juego
	//que en general dan menor distancia en Y	
	method haciaJugador()=if(self.menorDistanciaEjeY()){self.moverse(self.direccionY())}else{self.buscarAcercarseEnX()}
	
	//Controla si ek enemigo está a izquierda
	method aIzquierda()=position.x() > jugador.enemigo().nave().position().x()
	
	//Controla si la nave del enemigo está abajo
	method haciaAbajo()=position.y() > jugador.enemigo().nave().position().y()
	
	//Devuelven objetos de dirección
	method direccionX()=if(self.aIzquierda()){izquierda}else{derecha}
		
	method direccionY()=if(self.haciaAbajo()){abajo}else{arriba}
	
	
	//Inicia nave enemiga
	method iniciar(){
		
		self.seleccionarDireccion()
		self.posicionar()
		self.iniciarArmamento()
		game.addVisual(self)	
		colisiones.validarEnemigo(jugador)	
		self.perseguir()
	}
	
	//Si esta alineado dispara caso contrari se mueve hacia nave enemiga
	method perseguir(){
		
		game.onTick(1000,self.identity().toString(),{
			if(self.alineadoX()){
				armaActual.dispararProyectil1(self)
			}// si se alinea con el jugador, dispara 
			else{
				self.haciaJugador()	
			}
		})
	}
	
	override method iniciarArmamento(){
		armamentoNave=armamentoEnemigo
		super()
	}
	
	method enPantalla()=game.allVisuals().contains(self)	
	//Quita evento propio de persecución y el visual. Se regenera. Cotrola q esté en pantalla cuando recibe doble daño
	method muerte(){
		if(self.enPantalla()){
		game.removeTickEvent(self.identity().toString())
		game.removeVisual(self)
		self.regenerar()}
		else{}
	}
}

