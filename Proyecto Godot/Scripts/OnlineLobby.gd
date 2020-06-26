extends Control


var UIPath = "./TempUI/"
var canContinue = false

var playerNum = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HBoxContainer3/Player1/Label").text = gameManager.me
	
	
func _process(delta):
	if canContinue:
		get_tree().change_scene("res://Scenes/diceOrder.tscn")


func _on_Continue_pressed():
	#player ready to server
	pass
	
func addPlayer(nick):
	playerNum += 1
	get_node("HBoxContainer3/Player" + playerNum + "/Label").text = nick
	get_node("HBoxContainer3/Player" + playerNum).visible = true

func removePlayer(order):
	pass


func _on_Cancel_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
