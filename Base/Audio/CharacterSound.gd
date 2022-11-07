extends AudioStreamPlayer2D




func _ready():
	pass



func _process(delta):
	if !playing:
		queue_free()
