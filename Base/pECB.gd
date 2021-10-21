extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var collisions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	connect( "body_entered", self, "on_body_enter")
	connect( "body_exited", self, "on_body_exit")
	connect( "area_entered", self, "on_area_enter")




func on_body_enter(body): #this won't be necessary I hope
	pass

func on_body_exit(body):
	pass


func on_area_enter(area): #or this
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
