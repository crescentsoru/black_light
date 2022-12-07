extends Area2D


func _ready():
	process_priority = 100 #I don't fucking know 
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")



func _process(delta):
	pass
