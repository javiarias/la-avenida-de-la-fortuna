extends Control

var scene_path_to_load

func _ready():
	$Menu/CenterContainer/Buttons/Local.grab_focus()

func _on_Button_pressed(scene_to_load):	
	scene_path_to_load = scene_to_load


func _on_FadeIn_fade_finished():
	$FadeIn.hide()
	get_tree().change_scene(scene_path_to_load)


func _on_Exit_pressed():	
		get_tree().quit()


func _on_Local_pressed():
	$FadeIn.show()
	$FadeIn.fade_in()
	gameManager.online = false
	scene_path_to_load = "res://Scenes/LocalLobby.tscn"


func _on_Host_pressed():
	$FadeIn.show()
	$FadeIn.fade_in()
	gameManager.host = true
	gameManager.online = true
	scene_path_to_load = "res://Scenes/HostScene.tscn"


func _on_Join_pressed():
	$FadeIn.show()
	$FadeIn.fade_in()
	gameManager.host = false
	gameManager.online = true
	scene_path_to_load = "res://Scenes/HostScene.tscn"
