extends Area2D



var occupying = null #the character holding the ledge
var occupyframes = 0 #if 0, anyone can grab

export var direction = 1 #-1 and 1 same as characters. 
export var floorpos = Vector2(16,0) #the position the character uses for stuff like getup, getup attack. All pos vars are relative to ledgebox position
export var grabpos = Vector2(-70,0) #the position you're snapped to when you grab ledge. Should be same as releasepos but go buckwild I guess


var collisions = []



func _ready():
	process_priority = 150 #I don't FUCKING know
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")
	connect( "body_entered", self, "on_body_enter")
	connect( "body_exited", self, "on_body_exit")



func on_area_enter(area):
	if area.name == 'Ledgegrab':
		collisions.append(area.get_parent())
func on_area_exit(area):
	if area.name == 'Ledgegrab':
		if area.get_parent() in collisions: collisions.erase(area.get_parent())

func ledge_collision():
	var valid_chars = []
	for character in collisions:
		if character.ledgegrab_ok:
			if character.ledgedisable == 0 and character.grounded == false:
				if !character.inputheld(character.down):
					valid_chars.append(character)
					
	var best_char = null #obj reference
	var best_distance = 9999999999999
	if len(valid_chars) > 0:
		print ("valid_chars= " + str(valid_chars))
		for x in valid_chars:
			var distance = x.position.distance_to(position)
			print (distance)
			if distance < best_distance:
				best_distance = distance
				best_char = x
	if best_char != null: grab_ledge(best_char)


func grab_ledge(character):
	occupying = character
	character.interactingcharacter = self
	character.state('ledgegrab')
	character.position = position + (grabpos*direction)
	character.direction = direction
	



func choose_character():
	pass





func unoccupy():
	occupying.interactingcharacter = null
	occupying = null

const LEDGESTATES = ['ledgegrab','ledgewait']

func _physics_process(delta):
	if occupying == null:
		ledge_collision()
	else:
		if not (occupying.state in LEDGESTATES):
			unoccupy()
	if occupyframes > 0: occupyframes -=1
	
