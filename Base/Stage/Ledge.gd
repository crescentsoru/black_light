extends Area2D



var occupying = null #the character holding the ledge
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



#func on_body_enter(body):
#	if body.get_node_or_null('Ledgegrab'): #this is how the ledge checks if the kinematicbody2d it collided with is a player or not
#		collisions.append(body)

#func on_body_exit(body):
#	if body in collisions: collisions.erase(body)

func on_area_enter(area):
	if area.name == 'Ledgegrab':
		collisions.append(area.get_parent())
func on_area_exit(area):
	if area.name == 'Ledgegrab':
		if area.get_parent() in collisions: collisions.erase(area.get_parent())

func ledge_collision():
	for character in collisions:
		if character.ledgegrab_ok:
			if character.ledgedisable == 0 and character.grounded == false:
				if !character.inputheld(character.down):
					print ("valid ledgegrab")
					grab_ledge(character)
					break #instead of this, there should be a system that chooses which character is to
					# grab the ledge based on distance and amount of ledgegrabs w/o landing



func grab_ledge(character):
	occupying = character
	character.interactingcharacter = self
	character.state('ledgegrab')
	character.position = position + grabpos
	character.direction = direction
	



func choose_character():
	pass








func _physics_process(delta):
	if occupying == null: ledge_collision()
	if occupyframes > 0: occupyframes -=1
