extends Area2D



var collisions = []


func _ready():
	connect( "body_entered", self, "on_body_enter")
	connect( "body_exited", self, "on_body_exit")
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")



func on_body_enter(body):
	collisions.append(body)

func on_body_exit(body):
	for x in collisions:
		if x == body:
			collisions.erase(x)


func on_area_enter(area): #what do I even use this for 
	pass #maybe ledge collision

func on_area_exit(area):
	pass

func _process(delta):
	pass
	#print (collisions)
