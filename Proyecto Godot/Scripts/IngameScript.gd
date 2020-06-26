extends Spatial

var online = false
var host = false
var gameStarted = false
var rolled = false
var dice = 0
var players = [] #Array
var nicks = []
var me
var turn = 0
var basePath = "/root/Spatial/"
var UIPath = "/root/Spatial/TempUI/"
var playerAmount = 4
var investment = 100
var paused = false
var scoreWin = 15000
var winner : String

# El init/create
func _ready():
	pass

func gameStart():
	gameStarted = true
	for i in range(1, playerAmount+1):
		get_node(basePath + "Player" + str(i)).visible = true
		get_node(basePath + "Player" + str(i)).nick = nicks[i - 1]
		
		get_node(UIPath + "Scores").get_child(i-1).visible = true
		var color : Color = get_node(basePath + players[i-1]).color
		get_node(UIPath + "Scores").get_child(i-1).get_child(0).add_color_override("font_color", color)
		
		get_node(UIPath + "Scores").get_child(i-1).get_child(0).text = nicks[i - 1]
		get_node(UIPath + "Scores").get_child(i-1).get_child(1).get_child(1).text = str(get_node(basePath + "Player" + str(i)).Cash)
		get_node(UIPath + "Scores").get_child(i-1).get_child(2).get_child(1).text = str(get_node(basePath + "Player" + str(i)).Score)
	pass

func startTurn(nick):
	turn += 1
	if players[turn] != nick:
		var aux = 0
		for p in players:
			if p != nick:
				aux += 1
			else:
				return
				
		var interm = players[turn]
		players[turn] = players[aux]
		players[aux] = interm
		
		gameStart()

func _process(delta):
	if gameStarted:
		if not checkWin():
			turn()
		else:
			get_node(basePath).visible = false
			get_node(UIPath + "WinState").visible = true
			get_node(UIPath + "WinState/Label").text = ("VICTORIA DE " + winner)

func getPaused():
	return paused

func setPaused(value):
	paused = value
	get_node(basePath + "Dice").paused = value
	get_node(UIPath + "exit").visible = value
	get_node(UIPath + "rollButton").disabled = value
	
	
	get_node(UIPath + "PauseLabel").visible = value
	
	for c in get_node(UIPath).get_children():
		for ch in c.get_children():
			if ch is TextureButton or ch is Button:
				ch.disabled = value
			elif ch is HBoxContainer or ch == VBoxContainer:
				for chi in ch.get_children():					
					if chi == TextureButton or chi == Button:
						chi.disabled = value
	


func getPlayerAmount():
	return playerAmount

func getTurn():
	return turn

func setTurn(value):
	turn = value

func setRolled(value):
	rolled = value

func checkWin():
	for i in range(0, playerAmount):
		if (get_node(basePath + players[i]).getScore() >= scoreWin):
			winner = get_node(basePath + players[i]).nick
			return true
		
		elif (players.size() == 1): #O puntuacion minima, o bancarrota
			winner = nicks[0]
			return true
	
	return false

func turn():
	if not paused:
		if not online or (online and players[turn] == me):
			if not rolled and get_node(UIPath + "rollButton").visible == false:
				get_node(UIPath + "rollButton").visible = true
				get_node(basePath + "Dice").rolling = true				

func endTurn():
	updateUI()
	
	gameManager.setRolled(false)
	get_node(UIPath + "rollButton").visible == false
	get_node(basePath + "Dice").visible = true
	
	get_node(UIPath + "Scores").get_child(turn).modulate.a = 0.3
			
	if (gameManager.getTurn() < gameManager.getPlayerAmount() - 1):
		gameManager.setTurn(gameManager.getTurn() + 1)
	else:
		gameManager.setTurn(0)
	
	get_node(UIPath + "Scores").get_child(turn).modulate.a = 1	
	
	if online:
		#avisar servidor de turn end
		pass

func moveEnded():
	var player = get_node(basePath + players[turn]) #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
	if (node.isToll()):
		endTurn()
	
	elif (node.isBank()):
		get_node(UIPath + "BankButtons").visible = true #UI visible e invisible
		
		if (player.suits[0] and player.suits[1] and player.suits[2] and player.suits[3]):
			get_node(UIPath + "BankButtons/Label").text = "Tienes todos los palos, enhorabuena. Toma tu merecido salario"
		
		else:
			get_node(UIPath + "BankButtons/Label").text = "No tienes todos los palos, vuelve más tarde."
		
	elif (node.isSuit()):
		get_node(UIPath + "SuitButtons").visible = true #UI visible e invisible
	
	elif (node.free and node.isBuild()): #Comprar casilla
		get_node(UIPath + "FreeBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "FreeBuildingButtons/Label").text = "Esta casilla está libre, ¿quieres comprarla?"
		get_node(UIPath + "FreeBuildingButtons/Label2").text = str(node.Price)
		
		if (player.Cash < node.Price):
			get_node(UIPath + "FreeBuildingButtons/HBoxContainer/Comprar").set_disabled(true)
		

	elif (node.Owner == player.nick and node.canInvest(10)): #Casilla propia
		get_node(UIPath + "InvestButtons").visible = true #UI visible e invisible
		get_node(UIPath + "InvestButtons/Label").text = "Esta casilla es tuya, ¿quieres invertir en ella?"
		get_node(UIPath + "InvestButtons/Label2").text = "10"
		
		
	else:	#Casilla ajena, despues puede haber expropiese
		get_node(UIPath + "TakenBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "TakenBuildingButtons/Label").text = "Esta casilla es de otro jugador, te toca pagar"
		
		if (player.Cash < node.Value):
			get_node(UIPath + "TakenBuildingButtons/HBoxContainer/Pagar").set_disabled(true)
			get_node(UIPath + "TakenBuildingButtons/HBoxContainer/Bancarrota").set_disabled(false)

#Dado
func roll_dice():
	if rolled:
		return
	
	get_node(basePath + "Dice").rolling = false
	dice = 1#randi() % 6 + 1
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

func canEndMovement():
	get_node(UIPath + "moveButtons").visible = true


func exitGame():
	if online:
		pass
	
	players.clear()
	nicks.clear()
	
	online = false
	host = false
	gameStarted = false
	rolled = false
	dice = 0
	players = [] #Array
	nicks = []
	turn = 0
	playerAmount = 4
	investment = 100
	paused = false
	scoreWin = 15000
	
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")

func getOrderFromNick(nick):
	return nicks.find(nick)

func updateUI():	
	var i = 0
	for p in players:
		var player = get_node(basePath + p)
		player.calculateScore()
		
		get_node(UIPath + "Scores").get_child(i).get_child(1).get_child(1).text = String(player.Cash)
		get_node(UIPath + "Scores").get_child(i).get_child(2).get_child(1).text = String(player.Score)
		
		i += 1

#???

############
#func out_for_lunch():
#	pass

############
#func quick_save():
#	pass
