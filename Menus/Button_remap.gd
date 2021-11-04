extends Node2D

var inputs = [
	['p1_up', []],
	['p1_down',[]],
	['p1_left',[]],
	['p1_right',[]],
	['p1_jump',[]],
	['p1_attackA',[]],
	['p1_attackB',[]],
	['p1_attackC',[]],
	['p1_attackD',[]],
	['p1_attackE',[]],
	['p1_attackF',[]], 
	['p1_dodge',[]],
	['p1_grab',[]],
	['p1_cstickdown',[]],
	['p1_cstickup',[]],
	['p1_cstickleft',[]],
	['p1_cstickright',[]],
	['p1_uptaunt',[]],
	['p1_sidetaunt',[]],
	['p1_downtaunt',[]],
	['end',[]]
]
var currentinput = 0
var apeshit = []


var inputstage = 0 #0= first 60 frames, sus out apeshit joysticks. 1= taking inputs 2= inputs done
var configname = 'gamer'


func _ready():
	set_process_unhandled_key_input(false) #what does this do? 
	global.gametime = 0
	$guide.text = "No joystick inputs please! That device's joysticks will be banned."


func add_apeshit(devicenum): #Check if a joystick is going apeshit. If enough inputs from a device happen, that joystick will be ignored. Happens w my Switch Pro. 
	for x in apeshit: #Technically, this kind of check should be ran all the time, with forgiveness checks if the joystick hasn't been doing this for a while
		if x[0] == devicenum: #and it's just a human going ham on a joystick. Unfortunately my brain is broken and I don't want to waste any more time on remaps
			x[1] += 1
			return
	apeshit.append([devicenum,1]) #because of the return above this should only happen if no device was found in apeshit

func ban_apeshit():
	for x in apeshit:
		if x[1] > 2:
			print ("Banned device" + str(x[0]) + "!")
			x[1] = -99

func _input(event):

	if inputstage == 0:
		if event is InputEventJoypadMotion:
			if event.axis_value >= 0.3 or event.axis_value <= -0.3:
				add_apeshit(event.device)
				print (event.axis_value)




	if inputstage == 1:
		if event is InputEventJoypadMotion:
			for x in apeshit:
				if event.device == x[0] and x[1] < 0:
					return #don't do shit
		#all the for loops that start like this make sure that the same input can't get repeated for different actions. Trust me it's NEEDED
			if event.axis_value >= 0.5 or event.axis_value <= -0.5:  #prevents neutral position drifting standard in gamecube controllers to register as an input
				write2inputs(event)
		elif not (event is InputEventMouseMotion):
			write2inputs(event)
	#	print ('input is '+ str(currentinput) + str(event) + "     " + str(event.axis_value) + "   device= " + str(event.device) + "    frametime:" + str(global.gametime))




func write2inputs(event):
	if currentinput > 0: #This entire loop disallows inputs that have already been used. Trust me, it is necessary
		for x in range(currentinput): #won't throw errors
			if inputs[x][1] is InputEventJoypadMotion and event is InputEventJoypadMotion: #I don't know why I'm comparing both but it doesn't crash when I do
				if inputs[x][1].axis == event.axis and inputs[x][1].axis_value*event.axis_value >= 0:
					return
			elif inputs[x][1] is InputEventJoypadButton and event is InputEventJoypadButton:
				if inputs[x][1].button_index == event.button_index:
					return
			elif inputs[x][1] is InputEventKey and event is InputEventKey:
				if inputs[x][1].scancode == event.scancode:
					return
			elif inputs[x][1] is InputEventMouseButton and event is InputEventMouseButton:
				if inputs[x][1].button_index == event.button_index:
					return
			elif inputs[x][1] is InputEventMIDI and event is InputEventMIDI: #I don't give a fuck
				if inputs[x][1].controller_value == event.controller_value: #not even going to bother testing if this works
					return
	inputs[currentinput][1] = event
	currentinput +=1

		
func inputs2maps(): #writes the inputs into input maps
	for x in inputs:
		if x[0] != 'end':
			InputMap.action_erase_events(x[0])
			InputMap.action_add_event(x[0],x[1])
		else:
			return
			
func saveinputstofile(): #does exactly what it says on the tin
	var inputconfig = File.new()
	inputconfig.open('res://Configs/'+configname+'.cfg', File.WRITE)
	inputconfig.store_line(to_json(inputs))
	inputconfig.close()

func loadconfig():
	inputstage = 2
	currentinput = len(inputs) - 1
	global.gametime = 99999
	var loadconfig = File.new()
	if not loadconfig.file_exists('res://Configs/' + configname + '.cfg'): #if no file then break
		return
	loadconfig.open('res://Configs/' + configname + '.cfg', File.READ)
	var file2list = loadconfig
	inputs = parse_json(file2list)
	loadconfig.close()
	$guide.text = 'Loaded config file ' + configname
	print (inputs)

func _process(delta):
	if Input.is_action_just_pressed("d_load"):
		loadconfig()
	if global.gametime == 120:
		inputstage = 1
		ban_apeshit()
	
	if inputstage == 1 and currentinput <= len(inputs):
		$guide.text = 'Input ' +  str(inputs[currentinput][0])
		if inputs[currentinput][0] == 'end':
			inputstage = 2
			$guide.text = 'Button mapping finished'
			print (inputs)
	if inputstage == 2:

		if Input.is_action_just_pressed("d_forward"):
			inputs2maps()
			$guide.text = 'Applied config to inputmap'
		
		if Input.is_action_just_pressed("d_save"):
			saveinputstofile()
			$guide.text = 'Saved to file ' + configname
	if Input.is_action_just_pressed("d_a"):
		global.gametime = 0
		get_tree().change_scene("res://Base/Stage/Stage.tscn")

