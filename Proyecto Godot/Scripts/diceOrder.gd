extends Control


var rolled = 0
var rolls = []


# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager.currentScene = "diceOrder"
	if not gameManager.online:
		gameManager.nicks = ["Player 1", "Player 2", "Player 3", "Player 4"]
	else:
		get_node("buttons/Button").visible = false
	
	for i in range(1, gameManager.playerAmount + 1):
		get_node("playerList/Player" + str(i)).visible = true
		get_node("playerList/Player" + str(i) + "/Label").text = gameManager.nicks[i - 1]
		get_node("Dado" + str(i)).visible = true
		
	var node = get_node("playerList/Player" + str(gameManager.playerAmount))
	var size = node.get_size().x
	
	for i in range(1, gameManager.playerAmount + 1):
		var sizeAux = size
		
		if gameManager.playerAmount == 3:
			if i == 2:
				sizeAux = 0
		elif gameManager.playerAmount == 4:
			if i == 2:
				sizeAux = -size * 1.1
			elif i == 3:
				sizeAux = -size * 0.4
				
		node = get_node("playerList/Player" + str(i))
		var x = node.get_global_transform().get_origin().x
		get_node("Dado" + str(i)).global_transform.origin.x = x + (sizeAux / 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/LocalLobby.tscn")

func _on_roll_pressed():
	if not gameManager.online:
		if rolled >= gameManager.playerAmount:
			rolls.sort_custom(Sorter, "sort_rolls")
			gameManager.nicks.clear()
			for p in rolls:
				gameManager.players.append("Player" + str(p[0]))
				gameManager.nicks.append(p[2])
			get_tree().change_scene("res://Scenes/Ingame.tscn")
			return
		
		rolled += 1
		
		get_node("Dado" + str(rolled)).rolling = false
		var dice = randi() % 6 + 1
		get_node("Dado" + str(rolled)).frame = dice - 1
		rolls.append([rolled, dice, gameManager.nicks[rolled - 1]])
		
		if rolled == gameManager.playerAmount:
			get_node("buttons/roll").text = "Jugar"
			
	else:
		rolled += 1
		get_node("Dado1").rolling = false
		var dice = randi() % 6 + 1
		get_node("Dado1").frame = dice - 1
		get_node("buttons/roll").disabled = true
		gameManager.cpp.roll(dice)
		
		if rolled >= gameManager.playerAmount:
			get_tree().change_scene("res://Scenes/Ingame.tscn")
			return
		

func onlineRolled(player, roll):
	rolled += 1
		
	get_node("Dado" + str(player)).rolling = false
	get_node("Dado" + str(player)).frame = roll - 1
	
	if rolled >= gameManager.playerAmount:
		get_tree().change_scene("res://Scenes/Ingame.tscn")
		return


class Sorter:
	static func sort_rolls(a, b):
		# is they're equal it's random
		if a[1] == b[1]:
			return bool(randi() % 1)
		else:
			return a[1] > b[1]
