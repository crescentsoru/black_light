extends Node2D

	#Port stuff
var playerindex = 0
var stocks = 99
var ledgegrabs = 0




	##################
		##INPUTS##
	##################





#Buttons
#All the default values here should be overwritten by initialization
var up = ''
var down = 'p1_down' 
var left = ''
var right = ''
var jump = ''
var attackA = '' #the A button
var attackB = '' #AKA special
var attackC = '' 
var attackD = '' #extra attacks will be useful if the engine gets repurposed for 2D fighters
var attackE = ''
var attackF = ''
var dodge = ''
var grab = ''
var cstickup = ''
var cstickdown = ''
var cstickleft = ''
var cstickright = ''
var uptaunt = ''
var sidetaunt = ''
var downtaunt = ''

func initialize_buttons(buttonset):
	up = buttonset[0]
	down = buttonset[1]
	left = buttonset[2]
	right = buttonset[3]
	jump = buttonset[4]
	attackA = buttonset[5]
	attackB = buttonset[6]
	attackC = buttonset[7]
	attackD = buttonset[8]
	attackE = buttonset[9]
	attackF = buttonset[10]
	dodge = buttonset[11]
	grab = buttonset[12]
	cstickup = buttonset[13]
	cstickdown = buttonset[14]
	cstickleft = buttonset[15]
	cstickright = buttonset[16]
	uptaunt = buttonset[17]
	sidetaunt = buttonset[18]
	downtaunt = buttonset[19]
	currentreplay = {
	'analog' : [],
	up : [] ,
	down : [],
	left : [], 
	right : [],
	jump : [],
	attackA : [],
	attackB : [],
	attackC : [],
	attackD : [],
	attackE : [],
	attackF : [],
	dodge : [],
	grab : [],
	cstickup : [],
	cstickdown : [],
	cstickleft : [],
	cstickright : [],
	uptaunt : [],
	sidetaunt : [],
	downtaunt : [],
	
}
	buffer = [
[buttonset[0],0,9000,9000],
[buttonset[1],0,9000,9000],
[buttonset[2],0,9000,9000],
[buttonset[3],0,9000,9000],
[buttonset[4],0,9000,9000],
[buttonset[5],0,9000,9000],
[buttonset[6],0,9000,9000],
[buttonset[7],0,9000,9000],
[buttonset[8],0,9000,9000],
[buttonset[9],0,9000,9000],
[buttonset[10],0,9000,9000],
[buttonset[11],0,9000,9000],
[buttonset[12],0,9000,9000],
[buttonset[13],0,9000,9000],
[buttonset[14],0,9000,9000],
[buttonset[15],0,9000,9000],
[buttonset[16],0,9000,9000],
[buttonset[17],0,9000,9000],
[buttonset[18],0,9000,9000],
[buttonset[19],0,9000,9000],
]



#x[0] = input name
#x[1] = frames the input has been held
#x[2] = frames since this button has been pressed last (standard buffer)
#x[3] = frames since this button has been released
var buffer = [
[up,0,9000,9000],
[down,0,9000,9000],
[left,0,9000,9000],
[right,0,9000,9000],
[jump,0,9000,9000],
[attackA,0,9000,9000],
[attackB,0,9000,9000],
[attackC,0,9000,9000],
[attackD,0,9000,9000],
[attackE,0,9000,9000],
[attackF,0,9000,9000],
[dodge,0,9000,9000],
[grab,0,9000,9000],
[cstickup,0,9000,9000],
[cstickdown,0,9000,9000],
[cstickleft,0,9000,9000],
[cstickright,0,9000,9000],
[uptaunt,0,9000,9000],
[sidetaunt,0,9000,9000],
[downtaunt,0,9000,9000],
]
var pressbuffer = 4
var releasebuffer = 4


#After inputs come into the engine, EVERY input should be checked by using the data in the buffer variable,
#or functions/vars that get their data on inputs from buffer, like motionqueue. 
#buffer itself gets input data from base_inputheld(), which uses either player inputs,
#or recorded input data from replays, or potentially netcode(I am quite uninformed on netcode, though). 
#To get inputs for the state machine and such, use the following functions that use buffer var:
#	inputheld() is self_explanatory.
#	inputpressed() checks for a pressbuffer.
#	inputreleased() has its own buffer
#	inputjustreleased() (no input buffer)
#	inputjustpressed() (checks for an input press, has no input buffer)

#   inputpressed() and inputreleased() have two optional params- custombuffer and prevstate.
#	custombuffer lets you specify a specific frame amount. If you're not sure, then set it to pressbuffer.
#	prevstate lets you ignore the input if the previous state is the same state as the one specified.
var currentreplay = {
	'analog' : [],
	up : [] ,
	down : [],
	left : [], 
	right : [],
	jump : [],
	attackA : [],
	attackB : [],
	attackC : [],
	attackD : [],
	attackE : [],
	attackF : [],
	dodge : [],
	grab : [],
	cstickup : [],
	cstickdown : [],
	cstickleft : [],
	cstickright : [],
	uptaunt : [],
	sidetaunt : [],
	downtaunt : [],
	
}
var controllable = true #false when replay

var analogstick = Vector2(128,128)
var analogstick_prev = Vector2(128,128)
var analog_deadzone = 24 #should probably be the same as analog_tilt
var analog_tilt = 24 #how much distance you need for the game to consider something a tilt input rather than neutral
var analog_smash = 64 #how much distance the stick has to travel to be considered an u/d/l/r/ or smash input
var smashattacksensitivity = 3 #AKA stick sensitivity in Ultimate. That's literally all it does

func analogconvert(floatL,floatR,floatD,floatU):
#Godot returns analog "strength" of actions as a float going from 0 to 1.
#This function converts up/down/left/right inputs into a Vector2() which represents both axes as 256-bit digits.
	var analogX = 0
	var analogY = 0
	if floatL > floatR:
		analogX = 128 - 128*floatL 
	elif floatR > floatL:
		analogX = 128 + 127*floatR
	else: #if digital users input both left and right, go neutral
		analogX = 128
	#same thing for y axis
	if floatD > floatU:
		analogY = 128 - 128*floatD
	elif floatU >= floatD:
		analogY = 128 + 127*floatU
	#return finished calculations
	return Vector2(round(analogX),round(analogY))
func analogdeadzone(stick,zone): #applies a center deadzone to a stick value
	if not( stick.x <= 128-zone or stick.x >= 128+zone):
		if not (stick.y <= 128-zone or stick.y >= 128+zone):
			return Vector2(128,128)
	return stick

func analogdeadzone_axis(stick,zone): #applies an axis deadzone, accurate to Melee
	var resultstick = Vector2(128,128)
	if not( stick.x <= 128-zone or stick.x >= 128+zone):
		resultstick.x = 128
	else: resultstick.x = stick.x
	if not (stick.y <= 128-zone or stick.y >= 128+zone):
		resultstick.y = 128
	else: resultstick.y = stick.y
	return resultstick

func base_setanalog(): #sets the analogstick var to 0-255 values every frame w a deadzone
		analogstick_prev = analogstick #For SDI
		if controllable:
			if left != "": #prevents error spam if a character doesn't have control stick inputs.
				
				analogstick = analogconvert(Input.get_action_strength(left),Input.get_action_strength(right),Input.get_action_strength(down),Input.get_action_strength(up))

			analogstick = analogdeadzone_axis(analogstick,analog_deadzone) #Only really needed for airdodging and DI
			if currentreplay['analog'] == []:
				currentreplay['analog'].append([global.gametime, analogstick.x, analogstick.y])
			else:
				if [currentreplay['analog'][-1][1],currentreplay['analog'][-1][2]] != [analogstick.x,analogstick.y]:
					currentreplay['analog'].append([global.gametime, analogstick.x, analogstick.y])
		else: #if it's a replay
			for x in currentreplay['analog']:
				if x[0] == global.gametime:
					analogstick = Vector2(x[1],x[2])
func base_inputheld(inp):
	if controllable:
		if inp != "": #this line prevents massive lag in interpreter (and possibly exports) when a button isn't set. 
			if Input.is_action_pressed(inp):
				if inp in [up,down,left,right]:
					if analogstick != Vector2(128,128):
	#this code will break if there is no deadzone and analog_smash is at a small or 0 value. Please don't do that you have no reason to
#The center is 128,128 like Melee.
						if inp == up:
							if analogstick.y <= 255 and analogstick.y >= 128+analog_smash:
								return true
						if inp == down:
							if analogstick.y >= 0 and analogstick.y <= 128-analog_smash: #might take away the equals at the later check
								return true
						if inp == left:
							if analogstick.x >= 0 and analogstick.x <= 128-analog_smash:
								return true
						if inp == right:
							if analogstick.x <= 255 and analogstick.x >= 128+analog_smash:
								return true
				elif Input.get_action_strength(inp) >= 0.5: #If you use an analog stick for a button input,
					return true # you need to press it at least halfway like the u/d/l/r inputs above
				else: return false
			else: return false
	else:
		for x in currentreplay:
			if x == inp:
				for n in currentreplay[x]:
					if n[1] > global.gametime and n[0] <= global.gametime:
						return true
func writebuffer():
	for x in buffer:
		x[2]+=1
		x[3]+=1
		if base_inputheld(x[0]) and x[1] == 0:
			x[2]=0
			currentreplay[x[0]].append([global.gametime,0])
		if base_inputheld(x[0]):
			x[1]+=1
		if not base_inputheld(x[0]) and x[1] != 0:
			x[1]=0
			x[3]=0
			if currentreplay[x[0]] != []: currentreplay[x[0]][-1][1] = global.gametime
func inputheld(inp,below=900000000,above=0): #button held. pretty simple
	for x in buffer:
		if x[0] == inp:
			if x[1] > above and x[1] <= below:
				return true
			else: return false
func inputpressed(inp,custombuffer=pressbuffer,prevstate='',erase=true): 
	for x in buffer:
		if x[0] == inp:
			if x[2] <= custombuffer:
				if state_previous != prevstate:
					if erase: x[2] = custombuffer #can't use the same input to do 2 different actions. Please do not change erase if you don't know what you're doing.
					return true 
				else: return false
			else: return false
func inputreleased(inp,custombuffer=releasebuffer,prevstate=''):
	for x in buffer:
		if x[0] == inp:
			if x[3] <= custombuffer:
				if state_previous != prevstate:
					x[3] = custombuffer #can't use the same input to do two different (release) actions.
					return true 
				else: return false
			else: return false
func inputjustpressed(inp): #button pressed this frame, no buffer
	for x in buffer:
		if x[0] == inp:
			if x[2] == 0:
				return true
			else: return false
func inputjustreleased(inp): #button released this frame, no buffer
	for x in buffer:
		if x[0] == inp:
			if x[3] == 0:
				return true
			else: return false
func replayprep(): #called on _ready to make your character controllable or not
	if global.replaying == true and global.fullreplay.has('p_data'): #Will still crash if it has garbage data, but why would it? 
		controllable = false
		if playerindex == 1: currentreplay = global.fullreplay['p_data'][0][4]
		if playerindex == 2: currentreplay = global.fullreplay['p_data'][1][4]
		if playerindex == 3: currentreplay = global.fullreplay['p_data'][2][4]

var motionqueue = "5"
var motiontimer = 8
func tiltinput(inp): #returns true if you have an analog input beyond analog_tilt on the control stick, which is 24 by default.
	if inp == up: 
		if analogstick.y <= 255 and analogstick.y > 128+analog_tilt: return true
	if inp == down:
		if analogstick.y >= 0 and analogstick.y < 128-analog_tilt: return true
	if inp == left:
		if analogstick.x >= 0 and analogstick.x < 128-analog_tilt: return true
	if inp == right:
		if analogstick.x <= 255 and analogstick.x > 128+analog_tilt: return true
func motionqueueprocess():
	motiontimer = motiontimer - 1
	if motiontimer == 0:
		motionqueue = motionqueue[-1]
		motiontimer = 8
	if tiltinput(left) and not tiltinput(right):
		if tiltinput(down):
			motionappend("1")
		if tiltinput(up):
			motionappend("7")
		if not tiltinput(up) and not tiltinput(down):
			motionappend("4")
	elif tiltinput(right) and not tiltinput(left):
		if tiltinput(down):
			motionappend("3")
		if tiltinput(up):
			motionappend("9")
		if not tiltinput(up) and not tiltinput(down):
			motionappend("6")
	elif tiltinput(down):
		motionappend("2")
	elif tiltinput(up):
		motionappend("8")
	else: motionappend("5")
func motionappend(number):
	if motionqueue[-1] != number:
		motionqueue = motionqueue + number
		motiontimer = 8






			########################################
		##########CHILD CHARACTER REFERENCES##############
			########################################

var state_previous := "REFERENCE"



func _ready():
	pass



func _process(delta):
	pass

func _physics_process(delta):
	pass
