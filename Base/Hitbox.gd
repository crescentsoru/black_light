extends Area2D


var creator = [] #The owner of the hitbox
#poly
var damage = 3
var kb_base = 10
var kb_growth = 100
var angle = 30
var duration = 10
var id = 0

var frame = 99


func _ready():
	pass


func _physics_process(delta):
	if frame > 0: frame-=1
	if frame <= 0: queue_free()
	
