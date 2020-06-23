extends Spatial

var currentNode = "Banco"
var moves = 10
var roll = 10
var myTurn = true
var movement = []

var gameManager


func cellClicked(name):
	if moves > 0:
		for cell in get_node("../" + currentNode).getAdjacencies() :
			if cell == name :
				moves -= 1
				movement.append(currentNode)
				
				#print(name)
				
				currentNode = name
				var cellPos = get_node("../" + currentNode).global_transform.origin
				global_transform.origin = Vector3(cellPos.x, global_transform.origin.y, cellPos.z)
				
				if moves == 0:
					pass#gameManager.canEndMovement()
				
				return

func newRoll(rolled):
	moves = rolled
	roll = rolled
	movement.clear()
	

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 2:
			reverse()
		

func reverse():
	if myTurn and moves < roll:		
		var cellPos = get_node("../" + movement.back()).global_transform.origin
		currentNode = movement.back()
		movement.pop_back()
		global_transform.origin = Vector3(cellPos.x, global_transform.origin.y, cellPos.z)
		moves += 1
		print(moves)

# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager = get_node("..")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
