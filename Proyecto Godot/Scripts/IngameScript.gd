extends Spatial

var online = false
var gameStarted = false
var rolled = false
var dice = 0
var players = [] #Array
var turn = 0
var basePath = "/root/Spatial/"
var UIPath = "/root/Spatial/TempUI/"
var playerAmount = 4
var investment = 100
var paused = false

# El init/create
func _ready():
	pass

func gameStart():
	gameStarted = true
	for i in range(1, playerAmount+1):
		players.append("Player" + str(i))
		get_tree().get_root().get_node(basePath + "Player" + str(i)).visible = true

func _process(delta):
	if gameStarted:
		turn()

func getPaused():
	return paused

func setPaused(value):
	paused = value

func getPlayerAmount():
	return playerAmount

func getTurn():
	return turn

func setTurn(value):
	turn = value

func setRolled(value):
	rolled = value

func turn():
	if not paused:
		if not rolled and get_node(UIPath + "rollButton").visible == false:
			get_node(UIPath + "rollButton").visible = true
			get_node(basePath + "Dice").rolling = true
			
	pass

func endTurn():
	gameManager.setRolled(false)
	get_node(UIPath + "rollButton").visible == true
	get_node(basePath + "Dice").visible = true
	
	if (gameManager.getTurn() < gameManager.getPlayerAmount() - 1):
		gameManager.setTurn(gameManager.getTurn() + 1)
	else:
		gameManager.setTurn(0)

func moveEnded():
	var player = get_node(basePath + players[turn]) #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
	if (node.isToll()):
		endTurn()
	
	elif (node.isBank()):
		endTurn()
	
	elif (node.isSuit()):
		endTurn()
	
	elif (node.free and node.isBuild()): #Comprar casilla
		get_node(UIPath + "FreeBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "FreeBuildingButtons/Label").text = "Esta casilla está libre, ¿quieres comprarla?"
		
		if (player.Cash < node.Price):
			get_node(UIPath + "FreeBuildingButtons/HBoxContainer/Comprar").set_disabled(true)
		

	elif (node.Owner == player.Name): #Casilla propia
		get_node(UIPath + "OwnBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "OwnBuildingButtons/Label").text = "Esta casilla es tuya, ¿quieres invertir en ella?"
		
		
	else:	#Casilla ajena
		get_node(UIPath + "TakenBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "TakenBuildingButtons/Label").text = "Esta casilla es de otro jugador, te toca pagar"
		
		if (player.Cash < node.Value):
					get_node(UIPath + "TakenBuildingButtons/HBoxContainer/Pagar").set_disabled(true)

#Dado
func roll_dice():
	if rolled:
		return
	
	get_node(basePath + "Dice").rolling = false
	dice = randi() % 6 + 1
	get_node(basePath + "Dice").frame = dice - 1
	#$DiceButton.disabled = true
	rolled = true
	get_node(basePath + players[turn]).newRoll(dice)
	#tempElapsed = 0
	#diceMovement = 0
	
	#PlaySound and stuff?

#Movimiento

#Comprobar movimientos restantes y listas de adyacencia
#Al llegar a 0 movimientos restantes, pedir confirmacion
#Si si, hacer un set, si no, reset a la posicion inicial
#Al hacer Set, comprobar casilla, si está ocupada (pagar) o no (comprar)

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
	
	#score1.set_text(Player.Cash + Player.Score) #Player1
	#score2.set_text(Player.Cash + Player.Score) #Player2
	#score3.set_text(Player.Cash + Player.Score) #Player3
	#score4.set_text(Player.Cash + Player.Score) #Player4
	

func updateScoreInternal ():
	#Matesmaticas
	
	updateScoresVisual()
	pass

func canEndMovement():
	get_node(UIPath + "moveButtons").visible = true
	
#???

############
#func out_for_lunch():
#	pass

############
#func quick_save():
#	pass
