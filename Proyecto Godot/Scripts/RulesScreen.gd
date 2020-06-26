extends Control

var scene_path_to_load

func _ready():
	pass

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")
