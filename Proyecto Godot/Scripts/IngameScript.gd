extends Control

class Square:
	var Name: String
	var Position: int #O como se quiera expresar
	var District: int
	var Price: int
	var Value: int
	var Investment_Left: int
	var free : bool = true
	var Owner: Player

#Clases extra
class Player:
	var Name: String
	var Cash: int
	var Position: Square #Para ver donde está, casilla, o int y tener codigo interno?
	var Score: int
	var properties = [] #Esto tendria que ser array solo de squares, pero asi vale
	var stocks = [0,0,0,0,0]

class GameManager:
	var Name: String
	var Level: int
	var Players: Player #Array


#Variables
# var a = 2
# var b = "text"
var diced
var dice = 0

#var propiertiesP1 = [] #Cada casilla es una propiedad
#var propiertiesP2 = [] #Cada casilla es una propiedad
#var propiertiesP3 = [] #Cada casilla es una propiedad
#var propiertiesP4 = [] #Cada casilla es una propiedad
#var playerProperties = [propiertiesP1, propiertiesP2, propiertiesP3, propiertiesP4] #todas las propiedades

#var stocksP1 = [0,0,0,0,0] #Cada casilla es un distrito, [Central,1,2,3,4]
#var stocksP2 = [0,0,0,0,0] #Cada casilla es un distrito, [Central,1,2,3,4]
#var stocksP3 = [0,0,0,0,0] #Cada casilla es un distrito, [Central,1,2,3,4]
#var stocksP4 = [0,0,0,0,0] #Cada casilla es un distrito, [Central,1,2,3,4]
#var playerStocks = [stocksP1, stocksP2, stocksP3, stocksP4] #Cada casilla es un distrito, [Central,1,2,3,4]

#Adyacencias
var ady_Banco = ["Central_1", "Central_2", "Central_3", "Central_4"]

var ady_Central_1 = ["Central_Conexion_1", "Central_Conexion_3", "Banco"]
var ady_Central_2 = ["Central_Conexion_1", "Central_Conexion_2", "Banco"]
var ady_Central_3 = ["Central_Conexion_2", "Central_Conexion_3", "Banco"]
var ady_Central_4 = ["Central_Conexion_3", "Central_Conexion_4", "Banco"]

var ady_Central_Conexion_1 = ["1_1", "1_2", "Central_1", "Central_2"]
var ady_Central_Conexion_2 = ["2_1", "2_2", "Central_2", "Central_3"]
var ady_Central_Conexion_3 = ["3_1", "3_2", "Central_3", "Central_4"]
var ady_Central_Conexion_4 = ["4_1", "4_2", "Central_4", "Central_1"]

var ady_1_1 = ["Central_Conexion_1", "1_4"]
var ady_1_2 = ["Central_Conexion_1", "1_3"]
var ady_1_3 = ["Peaje_1_2", "1_2", "1_6"]
var ady_1_4 = ["Peaje_1_4", "1_1", "1_5"]
var ady_1_5 = ["Palo_1", "1_4"]
var ady_1_6 = ["Palo_1", "1_3"]

var ady_2_1 = ["Central_Conexion_2", "2_4"]
var ady_2_2 = ["Central_Conexion_2", "2_3"]
var ady_2_3 = ["Peaje_2_2", "2_2", "2_6"]
var ady_2_4 = ["Peaje_2_4", "2_1", "2_5"]
var ady_2_5 = ["Palo_2", "2_4"]
var ady_2_6 = ["Palo_2", "2_3"]

var ady_3_1 = ["Central_Conexion_3", "3_4"]
var ady_3_2 = ["Central_Conexion_3", "3_3"]
var ady_3_3 = ["Peaje_3_2", "3_2", "3_6"]
var ady_3_4 = ["Peaje_3_4", "3_1", "3_5"]
var ady_3_5 = ["Palo_3", "3_4"]
var ady_3_6 = ["Palo_3", "3_3"]

var ady_4_1 = ["Central_Conexion_4", "4_4"]
var ady_4_2 = ["Central_Conexion_4", "4_3"]
var ady_4_3 = ["Peaje_4_2", "4_2", "4_6"]
var ady_4_4 = ["Peaje_4_4", "4_1", "4_5"]
var ady_4_5 = ["Palo_4", "4_4"]
var ady_4_6 = ["Palo_4", "4_3"]

var ady_Peaje_1_2 = ["1_3", "2_4"]
var ady_Peaje_2_3 = ["2_3", "3_4"]
var ady_Peaje_3_4 = ["3_3", "4_4"]
var ady_Peaje_4_1 = ["4_3", "1_4"]


# El init/create
func _ready():
	pass # Replace with function body.
#Enganchar botones con funciones

# El update
#func _process(delta):
#	pass

#Funciones adicionales

#Dado
func roll_dice():
	pass

func dice():
	if diced:
		return
		
	dice = randi() % 6
	$Dice.frame = dice
	$DiceButton.disabled = true
	diced = true
	#tempElapsed = 0
	#diceMovement = 0
	
	#PlaySound and stuff?

#Movimiento

#Comprobar movimientos restantes y listas de adyacencia
#Al llegar a 0 movimientos restantes, pedir confirmacion
#Si si, hacer un set, si no, reset a la posicion inicial
#Al hacer Set, comprobar casilla, si está ocupada (pagar) o no (comprar)

func move_Left():
	pass

func move_Right():
	pass

############
func look_board():
	pass

#Mover cursor, mostrando información de la casilla a la que apunte

###########
func manage_stocks():
	pass

#Stonk system

############
func manage_stores():
	pass

#getnode("NAME").visible

#Despliega otro panel de botones

############
func others():
	pass

#getnode("NAME").visible

#Despliega otro panel de botones

############
func auction():
	pass

#Hacer subasta, precio inicial, tiempo(?)

############
func sell_Shop():
	pass

#Que tienda, que precio, a quien se hace la oferta
#Buscar en el array de properties del jugador que toque, y borrar

############
func buy_Shop_Menu():
	pass

#Que tienda, que precio, a quien se hace la oferta
#Comprobar que tiene dineros
#Añadir al array de properties del jugador que toque

############
func change_Shop():
	pass

#Que tienda por que tienda, a quien se hace la oferta
#Comprobar que ambos jugadores tienen la tienda en cuestion
#Dinero por dinero, además de tienda?

############
func individual_Score(): #Necesario?
	pass

#Mostrar puntuacion individual
#Suma de todas las propiedades + Stonks

############
func global_Score(): #Necesario?
	pass

#Mostrar puntuacion global
#Suma de todas las propiedades + Stonks, para cada jugador

############
func win_Condition():
	pass

#Mostrar condicion de victoria -> Marcar condicion en lobby

############
func options():
	pass

func updateScoresVisual():
	var score1 = get_node("Label J1")
	var score2 = get_node("Label J2")
	var score3 = get_node("Label J3")
	var score4 = get_node("Label J4")
	
	#Comprobar condicion de victoria aqui?
	
	score1.set_text(Player.Cash + Player.Score) #Player1
	score2.set_text(Player.Cash + Player.Score) #Player2
	score3.set_text(Player.Cash + Player.Score) #Player3
	score4.set_text(Player.Cash + Player.Score) #Player4
	

func updateScoreInternal (player : Player):
	#Matesmaticas
	
	updateScoresVisual()
	pass

func buySquare_Board(player : Player, square : Square):
	if (square.free()):
		if (player.Cash > square.Value):
			player.properties.push_back(square)
			player.Cash - square.Value
			square.Owner = player
			square.free = false
			updateScoreInternal(player)

	else: #Expropiese
		if (player.Cash > square.Value * 5):
			square.Owner.properties.erase(square.Owner.properties.bsearch((square))) #Confio en que esto es así
			player.properties.push_back(square)
			player.Cash = player.Cash - square.Value * 5
			square.Owner.Cash = square.Owner.Cash + square.Value * 5
			square.Owner = player
			updateScoreInternal(player)
	
	#Algo mas?

#???

############
#func out_for_lunch():
#	pass

############
#func quick_save():
#	pass














func _on_Button_pressed():
	pass # Replace with function body.
