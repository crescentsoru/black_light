extends Area2D


var creator = [] #The owner of the hitbox

var frame = 99

var damage = 3
var kb_base = 10
var kb_growth = 100
var angle = 30
var duration = 10
var id = 0
onready var path = Path2D.new().get_curve()



func _ready(): #happens BEFORE initialization in Player.gd apparently
	connect( "area_entered", self, "on_area_enter")

func update_path():
	if path.get_point_count() > 0:
		var length_percentage = path.get_baked_length()*(float(frame)/duration)
		position = creator.position + (path.interpolate_baked(length_percentage))

var collisions = []
func on_area_enter(area):
	collisions.append(area)

func hitbox_collide():
	for x in collisions:
		if x.name == 'Hitbox' and x.creator != creator: 
			print ("HITBOX COLLISION!! with " + x.name)
		if x.name == 'Hurtbox' and x.get_parent() != creator:
			print ("COLLIDED with " + x.get_parent().name)
			x.get_parent().state('jumpsquat') #test state change

func _physics_process(delta):
	hitbox_collide()
	collisions = []
	if frame > 0: frame-=1
	if frame <= 0: queue_free()
