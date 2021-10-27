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

var controllable = true #false when replay
var motionqueue = "5"
var motiontimer = 8

		#Gameplay


	#Constants
#These basically make the code more readable and make the process of working with state machines slightly quicker.
	#Ground movement
const STAND = 'stand'
const CROUCH = 'crouch'
const CROUCHSTART = 'crouchstart'
const WALK = 'walk'
const WALKBACK = 'walkback'
const DASH = 'dash'
const DASHEND = 'dashend'
const RUN = 'run'
const TURN = 'turn'
const SKID = 'skid'
const BRAKE = 'brake'
const LAND = 'land'
const JUMPSQUAT = 'jumpsquat'
const SHORTHOP = 'shorthop'
const FULLHOP = 'fullhop'

	#Air movement
const AIR = 'air'
const FAIRDASH = 'fairdash'
const BAIRDASH = 'bairdash'
const AIRDODGE = 'airdodge'
const WAVELAND = 'waveland'
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

	#Base attacks
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

const JAB = 'jab'



	#Movement vars




var traction = 80
var postwalktraction = 0 #This might be a fucking stupid idea, but it might make walking more snappy. Unusued
var skidmodifier = 1.0 #applies a modifier to traction during SKID/BRAKE


var walk_accel = 80
var walk_max = 900
var action_range = 80 #analog range for maximum walk acceleration, drifting, dashing and running.

var dashinitial = 1650 #initial burst of speed when you enter DASH. Not analog. 
var dashaccel = 10 #completely digital, also known as Base Acceleration
var dashaccelanalog = 15 #analog accel, also known as Additional Acceleration 
var dashspeed = 1900
var dashframes = 15
var dashendframes = 11 #DASHEND duration
var runjumpmod = 0.9 #A modifier on your momentum when you ground jump.
var runjumpmax = 1800 #A maximum amount of momentum you can transfer from a dash/run into a jump. 

var runspeed = 1900 
var runaccel = 0 #applied after dash momentum 


var drift_accel = 350
var drift_max = 1250
var fall_accel = 120
var fall_max = 1900
var airfriction = 8 #when stick is neutral during drifting, go back to 0,0 with this vel per frame 

var jumpsquat = 3
var shorthopspeed = 1600
var fullhopspeed = 2900
var airjumpspeed = 2700 #this is velocity.y not drifting

var airjump_max = 2 
var airjumps = 0 

var airdodgespeed = 1800
var airdodgestartup = 3 #the frame invuln starts
var airdodgeend = 25


var airdash_max = 1 
var airdashes = 0
var mergeairoptions = false #airdashes will exhaust jumps and jumps will exhaust airdashes if True.
var airdashstyle = "mb" #gg= airdash y momentum will not be cancelled by attacks.
var airdashframes = 0 #variable used for gg airdashes to preserve momentum during aerial_accel. 
var fairdash_startup = 8
var fairdash_end = 20
var fairdash_speed = 1500
var bairdash_startup = 7
var bairdash_end = 10
var bairdash_speed = 1100

var recoverymomentum_current = 500#Momentum value for moves like Mars Side B.
var recoverymomentum_default = 500#_current returns to this value upon landing.
var walljump_count = 0 #Consecutive walljumps lose momentum with each jump. 

var fastfall = false #true if you're fastfalling 
var hardland = 4
var softland = 2 #probably will remain unused for a while. Landing lag for when you're landing normally without fastfalling. 
var landinglag = 4 #changed all the time in states that can land. 


	#State definitions
var rootedstates = [JUMPSQUAT,SHIELD,SHIELDBREAK] #Rooted state. Ground attacks should be this.
var slidestates = [STAND,WALK,DASH,RUN,LAND,TURN,SKID,DASHEND,BRAKE] #Usually ground movement, will slide off when not grounded.
var tractionstates = [STAND,LAND,DASHEND] #Only adds traction
var landingstates = [AIR] #States that will enter LAND when you land on the ground.



	#Pressure vars
var blocking = false #Unused
var extrablockstun = 0 #Don't use


#movement engine, copypasted from Project Tension. If there's something better to use please replace this 
var slope_slide_threshold = 0


	##################
		##INPUTS##
	##################


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


var analogstick = Vector2(0,0)
var analog_deadzone = 24 #should probably be the same as analog_tilt
var analog_tilt = 24 #how much distance you need for the game to consider something a tilt input rather than neutral
var analog_smash = 64 #how much distance the stick has to travel to be considered an u/d/l/r/ or smash input
func analogconvert(floatL,floatR,floatD,floatU):
#Godot returns analog "strength" of actions as a float going from 0 to 1.
#This function converts up/down/left/right inputs into a Vector2() which represents both axes as 256-bit digits.
	var analogX = 0
	var analogY = 0
	if floatL > floatR:
		analogX = 127 - 127*floatL 
	elif floatR > floatL:
		analogX = 127 + 128*floatR
	else: #if digital users input both left and right, go neutral
		analogX = 127
	#same thing for y axis
	if floatD > floatU:
		analogY = 127 - 127*floatD
	elif floatU >= floatD:
		analogY = 127 + 128*floatU
	#return finished calculations
	return Vector2(round(analogX),round(analogY))
func analogdeadzone(stick,zone): #applies a deadzone to a stick value
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
#BTW, as far as I could gather, the distance you need for "smash inputs", which I tested with dashes, is kind of inconsistent in melee.
#To dash left from STAND, you need to travel 63 analog units or more, and to dash right, you need 65 or more. Values 64 and 192 respectively.
#Maybe a mistake was made and the "center" of the analog stick is deemed to be value 126 instead of 127? Definitely possible due to how rushed the game was. 
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
func inputheld(inp,below=900000000,above=0): #button held. pretty simple
	for x in buffer:
		if x[0] == inp:
			if x[1] > above and x[1] <= below:
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
#This includes tech buffering/lockout and SDI.
 
	#Might as well put this here, don't see a reason not to atm
	state_called = []



func state_check(statecompare):#state handler function for checking if the state is correct AND if it's been processed before.
	if state == statecompare:
		if not (state in state_called):
			state_called.append(state) #wip
			return true

		else:
			return false
	else: return false


func refresh_air_options():
	#This function is called when you land on the ground.
	#It will refresh your jumps, airdashes, recovery option momentum (think Mars side B)
	#and any other option it makes sense to refresh at the same time.
	airjumps = 0
	airdashes = 0
	recoverymomentum_current = recoverymomentum_default
	walljump_count = 0



func debug():
#function for testing, please do not use this for legit game logic
	#replay

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
		velocity.x = 4000
	if Input.is_action_just_pressed("d_b"):
		pass


func stand_state():
	if frame == 0:
		refresh_air_options()
	if inputheld(left,3) and not inputheld(up): #might increase below to 3? idk send your feedback
		state(DASH)
		direction= -1
	elif motionqueue[-1] in ["4","7"]: #walk left
		state(WALK)
		direction=- 1
	if inputheld(right,3) and not inputheld(up):
		state(DASH)
		direction= 1
	elif motionqueue[-1] in ["6","9"]: #walk right
		state(WALK)
		direction= 1
	if inputpressed(jump): state(JUMPSQUAT)

func crouch_state():
	pass

func crouchstart_state():
	pass



func action_analogconvert(): #returns how hard you're pressing your stick.x from 0 to 80(action_range)
	if analogstick.x <= 127:
		return min(action_range, 127-analogstick.x)
	if analogstick.x > 127:
		return min(action_range,analogstick.x-127)


func walk_state():#Test, still
	if motionqueue[-1] in ["4","7"]:
		if direction != -1: state(STAND)
	if motionqueue[-1] in ["6","9"]:
		if direction != 1: state(STAND)
	if motionqueue[-1] in ["5","8"]:
		state(STAND) #go to STAND if nothing is held
	if inputheld(down): state(STAND) #should go into crouch.
	if inputpressed(jump): state(JUMPSQUAT)
	if frame <= 1 and not inputheld(up): #UCF
		if inputheld(left,2):
			state(DASH)
			direction = -1
		if inputheld(right,2):
			state(DASH)
			direction = 1
	#acceleration
	if abs(velocity.x) < (walk_max * action_analogconvert()/action_range):
		velocity.x += min(abs(abs(velocity.x) - (walk_max * action_analogconvert()/action_range)),(walk_accel * action_analogconvert()/action_range)) * direction 


#find out how much analog dash influences inputs

func velocity_wmax(acc,maxx,veldir):#add x velocity with a maximum value and an acceleration.
	if veldir == 1: #Meant to not override existing velocity such as from hitstun.
		return min(veldir*maxx,velocity.x + acc)
	if veldir == -1:
		return max(veldir*maxx,velocity.x-acc)


#left
#		velocity.x = round( max(-1 * drift_max*action_analogconvert()/action_range,velocity.x-drift_accel*action_analogconvert()/action_range))
#	if motionqueue[-1] in ['6','9','3']: #if drifting right
#		velocity.x = round( min(maxx,velocity.x+acc))




func dash_state():

	if frame > dashframes:
		if not (inputheld(left) or inputheld(right)):
			state(DASHEND)
		else: state(RUN)

	if frame <= dashframes:
		if inputpressed(left) and direction == 1:
			direction = -1
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), -1) #abs(velocity.x) makes sure you don't just get a free boost the other direction in STAND 
			state(TURN)
		if inputpressed(right) and direction == -1:
			direction = 1
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), 1)
			state(TURN)


	if inputpressed(jump): #btw jump checks should be done as late as possible
		state(JUMPSQUAT) #because successful input buffer checks will erase the input for further jump checks and make it unbufferable
	if frame == 1: #yes initial dash is applied on the second frame
		velocity.x = velocity_wmax(dashinitial,dashspeed, direction)
	if frame >=1:
		if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
			if not (motionqueue[-1] in ['5','8','2']):
				velocity.x = velocity_wmax(dashaccelanalog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			elif frame > 1: apply_traction()
		elif frame > 1: apply_traction()


func dashend_state():
	if inputheld(left):
		if direction == 1:
			direction = -1
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), -1)
			state(TURN)
		else: state(RUN)
	if inputheld(right):
		if direction == -1:
			direction = 1
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), 1)
			state(TURN)
		else: state(RUN)
	if frame == dashendframes:
		state(STAND)
	if inputpressed(jump): state(JUMPSQUAT) 



func run_state():
	#momentum only applies if you're holding left/right
	if direction == 1:
		if inputheld(left):
			flip()
			state(SKID)
		elif inputheld(right):
			if abs(velocity.x) < dashspeed:
				if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
					velocity.x = velocity_wmax(dashaccelanalog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			else:
				velocity.x = velocity_wmax(runaccel,runspeed,direction) #as you can see I didn't put much effort into run specific acceleration
		else: #if nothing held
			state(BRAKE)
	if direction == -1:
		if inputheld(right):
			flip()
			state(SKID)
		elif inputheld(left):
			if abs(velocity.x) < dashspeed:
				if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
					velocity.x = velocity_wmax(dashaccelanalog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			else:
				velocity.x = velocity_wmax(runaccel,runspeed,direction)
		else:
			state(BRAKE)



	if inputpressed(jump): state(JUMPSQUAT)







func skid_state():
	if frame >= 1 and inputpressed(jump): state(JUMPSQUAT) #makes RAR momentum consistent
	if frame >=2: apply_traction(skidmodifier)
	if frame == 20:
			state(STAND)

func brake_state():
	if frame >=2: apply_traction(skidmodifier)
	if frame == 20:
			state(STAND)
	if inputpressed(left):
		if direction == -1:
			velocity.x = velocity_wmax(dashinitial,dashspeed, direction) #get a dashinitial boost when reentering RUN. Oughta be fun
			state(RUN)
		else:
			direction = -1
			state(SKID,frame) #frame thing is so that SKID endlag doesn't reset
	if inputpressed(right):
		if direction == 1:
			velocity.x = velocity_wmax(dashinitial,dashspeed, direction) 
			state(RUN)
		else:
			direction = 1
			state(SKID,frame)
	if inputpressed(jump): state(JUMPSQUAT)


func turn_state():
	if frame == 1:
		if inputheld(left):
			direction = -1
			state(DASH)
		elif inputheld(right):
			direction = 1
			state(DASH)
		else:
			state(STAND)
	if frame > 1: #I dunno what to do here exactly, I do not want to recreate the slow turn from Smash
		apply_traction()
	if frame == 15: #random number idc
		state(STAND)


func air_state():
	aerial_acceleration()
	if inputpressed(jump) and airjumps < airjump_max:
		doublejump()
	if inputpressed(dodge): state(AIRDODGE)
	if motionqueue[-1] in ['5','8','2']: #if not drifting
		if frame > 2: air_friction()
		#I honestly don't like air friction as a mechanic but there's no reason not to include it for how simple it is
	

func air_friction():
	if abs(velocity.x) - airfriction < 0:
		velocity.x = 0
	else:
		if velocity.x > 0:
			velocity.x-=airfriction
		else:
			velocity.x+=airfriction

func doublejump():
	velocity.y = -1 * airjumpspeed
	airjumps+=1
	#play animation

func jumpsquat_state():
	if frame == jumpsquat:
		velocity.x = velocity.x * runjumpmod #modifier
		if abs(velocity.x) > runjumpmax: velocity.x = runjumpmax * direction #maxifier
		if inputheld(jump): #fullhop
			velocity.y-= fullhopspeed
			state(AIR)
		if not inputheld(jump): #shorthop
			velocity.y-=shorthopspeed
			state(AIR)

func land_state():
	if frame == 0:
		refresh_air_options()
	if frame == landinglag:
		if inputheld(down): state(STAND) #switch to crouch
		else: state(STAND)

func fairdash_state():
	pass

func bairdash_state():
	pass

func airdodge_state():
	if frame==2:
		velocity = (analogstick-Vector2(127,127)).normalized() * Vector2(1,-1) * airdodgespeed #the Vector2(1,-1) is there because otherwise the y axis is flipped
		velocity.x = round(velocity.x)
		velocity.y = round(velocity.y) #because round() refuses to work properly with vector2
	if frame == 20:
		if is_on_floor(): state(STAND)
		else: state(AIR)


func waveland_state():
	if frame == 9:
		pass
	


func state_handler():
	if state_check(STAND): stand_state()
	if state_check(CROUCH): crouch_state()
	if state_check(CROUCHSTART): crouchstart_state()
	if state_check(WALK): walk_state()
	if state_check(RUN): run_state()
	if state_check(DASH): dash_state()
	if state_check(DASHEND): dashend_state()
	if state_check(SKID): skid_state()
	if state_check(BRAKE): brake_state()
	if state_check(TURN): turn_state()
	if state_check(JUMPSQUAT): jumpsquat_state()
	if state_check(AIR): air_state()
	if state_check(LAND): land_state()
	if state_check(FAIRDASH): fairdash_state()
	if state_check(AIRDODGE): airdodge_state()
	if state_check(WAVELAND): waveland_state()

func enable_platform(): #enables platform collision
	self.set_collision_mask_bit(2,true)
func disable_platform(): #disables platform collision
	self.set_collision_mask_bit(2,false)

func aerial_acceleration(drift=drift_accel,ff=true):
	#drift lets you set custom drift potential to use for specials.
	#ff=false will disallow fastfalling.
	if motionqueue[-1] in ['4','7','1']: #if drifting left
		if velocity.x > -1*drift_max: #so that drifting wouldn't cancel out existing run momentum
			velocity.x = round( max(-1 * drift_max*action_analogconvert()/action_range,velocity.x-drift_accel*action_analogconvert()/action_range))
	if motionqueue[-1] in ['6','9','3']: #if drifting right
		if velocity.x < drift_max:
			velocity.x = round( min(drift_max*action_analogconvert()/action_range,velocity.x+drift_accel*action_analogconvert()/action_range))

	#falling
	apply_gravity()

var rooted = false #if true, then check for pECB collision 
func apply_traction(mod=1.0): #mod = modifier for traction.
	if abs(velocity.x) - traction*mod < 0:
		velocity.x = 0
	else:
		if velocity.x > 0:
			velocity.x-=traction * mod
		else:
			velocity.x+=traction * mod 

func apply_gravity(): #this is called in ground states as well to prevent bugs regarding collision not working if you don't have a
#downward vector at all times.
#I'll go with that solution for floor collision for now, but I'm sure as hell open to other collision systems 
	velocity.y += fall_accel
	if velocity.y > fall_max:
		velocity.y = fall_max




func check_landing():
#Character scripts could either overwrite landingstates on _ready with every default state and their own or just .append() to it.
	if is_on_floor() and frame > 0:
		state(LAND)
		refresh_air_options()


#Unused funcs have fun with these
func ecb_up(): #returns the scene position of the top point of your pECB.
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[0]
func ecb_down(): #returns the scene position of the lower point of your pECB. 
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[2]
func ecb_left(): #left point. Note that this is right-facing, so the left point will become the rightmost point when direction == -1
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[1]
func ecb_right(): #right point. same directional concern as ecb_left()
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[3]

func actionablelogic(): #a function I made to make ordering stuff that doesn't happen during impactstop easier
	#direction updates. Sprite happens at the end
	$ECB.scale.x = direction
	$Hurtbox.scale.x = direction
	$pECB.scale.x = direction
	state_handler()
	char_state_handler()
	if state in rootedstates:
		apply_gravity()
		rooted = true
	if state in tractionstates:
		apply_traction()
	if state in slidestates:
		apply_gravity()
		if not is_on_floor():
			velocity.x = drift_max * direction
			state(AIR)
	if state in landingstates:
		check_landing()

	collision_handler()


func char_state_handler(): #Replace this in character script to have character specific states
	pass 

var collisions = []
var in_platform = true #will trigger dfghjduhpfsdlnjk;hblhnjk;sdfgb;luhjkfsdg
func collision_handler(): #For platform/floor/wall collision.
	#But first, velocity memes. Get your wok piping hot, then swirl a neutral tasting oil arou
	#var angle = 0 #I don't know what this does 
	#var slope_factor = Vector2(cos(deg2rad(angle))*velocity.x - sin(deg2rad(angle))*velocity.y, sin(deg2rad(angle))*velocity.x + cos(deg2rad(angle))*velocity.y ) 
	#move_and_slide(slope_factor,Vector2(0,1),50)
	$pECB.position = $ECB.position + velocity/60 #projected ECB pos calculation
	velocity = move_and_slide(velocity, Vector2(0, -1))
	#var collision = move_and_collide(velocity)
	#if collision: velocity = velocity.slide(collision.normal)


#	for i in get_slide_count(): #not used
#		collisions.append(get_slide_collision(i)) #not used
	if velocity.y < 0: disable_platform()
	for i in $pECB.get_overlapping_bodies():
# ^^^^ this returns the objects your projected ECB is touching. Essentially, "this will be collided with on the next frame".
#Only returns objects that pECB touches, but ECB doesn't. Also doesn't return the ECB itself. Why? I have absolutely no clue.
#This works out so far, but it needs to be replaced with a signal system so you could return the objects you're colliding w at any time. 
		if in_platform == false:
			if velocity.y >= 0:
				enable_platform()
	if $pECB.get_overlapping_bodies() == []:
		in_platform = false
	else: in_platform = true
	if inputheld(down):
		disable_platform() #once state machine is back make this freefall and air only? 

	rooted = false
#	collisions = [] #not used rn 

func _ready():
	replayprep()
	$pECB.position = $ECB.position
	$pECB.scale = $ECB.scale
	#should make pECB copy the collision of ECB at startup as well


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
#set analog values
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
