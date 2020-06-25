extends Sprite3D

export(Array, String) var adjacencies = []

enum Type {BANK, BUILD, SUIT, TOLL}
export(Type) var type = Type.BUILD
export(int) var Value
export(int) var Price

var Name: String = self.get_name()
#var Position: String #O como se quiera expresar
var District: int
#var Price: int = 1600
#var Value: int = 50
var Investment_Left: int = 0
var Investment_Total: int = 1000
var free : bool = true
var Owner: String

func getAdjacencies():
	return adjacencies

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func isBuild():
	if (type == Type.BUILD):
		return true
	else:
		return false

func isToll():
	if (type == Type.TOLL):
		return true
	else:
		return false

func isSuit():
	if (type == Type.SUIT):
		return true
	else:
		return false
		
func isBank():
	if (type == Type.BANK):
		return true
	else:
		return false

# Called when the node enters the scene tree for the first time.
func _ready():
	var text = get_child(1)
	if (text != null):
		if (self.type == Type.BUILD):
			text.set_text(String(Price))
		elif (self.type == Type.TOLL):
			text.set_text(String(Value))
			
	var model = get_child((2))
	if (model != null):
		model.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
