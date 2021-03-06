extends Spatial

var path = "../tiles/"
var currentNode = "Banco"
var moves = 0
var roll = 0
var myTurn = true
var movement = []
var nick: String = "EEE"
var Cash: int = 1500
var Score: int = 0
var properties = []
var suits = [false, false, false, false]
var stocks = [0,0,0,0,0]
var canEndMovement = false
var pos
export var color: Color = Color(0, 0, 0, 1)

var node

func getScore():
	return Score

func cellClicked(name):
	if not gameManager.online or (gameManager.online and gameManager.players[gameManager.turn] == nick and gameManager.players[gameManager.turn] == gameManager.me):
		if moves > 0:
			if movement.size() > 0 and name == movement.back():
				reverse()
			
			else:
				for cell in get_node(path + currentNode).getAdjacencies() :
					if cell == name :
						moves -= 1
						if moves > 0:
							get_node("../Dice").frame = moves - 1
						else:
							get_node("../Dice").visible = false
							
						movement.append(currentNode)
						
						currentNode = name
						var cellPos = get_node(path + currentNode).global_transform.origin
						global_transform.origin = Vector3(cellPos.x, global_transform.origin.y, cellPos.z)
						
						if moves == 0:
							gameManager.canEndMovement()
							canEndMovement = true
						
						return

func newRoll(rolled):
	moves = rolled
	roll = rolled
	movement.clear()
	canEndMovement = false


func _input(event):
	if not gameManager.online or (gameManager.online and gameManager.players[gameManager.turn] == nick and gameManager.players[gameManager.turn] == gameManager.me):
		if not gameManager.paused:
			if not canEndMovement:
				if event is InputEventMouseButton:
					if event.pressed and event.button_index == 2:
						reverse()


func reverse():
	if myTurn and moves < roll:		
		var cellPos = get_node(path + movement.back()).global_transform.origin
		currentNode = movement.back()
		movement.pop_back()
		global_transform.origin = Vector3(cellPos.x, global_transform.origin.y, cellPos.z)
		
		if moves == 0:
			get_node("../Dice").visible = true			
			canEndMovement = false
			
		moves += 1
		get_node("../Dice").frame = moves - 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func calculateScore():
	var propValue = 0
	
	for i in properties:
		var property = i.Value
		propValue = propValue + property
		
	Score = Cash + propValue

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
