extends RigidBody


func _input_event(camera, event, click_pos, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			var name = get_node("../").get_name()
			var gameManager = get_tree().get_root().get_child(0)
			var player = gameManager.players[gameManager.turn]
			get_node("../../../" + player).cellClicked(name)
