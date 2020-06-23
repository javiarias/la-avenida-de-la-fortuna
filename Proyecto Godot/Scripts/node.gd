extends Sprite3D

export(Array, String) var adjacencies = []

enum Type {BANK, BUILD, SUIT}
export(Type) var type = Type.BUILD

func getAdjacencies():
	return adjacencies

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
