extends Area2D



var collisions = []
var areacollisions = []

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

func current_ecbcheck():

#Blastzone collision checks happen in collision_handler, *before* pECB is updated.
#This is because kinematicbody2d doesn't really have a check for areas. Technically, I could simply add another area,
#Which would track the kinematicbody2d's collision box every frame, but, pECB does that already, so I saw no reason to add another Area2d.
#I guess this technically makes projected ECB a current ECB as well, before it updates?
	for x in areacollisions:
		if x.name.substr(0,9) == 'Blastzone':
			if x.blastzonetype == 'kill':
				self.get_parent().fuckingdie()
				return
				
			elif x.blastzonetype == 'top':
				if get_parent().state in ['hitstun','tumble']:
					self.get_parent().fuckingdie()
					return
		if x.name.substr(0,6) == 'Hitbox':
			pass
	




func on_area_enter(area):  
#maybe can also use this for ledge collision
	areacollisions.append(area)
func on_area_exit(area):
	for x in areacollisions:
		if x == area:
			areacollisions.erase(x)

func _process(delta):
	pass
	#print (collisions)
