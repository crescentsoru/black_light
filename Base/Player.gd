extends KinematicBody2D
#https://www.youtube.com/watch?v=KikLLLeyVOk
var charactername = 'pass'
var characterdescription = 'my jambo jet flies cheerfully'

var state = 'stand'
var state_previous = '' #for logic like "cant buffer this during x state"
var state_called = [] #to fix function ordering memes
var frame = 0
var velocity = Vector2(0,0)
var direction = -1 #   -1 is left; 1 is right
var impactstop = 0 #hitstop and blockstop. Also known as hitlag. 
var impactstop_trigger = false #necessary to allow for 1f impactstops.

				#Inputs
#Buttons
#All the values here should be erased by initialization anyways once that's implemented
var up = 'p1_up'
var down = 'p1_down'
var left = 'p1_left'
var right = 'p1_right'
var jump = 'p1_jump'
var attack = 'p1_attack'
var special = 'p1_special'
var ex = 'p1_ex'
var dodge = 'p1_dodge'
var grab = 'p1_grab'
var cstickup = ''
var cstickdown = ''
var cstickleft = ''
var cstickright = ''
var uptaunt = ''
var sidetaunt = ''
var downtaunt = ''


var controllable = true #will probably remove this
var motionqueue = "5"
var motiontimer = 8
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
[attack,0,9000,9000],
[special,0,9000,9000],
[ex,0,9000,9000],
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
var releasebuffer = 4 #aka negative edge

#After inputs come into the engine, EVERY input should be checked by using the data in the buffer variable,
#or functions/vars that get their data on inputs from buffer, like motionqueue. 
#buffer itself gets input data from base_inputheld(), which uses either player inputs,
#or recorded input data from replays, or potentially netcode(I am quite uninformed on netcode, though). 
#To get inputs for the state machine and such, use the following functions that use buffer var:
#	inputheld() is self_explanatory.
#	inputpressed() checks for a pressbuffer.
#	inputreleased() has its own buffer, basically negative edge
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
	attack : [],
	special : [],
	ex : [],
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
#[up,down,left,right,jump,attack,special,ex,dodge,grab,cstickup,cstickdown,cstickleft,cstickright,uptaunt,sidetaunt,downtaunt]

		#Gameplay


	#Constants
#These basically make the code more readable and make the process of working with state machines slightly quicker.
	#Ground movement
const STAND = 'stand'
const WALK = 'walk'
const WALKBACK = 'walkback'
const DASH = 'dash'
const RUN = 'run'
const CROUCH = 'crouch'
const LAND = 'land'
const JUMPSQUAT = 'jumpsquat'
const SHORTHOP = 'shorthop'
const FULLHOP = 'fullhop'
const SKID = 'skid'
	#Air movement
const AIR = 'air'
const F_AIRDASH = 'f_airdash'
const B_AIRDASH = 'b_airdash'
const AIRDODGE = 'airdodge'
const FREEFALL = 'freefall'
const WALLJUMP_L = 'walljump_l'
const WALLJUMP_R = 'walljump_r'
	#Pressure
const SHIELD = 'shield'
const SHIELDRELEASE = 'shieldrelease'
const SHIELDBREAK = 'shieldbreak'
const BLOCKSTUN = 'blockstun'

const HITSTUN = 'hitstun'
const TUMBLE = 'tumble'
const LANDSTUN = 'landstun' #this is the 4f air-to-ground transition that ASDI down makes use of, which I made into a separate state.
const UKEMISS = 'ukemiss' #ukemi refers to ground teching. Given a different name in code to differentiate from throw teching
const UKEMISTAND = 'ukemistand'
const UKEMIBACK = 'ukemiback'
const UKEMIFORTH = 'ukemiforth'
const HARDKNOCKDOWN = 'hardknockdown'
const SPECIALFALL = 'specialfall'

	#Attacks
const NAIR = 'nair'
const FAIR = 'fair'
const UAIR = 'uair'
const BAIR =  'bair'
const DAIR =  'dair'
const NOVAIR = 'novair' #up-forward aerial
const SEVAIR = 'sevair' #up-backward aerial
const TRIAIR = 'triair' #down-forward aerial
const UNOAIR = 'unoair' #down-backward aerial
const ZAIR = 'zair'

	#Movement vars

var collisions = []

var traction = 200 #unused
var postwalktraction = 0 #This might be a fucking stupid idea, but it might make walking more snappy. Unusued
var skidmodifier = 1 #unused

var walk_accel = 200
var walk_max = 1600
var walk_range = 80 #analog range for maximum walk acceleration. 
var dashspeed = 300 #unused
var runspeed = 800 #unused
var runaccel = 800 #unused
var shorthopspeed = 650 #unused
var fullhopspeed = 1000
var airjumpspeed = 900
var airjump_max = 2 
var airjumps = 0 
var airdash_max = 1 #unused
var airdashes = 0 #unused
var recoverymomentum_current = 500#Momentum value for moves like Mars Side B.
var recoverymomentum_default = 500#_current returns to this value upon landing.
var walljump_count = 0 #Unused. Consecutive walljumps lose momentum with each jump. 

	#Pressure vars
var rooted = false #Will determine if you will slide off into the air with too much velocity on the ground. Unused
var blocking = false #Unused
var extrablockstun = 0 #Don't use







#movement engine, copypasted from Project Tension. If there's something better to use please replace this 
var slope_slide_threshold = 50
var snap = false


var analogstick = Vector2(0,0)
var analog_deadzone = 24 #should probably be the same as analog_tilt
var analog_tilt = 24 #how much distance you need for the game to consider something a tilt input rather than neutral
var analog_smash = 63 #how much distance the stick has to travel to be considered an u/d/l/r/ or smash input

func analogconvert(floatL,floatR,floatD,floatU):
#Godot returns analog "strength" of actions as a float going from 0 to 1.
#This function converts up/down/left/right inputs into a Vector2() which represents both axes as 256-bit digits.
	var analogX = 0
	var analogY = 0
	if floatL >= floatR: #Meant to account for the impossibly stupid situation of "what if two opposite strengths are pressed at the same time"
		analogX = 127 - 127*floatL #Which I am pretty sure can't happen on this stage but w/e
	if floatR > floatL:
		analogX = 127 + 128*floatR
	#same thing for y axis
	if floatD >= floatU:
		analogY = 127 - 127*floatD
	if floatU > floatD:
		analogY = 127 + 128*floatU
	#return finished calculations
	return Vector2(round(analogX),round(analogY))

func analogdeadzone(stick,zone): #applies a deadzone to a stick value
	pass
	if not( stick.x <= 127-zone or stick.x >= 127+zone):
		if not (stick.y <= 127-zone or stick.y >= 127+zone):
			return Vector2(127,127)
	return stick

func base_setanalog(): #sets the analogstick var to 0-255 values every frame w a deadzone
		if controllable:
			analogstick = analogconvert(Input.get_action_strength(left),Input.get_action_strength(right),Input.get_action_strength(down),Input.get_action_strength(up))
			analogstick = analogdeadzone(analogstick,analog_deadzone)
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
					if analogstick != Vector2(127,127):
	#this code will break if there is no deadzone and analog_smash is at a small or 0 value. Please don't do that you have no reason to
						if inp == up:
							if analogstick.y <= 255 and analogstick.y >= 127+analog_smash:
								return true
						if inp == down:
							if analogstick.y >= 0 and analogstick.y <= 127-analog_smash: #might take away the equals at the later check
								return true
						if inp == left:
							if analogstick.x >= 0 and analogstick.x <= 127-analog_smash:
								return true
						if inp == right:
							if analogstick.x <= 255 and analogstick.x >= 127+analog_smash:
								return true
				else: return true
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
func inputheld(inp): #button held. pretty simple
	for x in buffer:
		if x[0] == inp:
			if x[1] > 0:
				return true
			else: return false 

func inputpressed(inp,custombuffer=pressbuffer,prevstate=''): 
	for x in buffer:
		if x[0] == inp:
			if x[2] <= custombuffer:
				if state_previous != prevstate:
					x[2] = custombuffer #can't use the same input to do two different actions.
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
	if global.replaying == true:
		controllable = false
		currentreplay = global.fullreplay

func tiltinput(inp): #returns true if you have an analog input beyond analog_tilt on the control stick, which is 24 by default.
	if inp == up: 
		if analogstick.y <= 255 and analogstick.y > 127+analog_tilt: return true
	if inp == down:
		if analogstick.y >= 0 and analogstick.y < 127-analog_tilt: return true
	if inp == left:
		if analogstick.x >= 0 and analogstick.x < 127-analog_tilt: return true
	if inp == right:
		if analogstick.x <= 255 and analogstick.x > 127+analog_tilt: return true



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

#Backup of the input-only version of motionqueue
#	if inputheld(left) and not inputheld(right):
#		if inputheld(down):
#			motionappend("1")
#		if inputheld(up):
#			motionappend("7")
#		if not inputheld(up) and not inputheld(down):
#			motionappend("4")
#	elif inputheld(right) and not inputheld(left):
#		if inputheld(down):
#			motionappend("3")
#		if inputheld(up):
#			motionappend("9")
#		if not inputheld(up) and not inputheld(down):
#			motionappend("6")
#	elif inputheld(down):
#		motionappend("2")
#	elif inputheld(up):
#		motionappend("8")
#	else: motionappend("5")

func motionappend(number):
	if motionqueue[-1] != number:
		motionqueue = motionqueue + number
		motiontimer = 8



var animexception = [] #this will be useful later for the AIR state 
func state_exception(state_array):
	for each_state in state_array:
		if state == each_state:
			return false
	return true
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
func update_animation(): #default animation handler. 
	if $Sprite.animation != state:
		if state_exception(animexception):
			$Sprite.play(state)
			$AnimationPlayer.play(state)


	$Sprite.scale.x = direction
func flip(): #brevity's sake
	direction = direction * -1


#			if $Sprite.animation in animationoffsets and $Sprite.frame+1 <= len(animationoffsets[$Sprite.animation]):
#				$Sprite.offset = Vector2(animationoffsets[$Sprite.animation][$Sprite.frame][0],animationoffsets[$Sprite.animation][$Sprite.frame][1])

#func updateoffset():
#	if animation in get_parent().animationoffsets and frame+1 <= len(get_parent().animationoffsets[animation]):
#		offset = Vector2(get_parent().animationoffsets[animation][frame][0],get_parent().animationoffsets[animation][frame][1])



func state(newstate,newframe=0): #records the current state in state_previous, changes the state and sets the frame to 0.
	state_previous = state
	state = newstate
	frame = newframe
	state_called.append(newstate) #wip
	state_handler()


func framechange(): #increments the frames, decrements the impactstop timer and stops decrementing frame if impactstop > 0.
	if impactstop == 0: #moved to a separate function for brevity
		frame+=1
		impactstop_trigger = false
	if impactstop > 0:
		impactstop-=1
		if impactstop == 0 and not impactstop_trigger:
			impactstop_trigger = true

func persistentlogic(): #this will contain character functions that happen during impactstop.
	pass  #This includes tech buffering/lockout and SDI. 

	#might as well put this here, don't see a reason not to atm
	state_called = []






func state_check(statecompare):#state handler function for checking if the state is correct AND if it's been processed before.
	if state == statecompare:
		if not (state in state_called):
			return true
		else:
		#	print ("double state function call prevented " + state) #do this later
			return false
	else: return false

func refresh_air_options():
	#This function is called when you land on the ground.
	#It will refresh your jumps, airdashes, recovery option momentum (think Mars side B)
	#and any other option it makes sense to refresh at the same time.
	airjumps = 0
	airdashes = 0
	recoverymomentum_current = recoverymomentum_default

func debug():
#function for testing, please do not use this for legit game logic



	#replay debug
	if Input.is_action_just_pressed("d_load"):
		global.replaying = true
		global.replay_loadfile()
		global.resetgame()
	if Input.is_action_just_pressed("d_save"):
		global.replay_savefile() #will reload then save fullreplay to a JSON file
	if Input.is_action_just_pressed("d_record"):
		global.replaying = false
		global.resetgame() #wipes the replay file
	if Input.is_action_just_pressed("d_play"):
		global.fullreplay = currentreplay
		global.replaying = true
		global.resetgame()
	if Input.is_action_just_pressed("d_a"):
		flip()

func stand_state(): #Test
	velocity.x = 0
	if motionqueue[-1] == "4": #walk left
		state(WALK)
		direction= -1
	if motionqueue[-1] == "6": #walk right
		state(WALK)
		direction= 1
	if inputpressed(attack):
		state('goattack')
	if inputpressed(special,pressbuffer,""): #same as inputpressed without specifying the optional params
		state('gospecial')
	if inputreleased(special,releasebuffer,''): #same as inputreleased without params
		state('gorelease')


func walk_analogconvert(): #logic aid, might put in WALK once I get it straight in me head
	pass
	var leftslack = 127 - walk_range #what the fuck am I doing
	if analogstick.x <= 127:
		return min(walk_range,leftslack + (walk_range -analogstick.x))
	if analogstick.x > 127:
		return min(walk_range,analogstick.x-127)


func walk_state():#Test, still
	if motionqueue[-1] == "4":
		if direction != -1:
			state(STAND)
	if motionqueue[-1] == "6":
		if direction != 1: state(STAND)
	if motionqueue[-1] == "5":
		state(STAND) #go to STAND if nothing is held
	if inputheld(down): state(STAND) #should go into crouch.
	#acceleration
	if abs(velocity.x) < (walk_max * walk_analogconvert()/walk_range):
		velocity.x += min(abs(abs(velocity.x) - (walk_max * walk_analogconvert()/walk_range)),(walk_accel * walk_analogconvert()/walk_range)) * direction 




#enables platform collision
func enable_platform():
	self.set_collision_mask_bit(2,true)
#disables platform collision
func disable_platform():
	self.set_collision_mask_bit(2,false)

func platform_check(): #checks if plat collision is enabled
	return self.get_collision_mask_bit(2)


func testlogic():
#function for testing, everything here will eventually be replaced by something actually good in other functions

#gravity
	velocity.y+=45
	if  not is_on_floor(): if velocity.y > 900: velocity.y = 900

#go through platforms when rising



#limited jumps, refresh air option test
	if is_on_floor(): refresh_air_options()
	if inputpressed(jump):
		if is_on_floor():
			velocity.y-=airjumpspeed
		else:
			if airjumps < airjump_max:
				velocity.y-=airjumpspeed
				airjumps+=1

#state machination
	if state == 'goattack':
		if frame == 5:
			impactstop+=10
		if frame == 18:
			state('stand')
	if state == 'gospecial':
		if frame == 26:
			state('stand')
	if state == 'gorelease':
		if frame == 8:
			state('stand')



func actionablelogic(): #a function I made to make ordering stuff that doesn't happen during impactstop easier
	#direction updates. Sprite happens at the end
	$ECB.scale.x = direction
	$Hurtbox.scale.x = direction
	$pECB.scale.x = direction
	$pECB.position = $ECB.position + velocity/60 #projected ECB pos calculation
	state_handler()
	testlogic() #will be removed eventually
	collision_handler()


func state_handler():
	if state_check(STAND): stand_state()
	if state_check(WALK): walk_state()


func has_collision(namae): #checks the name of any collided object, returns true if it starts with the namae param
	for x in collisions:
		if x.substr(0,len(namae)) == namae:
			return true
		else: return false
func collision_handler(): #For platform/floor/wall collision. Might contain state checks. That's probably fine? 


	#But first, velocity memes. Get your wok piping hot, then swirl a neutral tasting oil arou
	var snap_vector = Vector2(0, 0) if snap && is_on_floor() else Vector2() #this is basically copypasted from Project Tension
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2(0, -1), slope_slide_threshold) #theres probably something better than this
	

	for i in get_slide_count():
		collisions.append(get_slide_collision(i).collider.name)


	if velocity.y < 0:
		disable_platform()
	if inputheld(down): disable_platform()
		

	if has_collision('Platform'): #oh yeah this literally doesn't do anything if the mask is disabled
		print ("colliding w plat!!")
		if (velocity.y >= 0 and not inputheld(down)):
				enable_platform()
	





		#this is deceptively simple, but it's also probably wrong


	
	
	collisions = [] #wipes the collisions so they can be read over the next frame
	
func _ready():
	replayprep()
	$pECB.position = $ECB.position
	$pECB.scale = $ECB.scale
	#should make pECB copy the collision of ECB at startup as well

func _process(delta):
	pass
func _physics_process(delta):
#inputs update
	base_setanalog()
#buffer update
	writebuffer()
#motionqueue update
	motionqueueprocess()
#if blockstop/hitstop > 0: ignore game logic, otherwise decrement hitstop

#game logic.
	debug()
	persistentlogic()

	if impactstop == 0 and not impactstop_trigger:
		actionablelogic()
		update_animation()


#frame+=1. If hitstop > 0, don't increment frame
	framechange()





#physics process order-

#writebuffer()
#motionqueueprocess()
#state machine.			  ignored if impactstop > 0
#update_animations()      ignored if impactstop > 0
#framechange().      	  timer+=1; if hitstop > 0 then don't increment frame and decrement hitstop



	#Heritage For The Future 
#(note down things for the future that might break)

#Impactstop concerns-
#1. Disabling character logic during hitstop might get fucky if the game's expecting a release input.
#most/all things should either expect a buffer release or a not inputheld, but still, this should be something I keep in mind.
#continuing inputs and motionqueue during hitstop is non-negotiable, removing that is not a solution

#2. SDI is easily implementable only for defenders.
#Put the defender into hitstun first, add impactstop based on damage values.
#Add ability to SDI if state == HITSTUN in persistent_logic().


#Analogue update-

#Right now, it is possible to find an analog value where a diagonal motionqueue input and an orthogonal input will
#be spammed quickly for a few frames because the value is at the borders of those inputs and my human finger
#is constantly doing small movements that hop in and out of the border values. 
#This seems like an expected behavior of analog input.
#It feels like something games usually solve, though?
