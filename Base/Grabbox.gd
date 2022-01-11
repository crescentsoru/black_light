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
				print ('grabbox only clash')
				throwclash(x)
				pass #throw clash? This happens when only grabboxes collide w no hurtbox collision, needs testing
		if x.name == 'Hurtbox' and x.get_parent() != creator: #Change to grabbable hurtbox later 
			if not (x.get_parent() in handled_characters):
				if not x.get_parent().state in ['ukemiss','grabbed','grabbing'] or (x.get_parent().invulns['grab'] <= 0):
					grab_impact(x.get_parent())
	
	
	handled_characters = []






func grab_impact(character):
	print ('grab impact')
	

func throwclash(othergrabbox):
#	if groundedness = 0 or (groundedness == -1 and 

	creator.state('throwclash')
	othergrabbox.creator.state('throwclash')



func _physics_process(delta):
	update_path()
	if createdstate != creator.state: queue_free()


	grabbox_collide()

	if creator.impactstop == 0:
		frame+=1
	if frame == duration: queue_free()
