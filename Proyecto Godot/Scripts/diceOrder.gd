extends Control


var rolled = 0
var rolls = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, gameManager.playerAmount + 1):
		get_node("playerList/Player" + str(i)).visible = true
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
	if rolled >= gameManager.playerAmount:
		rolls.sort_custom(Sorter, "sort_rolls")
		for p in rolls:
			gameManager.players.append("Player" + str(p[0]))
		get_tree().change_scene("res://Scenes/Ingame.tscn")
		return
	
	rolled += 1
	
	get_node("Dado" + str(rolled)).rolling = false
	var dice = randi() % 6 + 1
	get_node("Dado" + str(rolled)).frame = dice - 1
	rolls.append([rolled, dice])
	
	if rolled == gameManager.playerAmount:
		get_node("buttons/roll").text = "Jugar"


class Sorter:
	static func sort_rolls(a, b):
		# is they're equal it's random
		if a[1] == b[1]:
			return bool(randi() % 1)
		else:
			return a[1] > b[1]
