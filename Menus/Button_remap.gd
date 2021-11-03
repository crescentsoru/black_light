extends Node2D

var inputs = {
	'p1_up' : [],
	'p1_down' : [],
	'p1_left' : [],
	'p1_right' : [],
	'p1_jump' : [],
	'p1_attackA' : [],
	'p1_attackB' : [],
	'p1_attackC' : [],
	'p1_attackD' : [],
	'p1_attackE' : [],
	'p1_attackF' : [], 
	'p1_dodge' : [],
	'p1_grab' : [],
	'p1_cstickdown' : [],
	'p1_cstickup' : [],
	'p1_cstickleft' : [],
	'p1_cstickright' : [],
	'p1_uptaunt' : [],
	'p1_sidetaunt' : [],
	'p1_downtaunt' : [],
}
var currentinput = 0

var configname = 'soru'




func _input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if event is InputEventJoypadMotion:

		if event.axis_value >= 0.5 or event.axis_value <= -0.5: #prevents drifting from being registered as inputs
			print ('fuck!'+ str(currentinput) + str(event) + "     " + str(event.axis_value))
			remap_action_to(event)

	currentinput += 1



func remap_action_to(event):
	InputMap.action_add_event('p1_jump', event)
	inputs['p1_jump'] = event


func _ready():
	set_process_unhandled_key_input(false) #what does this do? 

func _process(delta):
	if Input.is_action_just_pressed("d_a"):
		get_tree().change_scene("res://Base/Stage/Stage.tscn")
