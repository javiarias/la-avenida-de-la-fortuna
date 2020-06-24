extends Spatial

#Variables
var rolled = false
var dice = 0
var players = ["Player1"] #Array
var turn = 0
var UIPath = "./TempUI/"

var investment = 100
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


# El init/create
func _ready():
	pass # Replace with function body.
#Enganchar botones con funciones

# El update
func _process(delta):
	if not rolled and get_node(UIPath + "rollButton").visible == false:
		get_node(UIPath + "rollButton").visible = true
		get_node("Dice").rolling = true

#Funciones adicionales

func moveEnded():
	var player = get_node("Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node("tiles/" + player.currentNode)
	
	if (node.free): #Comprar
		get_node(UIPath + "FreeBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "FreeBuildingButtons/Label").text = "Esta casilla está libre, ¿quieres comprarla?"
		
		if (player.Cash < node.Price):
			get_node(UIPath + "FreeBuildingButtons/Comprar").set_disabled(true)
		

	elif (node.Owner == player.Name): #Casilla propia
		get_node(UIPath + "OwnBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "OwnBuildingButtons/Label").text = "Esta casilla es tuya, ¿quieres invertir en ella?"
		

	else:	#Casilla ajena
		get_node(UIPath + "TakenBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "TakenBuildingButtons/Label").text = "Esta casilla es de otro jugador, te toca pagar"
		
		if (player.Cash < node.Value):
					get_node(UIPath + "TakenBuildingButtons/Pagar").set_disabled(true)

#Dado
func roll_dice():
	if rolled:
		return
	
	get_node("Dice").rolling = false
	dice = randi() % 6 + 1
	$Dice.frame = dice - 1
	#$DiceButton.disabled = true
	rolled = true
	get_node(players[turn]).newRoll(dice)
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














func _on_Button_pressed():
	pass # Replace with function body.

func rollButton_pressed():
	roll_dice()
	get_node(UIPath + "rollButton").visible = false


func acceptMove_pressed():
	get_node(UIPath + "moveButtons").visible = false
	
	#PlayerInfo.Position.Name = PlayerInfo.currentNode
	moveEnded()

func cancelMove_pressed():
	get_node("./" + players[turn]).reverse()
	get_node(UIPath + "moveButtons").visible = false

func buyFreeBuilding_pressed():
	var player = get_node("Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node("tiles/" + player.currentNode)
	
	#if (player.Cash => node.Price): A priori no hace falta la comprobacion porque si no el boton está desactivado
	player.Cash = player.Cash - node.Price
	node.free = false
	node.Owner = player.Name
	
	#Algo mas?
	get_node(UIPath + "FreeBuildingButtons").visible = false

func pass_on_Building_pressed():
	#Se reutiliza para todos los casos, asi que pongo en false la visibilidad de la UI y tirando
	get_node(UIPath + "FreeBuildingButtons").visible = false
	get_node(UIPath + "OwnBuildingButtons").visible = false
	#Siguiente turno stuff
	pass

func invest_on_Building():
	get_node(UIPath + "OwnBuildingButtons").visible = false
	get_node(UIPath + "InvestButtons").visible = true

func add_Investment():
	var player = get_node("Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	
	if (investment <= player.Cash - 50):
		investment = investment + 50
	else:
		get_node(UIPath + "InvestButtons/Mas").set_disabled(true)

func reduce_Investment():
	if (investment >= 0):
		investment = investment - 50
	else:
		get_node(UIPath + "InvestButtons/Menos").set_disabled(true)


func confirm_Investment():
	var player = get_node("Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node("tiles/" + player.currentNode)
	
	player.Cash = player.Cash - investment
	node.Investment_Left = node.Investment_Left - investment
	investment = 100 #Reset de valor
	get_node(UIPath + "InvestButtons").visible = false

func cancel_Investment():
	investment = 100 #Reset de valor
	get_node(UIPath + "OwnBuildingButtons").visible = true
	get_node(UIPath + "InvestButtons").visible = false

func pay_Building():
	var player_pay = get_node("Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node("tiles/" + player_pay.currentNode)
	var player_earn = get_node(node.owner) #Aqui
	
	player_pay.Cash = player_pay.Cash - node.Value
	player_earn.Cash = player_earn.Cash + node.Value
	
	get_node(UIPath + "TakenBuildingButtons").visible = false #UI visible e invisible

func bankrupt():
	pass #que hacemos aqui
