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

func pauseGame():
	if (gameManager.getPaused()):
		$TempUI/Pause.text = "Pause"
		gameManager.setPaused(false)
	else:
		$TempUI/Pause.text = "Resume"
		gameManager.setPaused(true)

func acceptMove_pressed():
	get_node(UIPath + "moveButtons").visible = false
	
	#para que no se queden los dos en la misma casilla
	var j = gameManager.getTurn()
	for i in gameManager.players:
		if (i != gameManager.players[j]):
			if (get_node(i).currentNode == get_node(gameManager.players[j]).currentNode):
				var pos = get_node(i).global_transform.origin
				global_transform.origin = Vector3(pos.x - 1, global_transform.origin.y, pos.z)
					
				var pos2 = get_node(gameManager.players[j]).global_transform.origin
				global_transform.origin = Vector3(pos2.x + 1, global_transform.origin.y, pos2.z)					
					
	gameManager.moveEnded()

func cancelMove_pressed():
	get_node(basePath + gameManager.players[gameManager.turn]).reverse()
	get_node(UIPath + "moveButtons").visible = false


func buyFreeBuilding_pressed():
	var player = get_node(basePath + "Player1") #Aqui igual hay que cambiar que jugador se coge en funcion del turno
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
	if (node.free):
		player.Cash = player.Cash - node.Price
		node.free = false
		node.Owner = player.nick
		node.get_child((1)).set_text(String(node.Value))
		node.get_child((2)).visible = true
		player.properties.push_back(node)
	
	else:
		player.Cash = player.Cash - node.Price * 5
		node.Owner.Cash = node.Owner.Cash - node.Price * 5
		node.Owner.properties.erase(node)
		node.Owner = player.nick
		player.properties.push_back(node)
		
	#Algo mas?
	get_node(UIPath + "FreeBuildingButtons").visible = false
	gameManager.endTurn()

func pass_on_Building_pressed():
	#Se reutiliza para todos los casos, asi que pongo en false la visibilidad de la UI y tirando
	get_node(UIPath + "FreeBuildingButtons").visible = false
	#get_node(UIPath + "OwnBuildingButtons").visible = false
	
	gameManager.endTurn()

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

func suitConfirm():
	var player = get_node(basePath + gameManager.players[gameManager.getTurn()]) 
	
	if (player.currentNode == "Palo_1"):
		player.suits[0] = true
		
	elif (player.currentNode == "Palo_2"):
		player.suits[1] = true
		
	elif (player.currentNode == "Palo_3"):
		player.suits[2] = true
		
	elif (player.currentNode == "Palo_4"):
		player.suits[3] = true
	
	get_node(UIPath + "SuitButtons").visible = false #UI visible e invisible
	gameManager.endTurn()
	
func BankSuit():
	var player = get_node(basePath + gameManager.players[gameManager.getTurn()]) 
	
	if (player.suits[0] and player.suits[1] and player.suits[2] and player.suits[3]):
		player.Cash = player.Cash + 1500
	
	else:
		pass
	
	get_node(UIPath + "BankButtons").visible = false #UI visible e invisible
	gameManager.endTurn()
	
func confirm_Investment():
	var player = get_node(basePath + gameManager.players[gameManager.getTurn()]) 
	var node = get_node(basePath + "tiles/" + player.currentNode)
	
	player.Cash = player.Cash - gameManager.investment
	node.Investment_Left = node.Investment_Left - gameManager.investment
	gameManager.investment = 100 #Reset de valor
	get_node(UIPath + "InvestButtons").visible = false
	gameManager.endTurn()

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
	
	if (player_pay.Cash >= node.Price):
		get_node(UIPath + "FreeBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "FreeBuildingButtons/Label").text = "Esta casilla es de otro jugador, ¿quieres comprarla a 5 veces su precio?"
	else:
		gameManager.endTurn()

func bankrupt():
	var p = get_node(basePath + gameManager.players[gameManager.getTurn()])
	
	for i in p.properties:
		i.free = true
		i.Owner = null
	
	gameManager.players.erase(gameManager.players[gameManager.getTurn()])
	#gameManager.playerAmount = gameManager.playerAmount - 1
	
	#Quitar de players o algo?
