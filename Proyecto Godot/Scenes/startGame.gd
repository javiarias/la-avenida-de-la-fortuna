extends Spatial


var UIPath = "./TempUI/"
var basePath = "./"

func _ready():
	gameManager.gameStart()

func _on_Button_pressed():
	pass # Replace with function body.

func rollButton_pressed():
	gameManager.roll_dice()
	get_node(UIPath + "rollButton").visible = false


func acceptMove_pressed():
	get_node(UIPath + "moveButtons").visible = false
	
	#PlayerInfo.Position.Name = PlayerInfo.currentNode
	gameManager.moveEnded()

func cancelMove_pressed():
	get_node(basePath + gameManager.players[gameManager.turn]).reverse()
	get_node(UIPath + "moveButtons").visible = false

func buyFreeBuilding_pressed():
	var player = get_node(basePath + "Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
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
	var player = get_node(basePath + "Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	
	if (gameManager.investment <= player.Cash - 50):
		gameManager.investment = gameManager.investment + 50
	else:
		get_node(UIPath + "InvestButtons/Mas").set_disabled(true)

func reduce_Investment():
	if (gameManager.investment >= 0):
		gameManager.investment = gameManager.investment - 50
	else:
		get_node(UIPath + "InvestButtons/Menos").set_disabled(true)


func confirm_Investment():
	var player = get_node(basePath + "Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
	player.Cash = player.Cash - gameManager.investment
	node.Investment_Left = node.Investment_Left - gameManager.investment
	gameManager.investment = 100 #Reset de valor
	get_node(UIPath + "InvestButtons").visible = false

func cancel_Investment():
	gameManager.investment = 100 #Reset de valor
	get_node(UIPath + "OwnBuildingButtons").visible = true
	get_node(UIPath + "InvestButtons").visible = false

func pay_Building():
	var player_pay = get_node(basePath + "Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player_pay.currentNode)
	var player_earn = get_node(basePath + node.owner) #Aqui
	
	player_pay.Cash = player_pay.Cash - node.Value
	player_earn.Cash = player_earn.Cash + node.Value
	
	get_node(UIPath + "TakenBuildingButtons").visible = false #UI visible e invisible

func bankrupt():
	pass #que hacemos aqui
