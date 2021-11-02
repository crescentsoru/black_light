extends Node2D

var inputs = {
	
}
var currentinput = 0





func _process(delta):
	
	if Input.is_action_just_pressed("d_b"):
		get_tree().change_scene("res://Base/Stage/Stage.tscn")
