extends Control


var UIPath = "./TempUI/"
var canContinue = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HBoxContainer3/Player1/Label").text = gameManager.me
	
	
func _process(delta):
	if canContinue:
		get_tree().change_scene("res://Scenes/diceOrder.tscn")


func _on_Continue_pressed():
	#player ready to server
	pass


func _on_Cancel_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
