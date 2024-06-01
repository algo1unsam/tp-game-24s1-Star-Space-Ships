import wollok.game.*

//Control límites de pantalla
class  Bounds{
	
	method right(objeto)=objeto.position().x()<20
	
	method left(objeto)=objeto.position().x()>0
	
	method down(objeto)=objeto.position().y()>0
	
	method up(objeto)=objeto.position().y()<9
		
	method control(objeto){
		return self.right(objeto)and self.left(objeto)and self.up(objeto) and self.down(objeto)
	}
}
//Límites player uno pantalla división media
object boundsP1 inherits Bounds{
	override method right(objeto){
		return objeto.position().x()<10	
	}
}
//Límites player dos pantalla división media
object boundsP2 inherits Bounds{
	override method left(objeto){
		return objeto.position().x()>10	
	}
}
