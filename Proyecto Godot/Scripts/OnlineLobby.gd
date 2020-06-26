extends Control


var UIPath = "./TempUI/"
var canContinue = false

var playerNum = 1
var players = []

# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager.currentScene = "OnlineLobby"
	players.append(gameManager.me)
	updateLobby()
	
	
func _process(delta):
	if canContinue:
		get_tree().change_scene("res://Scenes/diceOrder.tscn")


func _on_Continue_pressed():
	gameManager.cpp.ready();
	gameManager.readyPlayers += 1
	get_node("HBoxContainer/Cancel").disabled = true
	get_node("HBoxContainer/Continue").disabled = true
	
	if gameManager.readyPlayers >= gameManager.playerAmount:
		canContinue = true
	
func addPlayer(nick):
	playerNum += 1
	players.append(nick)
	updateLobby()

func removePlayer(nick):
	playerNum -= 1
	players.erase(nick)
	updateLobby()

func updateLobby():
	for i in range(1, 5):
		get_node("HBoxContainer3/Player" + str(i)).visible = false
		
	for i in range(0, playerNum):
		get_node("HBoxContainer3/Player" + str(i + 1) + "/Label").text = players[i]
		get_node("HBoxContainer3/Player" + str(i + 1)).visible = true
	pass

func _on_Cancel_pressed():
	gameManager.logout()
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
