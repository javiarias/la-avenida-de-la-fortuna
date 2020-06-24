extends Sprite3D

export(Array, String) var adjacencies = []

enum Type {BANK, BUILD, SUIT}
export(Type) var type = Type.BUILD

var Name: String = self.get_name()
#var Position: String #O como se quiera expresar
var District: int
var Price: int = 1600
var Value: int = 50
var Investment_Left: int
var free : bool = true
var Owner: String

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
