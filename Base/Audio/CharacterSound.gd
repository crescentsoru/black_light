extends AudioStreamPlayer2D




func _ready():
	pass



func _process(delta):
	if !playing:
		print ("not playing")
		#queue_free()
