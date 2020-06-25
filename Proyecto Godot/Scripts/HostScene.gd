extends Control


var one = ""
var two = ""
var three = ""
var four = ""
var port = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func text_changed(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		port = new_text
		get_node("HBoxContainer/LineEdit").add_color_override("font_color", Color(1,1,1,1))
	else:
		get_node("HBoxContainer/LineEdit").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


func text_changed2(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		port = new_text
		get_node("HBoxContainer/LineEdit2").add_color_override("font_color", Color(1,1,1,1))
	else:
		get_node("HBoxContainer/LineEdit2").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


func text_changed3(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		port = new_text
		get_node("HBoxContainer/LineEdit3").add_color_override("font_color", Color(1,1,1,1))
	else:
		get_node("HBoxContainer/LineEdit3").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


func text_changed4(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		port = new_text
		get_node("HBoxContainer/LineEdit4").add_color_override("font_color", Color(1,1,1,1))
	else:
		get_node("HBoxContainer/LineEdit4").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


func text_changedPort(new_text):
	if new_text.is_valid_integer():
		port = new_text
		get_node("HBoxContainer/LineEdit5").add_color_override("font_color", Color(1,1,1,1))
	else:
		get_node("HBoxContainer/LineEdit5").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


