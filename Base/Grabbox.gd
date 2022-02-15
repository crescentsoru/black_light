extends Area2D


var frame = 0
var collisions = []

var creator = []
var createdstate = ''
var direction = 1
var duration = 5
onready var path = Path2D.new().get_curve()

var grabbingstate = '' #attacker
var grabbedstate = '' #defender 
var groundedness = 0 #0= grabs both aerial and grounded, -1= grabs aerial characters only, 1= grounded chars only 
var hasgrabbed = false #prevents grabbing multiple characters
var grabbedoffset = Vector2(0,0)


func _ready():
	process_priority = 15 #After hitboxes, but before players
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")
func update_path():
	if path.get_point_count() > 0:
		var length_percentage = path.get_baked_length()*(float(frame)/duration)
		position = creator.position + (path.interpolate_baked(length_percentage))






func on_area_enter(area):
	collisions.append(area)
	if area.name.substr(0,7) == 'Hurtbox':
		area.get_parent().process_priority = 89 #Do not change this!!! Fixes the impactstop offset bug, sort of 
		creator.process_priority = 109

func on_area_exit(area):
	if area in collisions: collisions.erase(area)


var handled_characters = [] #for throw clashes I guess? 

func grabbox_collide():
	for x in collisions:
		if x.name == 'Grabbox' and x.creator != creator: 
			for y in collisions:
				if y.name == 'Hurtbox' and y.get_parent() == x.creator:
					throwclash(x) #the grabbox gets clashed, not the creator 
					handled_characters.append(y.get_parent())
			if not (x.creator in handled_characters):

				throwclash(x)
		if x.name == 'Hurtbox' and x.get_parent() != creator: #Change to grabbable hurtbox later 
			if not (x.get_parent() in handled_characters):
				grab_impact(x.get_parent())
	
	
	handled_characters = []






func grab_impact(character):
	if not hasgrabbed:
		if groundedness == 0 or (groundedness == -1 and not character.grounded) or (groundedness == 1 and character.grounded):
			if character.invulns['grab'] == 0 and (not character.state in ['ukemiss','ukemiwait','grabbed','grabbing']): #if the grab is essentially successful:
				if creator.state == 'grabbed' or creator.state == grabbedstate: #if the creator has just been grabbed but the grabbox wasn't destroyed, then two chars grabbed each other at the same time
					creator.state('throwclash')
					character.state('throwclash')
				elif creator.state == 'hitstun': #no grab armor for you fuck you
					pass #pretty sure the fact that hitboxes are processed earlier should make this impossible to happen
					print ('but fuck you anyways')
				else: #actual grab
					grab_success(character)

func grab_success(character):
	#grabbed
	character.interactingcharacter = creator
	character.state(grabbedstate)
	character.framesleft = 76 + round((character.percentage* 1.6) /10 ) #melee formula, no comeback mechanic
	if character.direction == creator.direction: character.flip()
	character.velocity = Vector2(0,0)
	character.position = creator.position + creator.direction * grabbedoffset
	#grabbing
	creator.interactingcharacter = character
	creator.state(grabbingstate)

	hasgrabbed = true




func throwclash(othergrabbox):
	if groundedness == 0 or (groundedness == -1 and not othergrabbox.creator.grounded) or (groundedness == 1 and othergrabbox.creator.grounded):
		if othergrabbox.creator.invulns['grab'] == 0:
			creator.state('throwclash')
			othergrabbox.creator.state('throwclash')



func _physics_process(delta):
	update_path()
	if createdstate != creator.state: queue_free()


	grabbox_collide()

	if creator.impactstop == 0:
		frame+=1
	if frame == duration: queue_free()
