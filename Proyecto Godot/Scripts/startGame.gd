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
		$TempUI/Pause.text = "Pausar"
		gameManager.setPaused(false)
	else:
		$TempUI/Pause.text = "Resumir"
		gameManager.setPaused(true)

func acceptMove_pressed():
	get_node(UIPath + "moveButtons").visible = false
	
	#para que no se queden los dos en la misma casilla	
	var j = gameManager.getTurn()
	for i in gameManager.players:
		if (i != gameManager.players[j]):
			if (get_node(i).currentNode == get_node(gameManager.players[j]).currentNode):
				
				var ip = get_node(i)
				ip.set_translation(ip.get_translation() + Vector3(0.5,0,0))
				var jp = get_node(gameManager.players[j])
				jp.set_translation(jp.get_translation() - Vector3(0.5,0,0))
				
	gameManager.moveEnded()

func cancelMove_pressed():
	get_node(basePath + gameManager.players[gameManager.turn]).reverse()
	get_node(UIPath + "moveButtons").visible = false


func buyFreeBuilding_pressed():
	var player = get_node(basePath + gameManager.players[gameManager.turn])
	var node = get_node(basePath + "tiles/" + player.currentNode)
	node.modulate = player.color;
	
	if (node.free):
		player.Cash = player.Cash - node.Price
		node.free = false
		node.Owner = player.nick
		node.Value = node.Price / 2
		node.get_child((1)).set_text(String(node.Value))
		node.get_child((2)).visible = true
		player.properties.push_back(node)
	
	else:
		var owner = get_node(basePath + "Player" + str(gameManager.getOrderFromNick(node.Owner)))
		player.Cash = player.Cash - node.Price * 5
		owner.Cash = owner.Cash + node.Price * 5
		owner.properties.erase(node)
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
		get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/spade").modulate = Color(1, 1, 1, 1)
		
	elif (player.currentNode == "Palo_2"):
		player.suits[1] = true
		get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/clover").modulate = Color(1, 1, 1, 1)
		
	elif (player.currentNode == "Palo_3"):
		player.suits[2] = true
		get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/diamond").modulate = Color(1, 1, 1, 1)
		
	elif (player.currentNode == "Palo_4"):
		player.suits[3] = true
		get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/heart").modulate = Color(1, 1, 1, 1)
	
	get_node(UIPath + "SuitButtons").visible = false #UI visible e invisible
	gameManager.endTurn()
	
func BankSuit():
	var player = get_node(basePath + gameManager.players[gameManager.getTurn()]) 
	
	if (player.suits[0] and player.suits[1] and player.suits[2] and player.suits[3]):
		player.Cash = player.Cash + 1500
	
	else:
		pass
		
	
	get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/spade").modulate = Color(0.2, 0.2, 0.2, 0.5)
	get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/clover").modulate = Color(0.2, 0.2, 0.2, 0.5)
	get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/diamond").modulate = Color(0.2, 0.2, 0.2, 0.5)
	get_node(UIPath + "Scores/").get_child(gameManager.turn).get_node("suits/heart").modulate = Color(0.2, 0.2, 0.2, 0.5)
	
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
	var player_pay = get_node(basePath + gameManager.players[gameManager.turn])
	var node = get_node(basePath + "tiles/" + player_pay.currentNode)
	var player_earn = get_node(basePath + "Player" + str(gameManager.getOrderFromNick(node.Owner) + 1))
	
	player_pay.Cash = player_pay.Cash - node.Value
	player_earn.Cash = player_earn.Cash + node.Value
	
	
	
	get_node(UIPath + "TakenBuildingButtons").visible = false #UI visible e invisible
	
	gameManager.updateUI()
	
	if (player_pay.Cash >= node.Price * 5):
		get_node(UIPath + "FreeBuildingButtons").visible = true #UI visible e invisible
		get_node(UIPath + "FreeBuildingButtons/Label").text = "Esta casilla es de otro jugador, ¿quieres comprarla por 5 veces su valor?"
		get_node(UIPath + "FreeBuildingButtons/Label2").text = str(node.Price * 5)
	else:
		gameManager.endTurn()

func bankrupt():
	var p = get_node(basePath + gameManager.players[gameManager.getTurn()])
	
	for i in p.properties:
		i.free = true
		i.Owner = null
	
	gameManager.nicks.erase(gameManager.players[gameManager.getTurn()])
	gameManager.players.erase(gameManager.players[gameManager.getTurn()])

	#gameManager.playerAmount = gameManager.playerAmount - 1
	
	get_node(UIPath + "TakenBuildingButtons").visible = false
	gameManager.endTurn()


func exit_pressed():
	gameManager.exitGame()


func Menos_pressed():
	var txt = int(get_node(UIPath + "InvestButtons/Label2").text)
	if txt >= 10:
		get_node(UIPath + "InvestButtons/Label2").text = str(txt - 10)
		txt -= 10
	
	if txt < 10:
		get_node(UIPath + "InvestButtons/Menos").disabled = true
	elif get_node(UIPath + "InvestButtons/Mas").disabled and txt <= 490:
		get_node(UIPath + "InvestButtons/Mas").disabled = false
		
	if txt > get_node(basePath + gameManager.players[gameManager.turn]).Cash:
		get_node(UIPath + "InvestButtons/HBoxContainer/Invertir").disabled = true
	else:
		get_node(UIPath + "InvestButtons/HBoxContainer/Invertir").disabled = false


func Mas_pressed():
	var txt = int(get_node(UIPath + "InvestButtons/Label2").text)
	var node = get_node(basePath + "tiles/" + get_node(basePath + gameManager.players[gameManager.turn]).currentNode)
	if txt <= 490:
		get_node(UIPath + "InvestButtons/Label2").text = str(txt + 10)
		txt += 10
	
	if txt > 490 or not node.canInvest(txt + 10):
		get_node(UIPath + "InvestButtons/Mas").disabled = true
	elif get_node(UIPath + "InvestButtons/Menos").disabled and txt >= 10:
		get_node(UIPath + "InvestButtons/Menos").disabled = false	
	
	if txt > get_node(basePath + gameManager.players[gameManager.turn]).Cash  or not node.canInvest(txt):
		get_node(UIPath + "InvestButtons/HBoxContainer/Invertir").disabled = true
	else:
		get_node(UIPath + "InvestButtons/HBoxContainer/Invertir").disabled = false


func No_Invertir_pressed():
	get_node(UIPath + "InvestButtons").visible = false
	gameManager.endTurn()


func Invertir_pressed():
	var txt = int(get_node(UIPath + "InvestButtons/Label2").text)
	get_node(basePath + "tiles/" + get_node(basePath + gameManager.players[gameManager.turn]).currentNode).invest(txt)
	get_node(basePath + gameManager.players[gameManager.turn]).Cash -= txt
	get_node(UIPath + "InvestButtons").visible = false
	gameManager.endTurn()
	

func _on_MainMenu_pressed():
	gameManager.exitGame()
