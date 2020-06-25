extends Sprite3D

var time = 0.1
var temp = 0

var rolling = false
var paused = false

func _process(delta):
	if not paused and rolling:
		temp += delta
		if temp >= time:
			temp = 0
			var newFrame = randi() % 6
			while newFrame == frame:
				newFrame = randi() % 6
			
			frame = newFrame
