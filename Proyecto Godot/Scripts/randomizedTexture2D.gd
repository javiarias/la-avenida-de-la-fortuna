extends Sprite

var time = 0.1
var temp = 0

var rolling = true

func _process(delta):
	if rolling:
		temp += delta
		if temp >= time:
			temp = 0
			var newFrame = randi() % 6
			while newFrame == frame:
				newFrame = randi() % 6
			
			frame = newFrame
