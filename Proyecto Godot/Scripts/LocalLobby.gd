extends Control


var UIPath = "./TempUI/"

# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager.playerAmount = 2
	get_node("HBoxContainer3/Player1").visible = true
	get_node("HBoxContainer3/Player2").visible = true


func _on_Continue_pressed():
	if(gameManager.playerAmount == 1):
		get_tree().change_scene("res://Scenes/Ingame.tscn")
		gameManager.nicks.append("Player 1")
		gameManager.players.append("Player1")
	else:
		get_tree().change_scene("res://Scenes/diceOrder.tscn")


func _on_Cancel_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")


func _on_left_pressed():
	get_node("HBoxContainer3/Player" + str(gameManager.playerAmount)).visible = false
	
	if gameManager.playerAmount == 3:
		get_node("HBoxContainer2/left").disabled = true
	elif gameManager.playerAmount == 4:
		get_node("HBoxContainer2/right").disabled = false
	gameManager.playerAmount -= 1
	
	get_node("HBoxContainer2/Label").text = str(gameManager.playerAmount)


func _on_right_pressed():
	if gameManager.playerAmount == 2:
		get_node("HBoxContainer2/left").disabled = false
	elif gameManager.playerAmount == 3:
		get_node("HBoxContainer2/right").disabled = true
	gameManager.playerAmount += 1
	
	get_node("HBoxContainer3/Player" + str(gameManager.playerAmount)).visible = true
	
	get_node("HBoxContainer2/Label").text = str(gameManager.playerAmount)
