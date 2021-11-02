extends Node2D

var inputs = {
	
}
var currentinput = 0






func _unhandled_key_input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	remap_action_to(event)


func remap_action_to(event):
	InputMap.action_add_event('p1_jump', event)


func _ready():
	set_process_unhandled_key_input(false)
	
func _process(delta):
	
	if Input.is_action_just_pressed("d_a"):
		get_tree().change_scene("res://Base/Stage/Stage.tscn")
