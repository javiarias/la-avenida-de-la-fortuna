extends Control


var one = "127"
var two = "0"
var three = "0"
var four = "1"
var port = "7890"
var nick = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager.currentScene = "HostScene"
	if not gameManager.host:
		get_node("Label2").text = "Cliente"
		get_node("loading/Label").text = "\nConectando..."
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func text_changed(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		one = new_text
		get_node("HBoxContainer/LineEdit").add_color_override("font_color", Color(1,1,1,1))
		
		if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
			get_node("HBoxContainer2/confirm").disabled = false
	else:
		get_node("HBoxContainer/LineEdit").add_color_override("font_color", Color(1,0,0,1))		
		one = ""


func text_changed2(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		two = new_text
		get_node("HBoxContainer/LineEdit2").add_color_override("font_color", Color(1,1,1,1))
		
		if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
			get_node("HBoxContainer2/confirm").disabled = false
	else:
		get_node("HBoxContainer/LineEdit2").add_color_override("font_color", Color(1,0,0,1))		
		two = ""


func text_changed3(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		three = new_text
		get_node("HBoxContainer/LineEdit3").add_color_override("font_color", Color(1,1,1,1))
		
		if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
			get_node("HBoxContainer2/confirm").disabled = false
	else:
		get_node("HBoxContainer/LineEdit3").add_color_override("font_color", Color(1,0,0,1))		
		three = ""


func text_changed4(new_text):
	if new_text.is_valid_integer() and int(new_text) <= 255 and int(new_text) >= 0:
		four = new_text
		get_node("HBoxContainer/LineEdit4").add_color_override("font_color", Color(1,1,1,1))
		
		if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
			get_node("HBoxContainer2/confirm").disabled = false
	else:
		get_node("HBoxContainer/LineEdit4").add_color_override("font_color", Color(1,0,0,1))		
		four = ""


func text_changedPort(new_text):
	if new_text.is_valid_integer():
		port = new_text
		get_node("HBoxContainer/LineEdit5").add_color_override("font_color", Color(1,1,1,1))
		
		if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
			get_node("HBoxContainer2/confirm").disabled = false
	else:
		get_node("HBoxContainer/LineEdit5").add_color_override("font_color", Color(1,0,0,1))		
		port = ""


func _on_confirm_pressed():	
	if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
		get_node("HBoxContainer2/confirm").disabled = true
		get_node("HBoxContainer2/back").disabled = true
		get_node("HBoxContainer/LineEdit").editable = false
		get_node("LineEdit6").editable = false
		for i in range(2, 6):
			get_node("HBoxContainer/LineEdit" + str(i)).editable = false
		
		get_node("loading").visible = true
		
		#try to get connection
		#if succeeds, load lobby scene
		var serv = one + "." + two + "." + three + "." + four
		gameManager.cpp.start(serv, port, nick, gameManager.host)
		
		gameManager.online = true;
		
		
		gameManager.nicks.append(nick);
		gameManager.me = nick
		get_tree().change_scene("res://Scenes/OnlineLobby.tscn")
		
	
func _on_cancel_pressed():
	get_node("HBoxContainer2/confirm").disabled = false
	get_node("HBoxContainer2/back").disabled = false
	get_node("HBoxContainer/LineEdit").editable = true
	get_node("LineEdit6").editable = true
	for i in range(2, 6):
		get_node("HBoxContainer/LineEdit" + str(i)).editable = true
			
	get_node("loading").visible = false


func _on_back_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")


func nickChanged(new_text):
	nick = new_text
			
	if one != "" and two != "" and three != "" and four != "" and port != "" and nick != "":
		get_node("HBoxContainer2/confirm").disabled = false
