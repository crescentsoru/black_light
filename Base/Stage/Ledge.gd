extends Area2D


var occupying = [] #the character holding the ledge
var occupyframes = 0 #if 0, anyone can grab

export var direction = 1 #-1 and 1 same as characters. 
var floorpos = Vector2(0,0) #the position the character uses for stuff like getup, getup attack. All pos vars are relative to ledgebox position
var releasepos = Vector2(0,0) #the position you're in if you release ledge by pressing back.
var grabpos = Vector2(0,0) #the position you're snapped to when you grab ledge. Should be same as releasepos but go buckwild I guess


var collisions = []



func _ready():
	process_priority = 31 #I don't FUCKING know
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")
	connect( "body_entered", self, "on_body_enter")
	connect( "body_exited", self, "on_body_exit")



func on_body_enter(body):
	print (body.name + " ")
	
	if body.get_node_or_null('Ledgegrab'): #this is how the ledge checks if the kinematicbody2d it collided with is a player or not
		if body.ledgegrab_ok:

			if body.ledgedisable == 0 and body.grounded == false:
				if !body.inputheld(body.down):
					print ("valid ledgegrab")
				else: print ("down held")




func on_body_exit(body):
	pass


func _physics_process(delta):
	pass

