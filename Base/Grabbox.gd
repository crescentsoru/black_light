extends Area2D


var frame = 0


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



func _physics_process(delta):
	update_path()
	if createdstate != creator.state: queue_free()




	if creator.impactstop == 0:
		frame+=1
	if frame == duration: queue_free()
