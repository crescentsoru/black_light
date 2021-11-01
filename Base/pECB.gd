extends Area2D



var collisions = []


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


func _process(delta):
	pass
