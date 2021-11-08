extends Area2D


var creator = [] #The owner of the hitbox
var collisions = []

var damage = 3
var kb_base = 10
var kb_growth = 100
var angle = 30
var duration = 10
var id = 0

var frame = 99


func _ready(): #happens BEFORE initialization in Player.gd apparently
	connect( "area_entered", self, "on_area_enter")
#	connect( "area_exited", self, "on_area_exit")
	print ("_ready= " + str(global.gametime) + "      " + str(self.get_overlapping_areas()))


func on_area_enter(area):

	collisions.append(area)
	print ('area enter= ' + str(global.gametime) + area.name + "      " + str(self.get_overlapping_areas()))

func hitbox_collide():
	pass
	
	for x in collisions:
		if x.name == 'Hitbox' and x.creator != creator:
			print ("HITBOX COLLISION!! with ")
		if x.name == 'Hurtbox' and x.get_parent() != creator:
			print ("COLLIDED with " + x.get_parent().name)
	
	
	



func _physics_process(delta):
	hitbox_collide()
	collisions = []
	if frame > 0: frame-=1
	if frame <= 0: queue_free()
