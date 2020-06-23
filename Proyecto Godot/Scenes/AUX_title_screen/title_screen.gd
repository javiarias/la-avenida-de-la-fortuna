extends Control

var scene_path_to_load

func _ready():
	$Menu/CenterContainer/Buttons/Local.grab_focus()
	for button in $Menu/CenterContainer/Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])

#En vez de foreach, habra que meter otro botón para el exit?

func _on_Button_pressed(scene_to_load):	
	if scene_to_load == "":		
		get_tree().quit()
	else:
		$FadeIn.show()
		$FadeIn.fade_in()
		scene_path_to_load = scene_to_load


func _on_FadeIn_fade_finished():
	$FadeIn.hide()
	get_tree().change_scene(scene_path_to_load)
