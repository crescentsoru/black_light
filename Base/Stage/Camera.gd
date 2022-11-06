extends Camera2D

var targets = []
var initial_position := Vector2(5000,4601)

func find_players():
	pass


func _ready():
	print ("targets= " + str(targets))



func _process(delta):
	position = Vector2(0,0)
	for x in targets:
		position += x.position
		pass
	#position = (targets[0].position + targets[1].position) / 2
	position = position / len(targets)


