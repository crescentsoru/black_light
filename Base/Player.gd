extends KinematicBody2D
#https://www.youtube.com/watch?v=KikLLLeyVOk
var charactercode = '' #the same name as the folder/tscn in Characters/
var charactername = 'pass'
var characterdescription = 'my jambo jet flies cheerfully'
var playerindex = ''
var gamertag = 'thegamer69'
var maincharacter = true #if false, then it's probably a Nana thing
var spawnpoint = Vector2(0,0)

var state = 'stand'
var state_previous = '' #for logic like "cant buffer this during x state"
var state_called = [] #to fix function ordering memes
var frame = 0
var velocity = Vector2(0,0)
var direction = -1 #   -1 is left; 1 is right
var impactstop = 0 #hitstop and blockstop. Also known as hitlag. 


var stocks = 99
var percentage = 0 #Technically it's permillage since it goes down to the decimals


		#Gameplay

	#Constants
#These basically make the code more readable and make the process of working with state machines slightly quicker.
	#Ground movement
const STAND = 'stand'
const CROUCH = 'crouch' #AKA SquatWait
const CROUCHSTART = 'crouchstart' #AKA Squat
const CROUCHEXIT = 'crouchexit' #AKA SquatRV
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
const HITSTUNGROUNDED = 'hitstungrounded'
const ATGHITSTUN = 'atghitstun'  #this is the 4f air-to-ground transition that ASDI down makes use of, which I made into a separate state.
const TUMBLE = 'tumble'

const UKEMISS = 'ukemiss' #ukemi refers to ground teching. Given a different name in code to differentiate from throw teching
const UKEMIATTACK = 'ukemiattack'
const UKEMINEUTRAL = 'ukemineutral'
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
const FTILT = 'ftilt'
const UTILT = 'utilt'
const DTILT = 'dtilt'
const FSMASH = 'fsmash'
const USMASH = 'usmash'
const DSMASH = 'dsmash'


	#Movement vars
var traction = 70
var skidmodifier = 1.0 #applies a modifier to traction during SKID/BRAKE


var walk_accel = 85
var walk_max = 1050
var action_range = 80 #analog range for maximum walk acceleration, drifting, dashing and running. Don't change this
var walk_tractionless = false #if true, won't add traction when your speed exceeds the max walk speed, like when you land from runjumps.

var dashinitial = 1750 #initial burst of speed when you enter DASH. Not analog. 
var dashaccel = 10 #completely digital, also known as Base Acceleration
var dashaccel_analog = 35 #analog accel, also known as Additional Acceleration 
var dashspeed = 2200
var dashframes = 15
var dashendframes = 11 #DASHEND duration
var runjumpmod = 0.9 #A modifier on your momentum when you ground jump.
var runjumpmax = 1900 #A maximum amount of momentum you can transfer from a dash/run into a jump. 

var runspeed = 1900 
var runaccel = 0 #applied after dash momentum 

var driftaccel = 100 #Base drift acceleration
var driftaccel_analog = 200 #Additional drift accel
var drift_max = 1100
var fall_accel = 120
var fall_max = 1900
var fastfall_speed = 2375
var airfriction = 8 #when stick is neutral during drifting, go back to 0,0 with this vel per frame 

var jumpsquat = 3
var shorthopspeed = 1600
var fullhopspeed = 2900
var airjumpspeed = 2700 #this is velocity.y not drifting

var airjump_max = 2 
var airjumps = 0 

var airdodgespeed = 2600 #Please do not change this unless you know what you're doing! Can be used to give characters a speedier wavedash without affecting traction
var airdodgestartup = 3 #the frame invuln starts
var airdodgeduration = 26
var airdodgelandlag = 20 #landing lag for airdodging into the ground after the initial velocity
var airdodges = 0 #incremented when you use an airdodge. One airdodge per jump arc. 

var airdash_max = 1
var airdashes = 0
var mergeairoptions = false #airdashes will exhaust jumps and airdashes won't come out when your jumps are exhausted if True.
var airdashstyle = "mb" #gg= airdash y momentum will not be cancelled by attacks.
var airdashframes = 0 #variable used for gg airdashes to preserve momentum during aerial_accel, but can be used for any other movement that is exclusive to airdash.
var movementmomentum1 = 0 #used in airdodging for saving gravity from being divided by 1.11111, but can be used for any other exclusive movement
var movementmomentum2 = Vector2(0,0) 

var fairdash_speed = 2000 #the momentum
var fairdash_startup = 8 #The point at which you're able to cancel FAIRDASH with attacks. 
var fairdash_end = 20 #when fairdash recovers
var bairdash_speed = 1700
var bairdash_startup = 7 
var bairdash_end = 15 #same stuff for bairdash


var recoverymomentum_current = 500#Momentum value for moves like Mars Side B.
var recoverymomentum_default = 500#_current returns to this value upon landing.
var walljump_count = 0 #Consecutive walljumps lose momentum with each jump. 

var fastfall = false #true if you're fastfalling
var fastfall_instant = false #wacky movement option
var hardland = 4
var softland = 2 #probably will remain unused for a while. Landing lag for when you're landing normally without fastfalling. 
var landinglag = 4 #changed all the time in states that can land. 


	#State definitions
var rootedstates = [SHIELD,SHIELDBREAK,JAB,UKEMINEUTRAL,UKEMIBACK,UKEMIFORTH] #Rooted state. Ground attacks should be this.
var slidestates = [JUMPSQUAT,STAND,CROUCH,CROUCHSTART,CROUCHEXIT,WALK,DASH,RUN,LAND,ATGHITSTUN,TURN,SKID,DASHEND,BRAKE,WAVELAND,UKEMISS,] #Usually ground movement, will slide off when not grounded.
var landingstates = [AIR,FAIRDASH,BAIRDASH,NAIR,UAIR,DAIR,BAIR,FAIR,UNOAIR,TRIAIR,SEVAIR,NOVAIR] #States that will enter LAND when you land on the ground.



	#Pressure vars
var weight = 100

var blocking = false #Unused
var extrablockstun = 0 #Don't use
var hitstunknockback = 0.0 #used on startup in hitstun to save the end frame of hitstun
var hitstunmod = 0.4 #do not
var hitstunknockdown = 'normal' #normal= techroll after tumble, 'okizeme'= enter standup state
var hitstunangle = 0

var invulns = { #There will later be a system with three different hurtboxes each being either grabbable, projectile-able or strikable, but it won't replace this system at all
	'strike':0,
	'projectile':0,
	'grab':0,}
var invulntype = 'intangible'

#ukemi = ground tech. Please do not change these values, there's a reason a certain game made ground tech frame data universal
var ukemineutral_end = 26
var ukemineutral_invuln = 20
var ukemiroll_end = 40
var ukemiroll_invuln = 20




	#etc
var characterscale = 1



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
		if playerindex == "p1": currentreplay = global.fullreplay['p_data'][0][4]
		if playerindex == "p2": currentreplay = global.fullreplay['p_data'][1][4]
		if playerindex == "p3": currentreplay = global.fullreplay['p_data'][2][4]

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

var animexception = [] #this will be useful later for the AIR state 
func state_exception(state_array):
	for each_state in state_array:
		if state == each_state:
			return false
	return true
func update_animation(): #default animation handler. 
	if $Sprite.animation != state:
		if state_exception(animexception):
			$Sprite.play(state)
			$AnimationPlayer.play(state)
	$Sprite.scale.x = direction
func flip(): #brevity's sake
	direction = direction * -1


func state(newstate,newframe=0): #records the current state in state_previous, changes the state and sets the frame to 0.
	state_previous = state
	state = newstate
	frame = newframe
	state_handler()
	char_state_handler()
	attackcode()
	if maincharacter: get_parent().get_parent().update_debug_display(self,playerindex+'_debug')









func persistentlogic(): #contains code that is ran during impactstop.
#This includes tech buffering/lockout, SDI and getting hit. 
	hit_processing()
	ukemi_input()

	
	state_called = []
	currenthits = []
	lasthitbox = []
	if maincharacter: get_parent().get_parent().update_debug_display(self,playerindex+'_debug')









func state_check(statecompare):#state handler function for checking if the state is correct AND if it's been processed before.
	if state == statecompare:
		if not (state in state_called):
			state_called.append(state) #I think this works
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
	airdodges = 0
	fastfall = false
	recoverymomentum_current = recoverymomentum_default
	walljump_count = 0



func debug():
#function for testing, please do not use this for legit game logic
	#replay

	if Input.is_action_just_pressed("d_load"):
		global.replaying = true
		global.replay_loadfile_d()
	if Input.is_action_just_pressed("d_save"):
		global.replay_savefile() #will reload then save fullreplay to a JSON file
	if Input.is_action_just_pressed("d_record"):
		global.replaying = false
		global.resetgame() #wipes the replay file
	if Input.is_action_just_pressed("d_play"):
		if playerindex == "p1": global.p1_data[4] = currentreplay
		if playerindex == "p2": global.p2_data[4] = currentreplay
		if playerindex == "p3": global.p3_data[4] = currentreplay

		global.replaying = true
		global.compilereplay()
		global.resetgame()
	if Input.is_action_just_pressed("d_a"):
		move_and_collide(Vector2(0,5000))
	if Input.is_action_just_released("d_b"):
		get_tree().change_scene("res://Menus/Button_remap.tscn")




func stand_state():
	platform_drop()
	if frame == 0:
		refresh_air_options()
	if inputheld(left,3) and not inputheld(up): #might decrease below to 2? idk send your feedback
		state(DASH)
		direction= -1
	elif tiltinput(left) and not tiltinput(down): #walk left
		state(WALK)
		direction=- 1
	if inputheld(right,3) and not inputheld(up):
		state(DASH)
		direction= 1
	elif tiltinput(right) and not tiltinput(down): #walk right
		state(WALK)
		direction= 1
	if tiltinput(down):
		state(CROUCH) #it might be better to put crouch and crouchstart in animexceptions then manually set the animation to crouchstart so the character doesn't enter crouch instantly
	if inputpressed(jump): state(JUMPSQUAT)
	apply_traction()

func crouchstart_state(): #AKA Squat
	platform_drop()
	if frame == 8:
		state(CROUCH)
	if inputpressed(jump): state(JUMPSQUAT)

func crouch_state(): #AKA SquatWait
	platform_drop()
	if inputpressed(left):
		if direction == 1:
			flip()
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), -1)
			state(TURN)
		else: state(DASH)
	if inputpressed(right): #Honestly, because this input is bufferable(and SHOULD BE) I may consider nerfing dashing out of crouch
		if direction == -1:
			flip()
			velocity.x = velocity_wmax(dashinitial,abs(velocity.x), 1) #But I might be making dash too good with this line
			state(TURN)
		else: state(DASH)
	if not tiltinput(down): #makes sure you can hold down without also dropping from a platform
		state(CROUCHEXIT)
	if inputpressed(jump) and grounded: state(JUMPSQUAT)
	apply_traction2x()


func crouchexit_state(): #AKA SquatRV
	if frame == 10:
		state(STAND)
	if inputpressed(jump): state(JUMPSQUAT)
	if inputheld(down): state(CROUCH)
	apply_traction2x()

func action_analogconvert(): #returns how hard you're pressing your stick.x from 0 to 80(action_range)
	if analogstick.x <= 128:
		return min(action_range, 128-analogstick.x)
	if analogstick.x > 128:
		return min(action_range,analogstick.x-128)

func walk_state():
	if tiltinput(left):
		if direction != -1:state(STAND)
	if tiltinput(right):
		if direction != 1: state(STAND)
	if motionqueue[-1] in ["5","8"]:
		state(STAND) #go to STAND if nothing is held
	if inputheld(down) and not (inputheld(right) or inputheld(left)):
		state(CROUCH)
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
	elif abs(velocity.x) > walk_max and not walk_tractionless:
			apply_traction() #RIP 
func velocity_wmax(acc,maxx,veldir):#add x velocity with a maximum value and an acceleration.
	if veldir == 1: #Meant to not override existing velocity such as from hitstun.
		return min(veldir*maxx,velocity.x + acc)
	if veldir == -1:
		return max(veldir*maxx,velocity.x-acc)

func dash_state():
	platform_drop()
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
		if (direction==1 and velocity.x <=dashinitial): #Makes sure you can't cancel momentum by dashing in its direction
			velocity.x = velocity_wmax(dashinitial,dashspeed, direction)
		if direction==-1 and velocity.x >= dashinitial*-1:
			velocity.x = velocity_wmax(dashinitial,dashspeed, direction)
	if frame >=1:
		if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
			if not (motionqueue[-1] in ['5','8','2']):
				velocity.x = velocity_wmax(dashaccel_analog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			elif frame > 1: apply_traction()
		else: apply_traction()

func dashend_state():
	platform_drop()
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
	apply_traction()


func run_state():
	platform_drop()
	#momentum only applies if you're holding left/right
	if direction == 1:
		if inputheld(down) and not (inputheld(right) or inputheld(left)):
			state(CROUCHSTART)
		if inputheld(left):
			flip()
			state(SKID)
		elif inputheld(right):
			if abs(velocity.x) <= dashspeed:
				if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
					velocity.x = velocity_wmax(dashaccel_analog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			else:
				velocity.x = velocity_wmax(runaccel,runspeed,direction) #as you can see I didn't put much effort into run specific acceleration
		else: #if nothing held
			state(BRAKE)
	if direction == -1:
		if inputheld(right):
			flip()
			state(SKID)
		elif inputheld(left):
			if abs(velocity.x) <= dashspeed:
				if abs(velocity.x) <= (dashinitial+(dashspeed-dashinitial)*action_analogconvert()/action_range):
					velocity.x = velocity_wmax(dashaccel_analog*action_analogconvert()/action_range + dashaccel,dashinitial+ (dashspeed-dashinitial)*action_analogconvert()/action_range,direction)
			else:
				velocity.x = velocity_wmax(runaccel,runspeed,direction)
		else:
			state(BRAKE)
	if inputpressed(jump): state(JUMPSQUAT)

func skid_state():
	platform_drop()
	if frame >= 1 and inputpressed(jump): state(JUMPSQUAT) #makes RAR momentum consistent
	if frame >=2: apply_traction(skidmodifier)
	if frame == 20:
			state(STAND)
func brake_state():
	platform_drop()
	if inputheld(down) and not (inputheld(right) or inputheld(left)):
		state(CROUCHSTART)
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
	platform_drop()
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
	if inputpressed(dodge,pressbuffer,"",false):
		var stickangle = (rad2deg(atan2(((analogstick-Vector2(128,128)).normalized() ).y, ((analogstick-Vector2(128,128)).normalized()).x)))
		if analogstick == Vector2(128,128):
			if airdodges < 1: state(AIRDODGE) #I could make 5R a shortcut for forward airdash instead. Let me know if that's something you want
		elif stickangle < 28 and stickangle > -16: #the angle is arbitrary, roughly based on Melee's pure left/right airdodge angle zone.
			if frame != 0: #so you don't get super low to the ground airdashes or orthogonal wavelands.
				if airdashes < airdash_max and ((mergeairoptions and airjumps<airjump_max) or not mergeairoptions):
						if direction == 1: state(FAIRDASH)
						else: state(BAIRDASH)
				elif airdodges < 1: state(AIRDODGE)
		elif stickangle < -164 or stickangle > 152:
			if frame !=0:
				if airdashes < airdash_max and ((mergeairoptions and airjumps<airjump_max) or not mergeairoptions):
					if direction == -1: state(FAIRDASH)
					else: state(BAIRDASH)
				elif airdodges < 1: state(AIRDODGE)
		elif airdodges < 1: state(AIRDODGE)
	if motionqueue[-1] in ['5','8','2']: #if not drifting
		if frame > 1: air_friction()
		#I honestly don't like air friction as a mechanic but there's no reason not to include it for how simple it is
	if inputpressed(down) and !fastfall and velocity.y >= 0:
		fastfall = true
		velocity.y = fastfall_speed
	if not grounded:
		if velocity.y < fall_max: landinglag = softland #AKA NIL
		else: landinglag = hardland

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
		velocity.y = 0 #needs to be done under the new move_and_collide system
		velocity.x = velocity.x * runjumpmod #modifier
		if abs(velocity.x) > runjumpmax: velocity.x = runjumpmax * direction #maxifier
		if inputheld(jump): #fullhop
			velocity.y-= fullhopspeed
			state(AIR)
		if not inputheld(jump): #shorthop
			velocity.y-=shorthopspeed
			state(AIR)
	apply_traction2x()
func land_state():
	if frame == 0:
		refresh_air_options()
	if frame == landinglag:
		if inputheld(down): state(CROUCH) #looks better
		else: state(STAND)
	apply_traction2x()

func airdashstart(): #just a shorthand
	airdashes+=1
	if mergeairoptions: airjumps+=1
	velocity.y = 0
	velocity.x = 0 #kinda problematic but not resetting vel.x means it feels bad to use airdashes in normal movement outside of getting hit with a bunch of knockback
	#hopefully the fact that up-b's won't be usable if you exhaust all air options even if you get hit will compensate for airdash's ability to cancel velocity
func airoptions_exhausted(): #Will be useful later to disallow recovery moves if both airdash and double jump have been used in a given jump arc.
#Allowing people to double jump, airdash AND up-B will trivialize recovering which will make edgeguards much more difficult or impossible.
#Using this function, you can disallow recovery moves like Up-B if both airdash and airjump have been used in the current jump arc.
	if mergeairoptions:
		if airjumps == airjump_max:
			return true
		else: return false
	else:
		if airjumps == airjump_max and airdashes == airdash_max:
			return true
		else: return false

func fairdash_state():
	if frame == 0:
		airdashstart()
		if airdashstyle == 'gg': airdashframes = fairdash_end #UNTESTED, will test when aerial attacks become a thing
		if direction == 1 and velocity.x <= fairdash_speed:
			velocity.x = velocity_wmax(fairdash_speed,fairdash_speed,1)
		if direction == -1 and velocity.x >= fairdash_speed * -1:
			velocity.x = velocity_wmax(fairdash_speed,fairdash_speed,-1)
	airdashframes-=1
	disable_platform()
	if frame == fairdash_end:
		state(AIR)

func bairdash_state():
	if frame == 0:
		airdashstart()
		if airdashstyle == 'gg': airdashframes = bairdash_end
		if direction == 1 and velocity.x >= bairdash_speed*-1:
			velocity.x = velocity_wmax(bairdash_speed,bairdash_speed,-1)
		if direction == -1 and velocity.x <= bairdash_speed:
			velocity.x = velocity_wmax(bairdash_speed,bairdash_speed,1)
	airdashframes-=1
	disable_platform()
	if frame == bairdash_end:
		state(AIR)

func send_airdodge(): #shorthand for the airdodge state so I can repeat the same code for the first frame
	var stickangle = (rad2deg(atan2(((analogstick-Vector2(128,128)).normalized() ).y, ((analogstick-Vector2(128,128)).normalized()).x)))
	if analogstick == Vector2(128,128): #Neutral airdodge. The one place in the game, probably, where the deadzone code I made actually matters
		velocity = Vector2(0,0)
	elif stickangle < 28 and stickangle > -16: #pure left/right vectors when you're within 16 angles of the x axis, plus upwards prune
		velocity = (Vector2(255,128)-Vector2(128,128)).normalized() * Vector2(1,-1) * airdodgespeed
	elif stickangle < -164 or stickangle > 152: #right airdodge
		velocity = (Vector2(0,128)-Vector2(128,128)).normalized() * Vector2(1,-1) * airdodgespeed
	elif stickangle < 106 and stickangle > 74: #upwards airdodge
		velocity = (Vector2(128,255)-Vector2(128,128)).normalized() * Vector2(1,-1) * airdodgespeed
	elif stickangle > -106 and stickangle < -74:
		velocity = (Vector2(128,0)-Vector2(128,128)).normalized() * Vector2(1,-1) * airdodgespeed
	else: velocity = (analogstick-Vector2(128,128)).normalized() * Vector2(1,-1) * airdodgespeed #the Vector2(1,-1) is there because otherwise the y axis is flipped
	velocity.x = round(velocity.x)
	velocity.y = round(velocity.y) #because round() refuses to work properly with vector2
	movementmomentum2 = velocity
	movementmomentum1 = 0

func airdodge_state():
	if frame==0:
		airdodges+=1
		velocity = Vector2(0,0) #reset velocity before applying airdodge 
		send_airdodge()
	if frame==1:
		if velocity == Vector2(0,0): #if the first frame was a neutral airdodge,
			send_airdodge() #then the player is allowed to correct it if it was a mistake and input a different angle
	if frame >= 30: #adds gravity after some point
		movementmomentum1 += fall_accel
		if movementmomentum1 > fall_max:
			movementmomentum1 = fall_max
	if frame > 0 and frame < 37:
		movementmomentum2 = movementmomentum2 / 1.11111 #slows the airdodge down as it goes
		velocity = movementmomentum2 + Vector2(0,movementmomentum1) #adds the accumulated gravity
	if frame == 37: #destroy airdodge momentum since it's basically at 0 anyways, and stop using the movementmomentum vars
		velocity.y = movementmomentum1
		landinglag = airdodgelandlag
		movementmomentum1 = 0
		movementmomentum2 = Vector2(0,0)
	if frame > 37:
		aerial_acceleration()
	if grounded:
		if frame < 37:
			state(WAVELAND)
		else:
			state(LAND)
	if frame == airdodgestartup: 
		fullinvuln(airdodgeduration)
		
	if frame == 100: state(AIR)
	#invuln

func waveland_state():
	apply_traction()
	refresh_air_options()
	if frame == 10:
		state(STAND)

func hitstungrounded_state():
	if frame == 1:
		velocity.x = cos(deg2rad(hitstunangle))*hitstunknockback*20
		velocity.y = sin(deg2rad(hitstunangle*-1))*hitstunknockback*20
	if frame >= 1:
		velocity.y += fall_accel
		if !grounded: state(AIR)
	if frame == int(hitstunknockback*hitstunmod):  #is it int or round?
		print (str(hitstunknockback) + " knockback units  " + str(hitstunangle) + " degrees")
		if grounded: state(STAND)
		else: state(AIR)
	apply_traction()

func hitstun_state():
	if frame == 1:
		if grounded and hitstunknockback >= 80: #the only way you could be grounded and have tumble KB is if you're hit with a downward angle
			velocity.x = cos(deg2rad(hitstunangle))*hitstunknockback*20 / 1.2 #1.2 is the bounce multiplier
			velocity.y = sin(deg2rad(hitstunangle*-1))*hitstunknockback*20 / 1.2
		else:
			velocity.x = cos(deg2rad(hitstunangle))*hitstunknockback*20 #the 20 is arbitrary
			velocity.y = sin(deg2rad(hitstunangle*-1))*hitstunknockback*20
	if frame >= 1: #does gravity get applied on frame == 1 or frame == 2?
		velocity.y += fall_accel
	if grounded and frame > 1:
		if hitstunknockback < 80:
			state(ATGHITSTUN) #air to ground transition, the thing that makes ASDI down good
		else: #ukemi
			ukemi_check()
		
	if frame == int(hitstunknockback*hitstunmod):  #is it int or round?
		print (str(hitstunknockback) + " knockback units  " + str(hitstunangle) + " degrees")
		if hitstunknockback >= 80:
			state(TUMBLE)
		else:
			if grounded: state(STAND)
			else: state(AIR)

func atghitstun_state(): #in melee, characters go to the landing state instead of this. I made it into a separate state
						#so designers could make anti-ASDIdown moves without changing the angle of the move.
	if frame == 0:
		refresh_air_options()
	if frame == 4:
		if inputheld(down): state(CROUCH) #looks better
		else: state(STAND)
	apply_traction2x()

func ukemi_check(): #switches state to different techs depending on your input
	if ukemi_ok():
		if inputheld(left): state(UKEMIBACK)
		elif inputheld(right): state(UKEMIFORTH)
		else: state(UKEMINEUTRAL)
	else: state(UKEMISS)

var ukemi_buffer = 40
func ukemi_input():
	print (str(ukemi_buffer) + "   " + str(global.gametime) + "  " + str(playerindex))
	if ukemi_buffer < 40: ukemi_buffer+=1
	if inputjustpressed(dodge):
		if ukemi_buffer == 40:
			ukemi_buffer = 0

func ukemi_ok():

	if ukemi_buffer < 20: return true
	else: return false

func tumble_state(): #test
	if inputpressed(jump): doublejump()
	#inputs
	
	if grounded: ukemi_check()
	aerial_acceleration()


func ukemiss_state():
	if frame == 50: state(STAND)
#as far as I understand, the traction during missed tech is universal at 0.051, which is why I copy the traction code here
	if abs(velocity.x) - 50 < 0:
		velocity.x = 0
	else:
		if velocity.x > 0:
			velocity.x-=50
		else:
			velocity.x+=50

func ukemiattack_state():
	if frame == 400: #i'll work on this later 
		state(STAND)

func ukemineutral_state():
	if frame == 0:
		fullinvuln(ukemineutral_invuln)
	if frame == ukemineutral_end:
		state(STAND)

func ukemiback_state():
	if frame == 0:
		fullinvuln(ukemiroll_invuln)
		velocity.x -= 500
	if frame == ukemiroll_end:
		velocity.x += 500
		state(STAND)

func ukemiforth_state():
	if frame == 0:
		fullinvuln(ukemiroll_invuln)
		velocity.x += 500
	if frame == ukemiroll_end:
		velocity.x -= 500
		state(STAND)






	##################
	##HITBOXES##
	##################

func create_hitbox(polygon,damage,kb_base,kb_growth,angle,duration,hitboxdict):
	var hitbox_load = load('res://Base/Hitbox.tscn')
	var hitbox_inst = hitbox_load.instance()
	get_parent().add_child(hitbox_inst)
	hitbox_inst.position = self.position
	hitbox_inst.creator = self
	hitbox_inst.createdstate = state
	hitbox_inst.direction = direction
	
	hitbox_inst.get_node('polygon').set_polygon(polygon) #Revolver Ocelot
	hitbox_inst.damage = damage
	hitbox_inst.kb_base = kb_base
	hitbox_inst.kb_growth = kb_growth
	hitbox_inst.angle = angle
	hitbox_inst.duration = duration

	if hitboxdict.has('id'):
		hitbox_inst.id = hitboxdict['id']
	else: hitbox_inst.id = damage #The hitbox w higher damage will have higher id by default. 
	if hitboxdict.has('type'):
		if hitboxdict.has('type_interaction'):
			hitbox_inst.hitboxtype = hitboxdict['type']
			hitbox_inst.hitboxtype_interaction = hitboxdict['type_interaction']
		else:
			hitbox_inst.hitboxtype = hitboxdict['type']
			hitbox_inst.hitboxtype_interaction = hitboxdict['type']
	else:
		hitbox_inst.hitboxtype = 'strike'
		hitbox_inst.hitboxtype_interaction = 'strike'
	if hitboxdict.has('path'):
		if direction == 1:
			for point in hitboxdict['path']:
				hitbox_inst.path.add_point(point)
		else: #Flip the path when you look left
			for point in hitboxdict['path']:
				hitbox_inst.path.add_point(Vector2(-point.x,point.y))
	else: hitbox_inst.path.add_point(Vector2(0,0)) #else statements after .has() specify a default value if that parameter wasn't specified
	hitbox_inst.update_path()#set the path for the first frame
	if hitboxdict.has('priority'):
		hitbox_inst.priority = hitboxdict['priority']
	if hitboxdict.has('decline_dmg'): #per frame 
		pass
	else: pass
	if hitboxdict.has('decline_scale'):
		pass
	else: pass
	if hitboxdict.has('group'):
		hitbox_inst.group = hitboxdict['group'] #you better know what you're doing. It's best to involve gametime in the definition 
	else:
		hitbox_inst.group = self.name + self.state + str(global.gametime)
	if hitboxdict.has('hitboxpriority'): #Transcendent priority. 0= regular, 1= transcendent.
		hitbox_inst.hitboxpriority = hitboxdict['hitboxpriority']
	if hitboxdict.has('meteorcancel'): #-1= unconditionally uncancellable, 0= melee behavior, 1= unconditionally cancellable 
		pass
	else: pass
	if hitboxdict.has('element'):
		hitbox_inst.element = hitboxdict['element']
	else: hitbox_inst.element = 'normal'
	if hitboxdict.has('hitstopmod'):
		if hitboxdict.has('hitstopmod_self'):
			hitbox_inst.hitstopmod = hitboxdict['hitstopmod']
			hitbox_inst.hitstopmod_self = hitboxdict['hitstopmod_self']
		else:
			hitbox_inst.hitstopmod = hitboxdict['hitstopmod']
			hitbox_inst.hitstopmod = hitboxdict['hitstopmod']
	else:
		if hitbox_inst.element == 'electric': #untested
			hitbox_inst.hitstopmod = 1.5
			hitbox_inst.hitstopmod_self = 1.0
		else:
			hitbox_inst.hitstopmod = 1.0
			hitbox_inst.hitstopmod_self = 1.0
	#Projectile
	if hitboxdict.has('hitsleft'):
		hitbox_inst.hitsleft = hitboxdict['hitsleft']
	if hitboxdict.has('speedX'):
		hitbox_inst.speedX = hitboxdict['speedX']
	if hitboxdict.has('speedY'):
		hitbox_inst.speedY = hitboxdict['speedY']
	if hitboxdict.has('sprite'): #technically can be used for anything but projectiles are making the most out of this
		hitbox_inst.get_node('hitboxsprite').animation = hitboxdict['sprite']
	else:#this probably results in interpreter lag memes but only for 1 frame hopefully
		hitbox_inst.get_node('hitboxsprite').animation = self.state #there is probably a better way to handle this
	if hitboxdict.has('rage_growth'): #lol
		pass
	else: pass

	#shorthands for polygon creation
func rectangle(wid,hei):
	return [Vector2(-1*wid,hei),Vector2(wid,hei),Vector2(wid,-1*hei),Vector2(-1*wid,-1*hei)]
func square(wid):
	return [Vector2(-1*wid,wid),Vector2(wid,wid),Vector2(wid,-1*wid),Vector2(-1*wid,-1*wid)]

func fuckingdie(): #highly placeholder
	position = spawnpoint
	if maincharacter: stocks-=1
	else: queue_free()
	percentage = 0
	state(AIR)
	velocity = Vector2(0,0)
	refresh_air_options()
	hitqueue = []

var currenthits = []
var hitqueue = []
var nochange = false #used to break the while loop
var lasthitbox = []
func hit_processing():
	if state == HITSTUN or state == HITSTUNGROUNDED:
		var stick_normalized = Vector2((analogstick-Vector2(128,128)).normalized().y,(analogstick-Vector2(128,128)	).normalized().x)
			#SDI
		if impactstop > 0: #Placed before the getting hit code so that first frame of hitstop couldn't SDI
			if analogstick != analogstick_prev: #all of this is kind of a mess but it works 
				if (analogstick_prev.x == 128 or analogstick_prev.y == 128):
					if not (analogzone(2) or analogzone(4) or analogzone(6) or analogzone(8)):
						sdi(stick_normalized)
				else:
					if not (analogzone(1) or analogzone(3) or analogzone(7) or analogzone(9)):
						sdi(stick_normalized)


		if impactstop == 0 and frame == 1:
		#shoutouts to Numacow for babying me through perpendicular distance calculation
			#TDI
			var stick_prev_normalized = Vector2((analogstick_prev-Vector2(128,128)).normalized().y,(analogstick_prev-Vector2(128,128)).normalized().x)
			var angle_as_vector = Vector2(cos(deg2rad(hitstunangle)),sin(deg2rad(hitstunangle)))
			var perpendicular_distance = angle_as_vector.dot(stick_prev_normalized)
			hitstunangle = hitstunangle + abs(perpendicular_distance)*perpendicular_distance*-18 
			#ASDI
			if analogstick != Vector2(128,128):
				if motionqueue[-1] != "5": 
					move_and_collide(Vector2(stick_prev_normalized.y*35,stick_prev_normalized.x*-35)) #35 is arbitrary value, there'll be an update where I do accurate scaling later

	if currenthits != []:
		nochange = false
		while nochange == false:
			prune_ids()
		nochange = false
		lasthitbox = currenthits
		while nochange == false: sorthitbox_byparam('priority')
		nochange = false
		while nochange == false: sorthitbox_byparam('id')
		nochange = false
		while nochange == false: sorthitbox_byparam('damage')
		nochange = false
		while nochange == false: sorthitbox_byparam('lengroup')
		nochange = false
		while nochange == false: sorthitbox_byparam('port') 
		for x in currenthits: #hits everything except the last hitbox
			if not (x.group in hitqueue) and x != lasthitbox[0]:get_hit(x)
		if not (lasthitbox[0] in hitqueue): get_hit(lasthitbox[0]) #hits w the last (or only) hitbox

func sdi(normal):
	if grounded and hitstunknockback < 80: #Forbidden SDI check for grounded attacks
		var space_state = get_world_2d().direct_space_state
		move_and_collide(Vector2(normal.y*70,0))
		var ray_standing = space_state.intersect_ray(self.global_position+ecb_down(), Vector2(0,0),[self],collision_mask) #for getting the floor you're on
		var ray_y = space_state.intersect_ray(self.global_position+ecb_down(), Vector2(0,normal.x*-70),[self],collision_mask)
	#	print ("STANDING: " + str(ray_standing) + "  " + str(global.gametime))
	#	print ("RAY_Y:" + str(ray_y) + "  " + str(global.gametime) )
	else: #Air SDI
		move_and_collide(Vector2(normal.y*70,normal.x*-70)) #70 is arbitrary
#https://www.reddit.com/r/SSBM/comments/6k7goj/new_sdi_exception_unforbidden_di_and_conditional/		
#In Melee, there's a loophole regarding grounded Forbidden SDI- if you are inputting a diagonal SDI, and the horizontal vector of that SDI
#will put you outside of the ground anyways, then the vertical vector will also go through so long as it has the same collisions.
#Anyways I've tried to implement this with raycasts for like 2 hours and it didn't work
#piece of shit 
#have fun with this 



func analogzone(dir): #I made it this way cause it feels like this will be useful later, I doubt that though
	if dir == 1: #same zones
		if analogstick.y <= 128 and analogstick_prev.y <= 128 and analogstick.x <= 128 and analogstick_prev.x <= 128: return true
		else: return false
	if dir == 3:
		if analogstick.y <= 128 and analogstick_prev.y <= 128 and analogstick.x >= 128 and analogstick_prev.x >= 128: return true
		else: return false
	if dir == 7:
		if analogstick.y >= 128 and analogstick_prev.y >= 128 and analogstick.x <= 128 and analogstick_prev.x <= 128: return true
		else: return false
	if dir == 9:
		if analogstick.y >= 128 and analogstick_prev.y >= 128 and analogstick.x >= 128 and analogstick_prev.x >= 128: return true
		else: return false
	if dir == 2: #same cardinals
		if analogstick.y > 128 and analogstick_prev.y > 128 and analogstick.x == 128 and analogstick_prev.y == 128: return true
		else: return false
	if dir == 4:
		if analogstick.y == 128 and analogstick_prev.y == 128 and analogstick.x < 128 and analogstick_prev.x < 128: return true
		else: return false
	if dir == 8:
		if analogstick.y > 128 and analogstick_prev.y > 128 and analogstick.x == 128 and analogstick_prev.x == 128: return true
		else: return false
	if dir == 6:
		if analogstick.y == 128 and analogstick_prev.y == 128 and analogstick.x > 128 and analogstick_prev.x > 128: return true
		else: return false

func prune_ids(): 
	var initialhits = currenthits
	for x in currenthits:
		for y in currenthits:
			if y.creator == x.creator and y.group == x.group and not (x == y):
				if y.id > x.id:
					currenthits.erase(x)
					return
				if x.id > y.id:
					currenthits.erase(y)
					return
				if x.id == y.id: #this shouldn't happen
					currenthits.erase(y) #whichever was created later will be erased
					return
	nochange = true

func sorthitbox_byparam(param):
	var initial = lasthitbox
	for x in lasthitbox:
		for y in lasthitbox:
			if param == 'priority' and y.priority > x.priority:
				lasthitbox.erase(x)
				return
			if param == 'id' and y.id > x.id:
				lasthitbox.erase(x)
				return
			if param == 'lengroup' and len(y.group) > len(x.group):
				lasthitbox.erase(x)
				return
			if param == 'damage' and y.damage > x.damage:
				lasthitbox.erase(x)
				return
			if param == 'port' and int(y.creator.playerindex[1]) > int(x.creator.playerindex[1]): #this is fucked up 
				lasthitbox.erase(x) #lengroup check is kind of a port check cause p1 doesn't have additional symbols after its name
				return
	nochange = true

func hitqueue_plus(hit): #disallows hit groups that you've already been hit with. 12 entries. 
#Can happen if you slide into someone with a move with multiple hitboxes and different ids, the id code cannot prevent that. 
	if len(hitqueue) < 12:
		hitqueue.push_back(hit)
	else:
		hitqueue.pop_front()
		hitqueue.push_back(hit)

func get_hit(hitbox):

	hitqueue_plus(hitbox.group)
	
	if hitbox.hitboxtype_interaction == 'strike':
		if invulns['strike'] > 0:
			hit_invincibled(hitbox)
		else:
			hit_success(hitbox)
	if hitbox.hitboxtype_interaction == 'projectile':
		if invulns['projectile'] > 0:
			hit_invincibled(hitbox)
		else:
			hit_success(hitbox)


func hit_success(hitbox):
	hitstunknockback = (hitbox.kb_growth*0.01) *  \
	((14*(percentage/10+hitbox.damage/10)*(hitbox.damage/10+2)) \
	/             (weight + 100)                 +18) \
	+ hitbox.kb_base
	percentage+=hitbox.damage
	hitstunmod = hitbox.hitstunmod
	hitstunknockdown = hitbox.knockdowntype
	if hitbox.creator.position.x < position.x or (hitbox.creator.position.x == position.x and hitbox.creator.direction==1):
		hitstunangle = hitbox.angle
	if hitbox.creator.position.x > position.x or (hitbox.creator.position.x == position.x and hitbox.creator.direction==-1):
		hitstunangle = 90 + -1*(hitbox.angle-90)

	if (hitbox.angle >= 180 or hitbox.angle == 0):
		if grounded:
			if hitstunknockback < 80:
				grounded = true#grounded hitstun
				state(HITSTUNGROUNDED)
			else:
				hitstunangle = hitstunangle * -1 # bounce
				state(HITSTUN)
	else:
		grounded = false
		state(HITSTUN)

	invulns['strike'] = 0
	invulns['projectile'] = 0
	invulns['grab'] = 0
	#hitstop
	update_animation() #otherwise their first hitstop animation frame will be the state they were in before hitstun
	impactstop = int((hitbox.damage/30 + 3)*hitbox.hitstopmod) 

	if hitbox.hitboxtype_interaction == 'strike' and hitbox.creator.state != HITSTUN: #state check means trades will have offender hitstop
		hitbox.creator.impactstop = int((hitbox.damage/30 +3)*hitbox.hitstopmod_self)
func hit_blocked(hitbox):
	pass

func hit_invincibled(hitbox):
	if hitbox.hitboxtype_interaction == 'strike' and hitbox.creator.state != HITSTUN: #state check means trades will have offender hitstop
		hitbox.creator.impactstop = int((hitbox.damage/30 +3)*hitbox.hitstopmod_self)
	#no staling queue add



func invuln_processing():
	for x in invulns:

		if invulns[x] > 0:
			invulns[x]-=1

func fullinvuln(number):
	invulns['strike'] = number
	invulns['projectile'] = number
	invulns['grab'] = number


	##################
	##HANDLERS##
	##################


func state_handler():
	if state_check(STAND): stand_state()
	if state_check(CROUCH): crouch_state()
	if state_check(CROUCHSTART): crouchstart_state()
	if state_check(CROUCHEXIT): crouchexit_state()
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
	if state_check(BAIRDASH): bairdash_state()
	if state_check(AIRDODGE): airdodge_state()
	if state_check(WAVELAND): waveland_state()
	if state_check(HITSTUN): hitstun_state()
	if state_check(HITSTUNGROUNDED): hitstungrounded_state()
	if state_check(ATGHITSTUN): atghitstun_state()
	if state_check(TUMBLE): tumble_state()
	if state_check(UKEMISS): ukemiss_state()
	if state_check(UKEMIATTACK): ukemiattack_state()
	if state_check(UKEMINEUTRAL): ukemineutral_state()
	if state_check(UKEMIBACK): ukemiback_state()
	if state_check(UKEMIFORTH): ukemiforth_state()
	
func char_state_handler(): #Replace this in character script to have character specific states
	pass 
func attackcode():
#This is replaced in character script and contains state+input checks for attacks.
#The reason checks for attacks are outside of state_handler() is for the sake of modular design-
#it's much harder to create custom attack behavior if there's a bunch of default attack behavior baked into the default movement states in Player.gd,
#and you have to replace the entire state function to overwrite it.
#Simply putting these checks in the character script's _process functions adds a frame of lag to any action within it, so attackcode() was put in actionablelogic().
	pass


func enable_platform(): #enables platform collision
	self.set_collision_mask_bit(2,true)
func disable_platform(): #disables platform collision
	self.set_collision_mask_bit(2,false)

func aerial_acceleration(drift=1.0,ff=true):
	#drift lets you set custom drift potential to use for specials.
	#ff=false will disallow fastfalling.
	if tiltinput(left): #if drifting left
		if velocity.x > -1*drift_max: #so that drifting wouldn't cancel out existing run momentum
			velocity.x = round( max(-1 * drift_max*drift*action_analogconvert()/action_range,velocity.x-driftaccel_analog*drift*action_analogconvert()/action_range - driftaccel*drift))
	if tiltinput(right): #if drifting right
		if velocity.x < drift_max:
			velocity.x = round( min(drift_max*drift*action_analogconvert()/action_range,velocity.x+driftaccel_analog*drift*action_analogconvert()/action_range + driftaccel*drift))
	#fastfall
	if inputpressed(down) and !fastfall and ff:
		if fastfall_instant or velocity.y >= 0:
			fastfall = true
			velocity.y = fastfall_speed
	if velocity.y < fastfall_speed: fastfall = false
	#falling
	if airdashframes <= 0: apply_gravity()
	if airdashframes>0: airdashframes-=1
	if inputheld(down) and frame > 0: disable_platform() #frame>0 makes wavedashing on platforms not annoying, you'd need to hold 5 before JUMPSQUAT otherwise


var rooted = false #if true, then check for pECB collision 
func apply_traction(mod=1.0): #mod = modifier for traction.
	if abs(velocity.x) - traction*mod < 0:
		velocity.x = 0
	else:
		if velocity.x > 0:
			velocity.x-=traction * mod
		else:
			velocity.x+=traction * mod

func apply_traction2x():
	#Traction for states like jumpsquat, crouch, land and some grounded attacks.
	#The traction is doubled if your current speed is higher than the maximum walk speed. 
	if abs(velocity.x)-traction*2 >= walk_max:
		apply_traction(2.0)
	elif abs(velocity.x)-traction*2 <= walk_max:
		if abs(velocity.x) > walk_max+traction:
			#this part never happens but the function works so I lost the ability to care
			if velocity.x > 0:
				velocity.x = walk_max
			else:
				velocity.x = walk_max * -1
		else: apply_traction()


func apply_gravity(): #this is called in ground states as well to prevent bugs regarding collision not working if you don't have a
#downward vector at all times.
#I'll go with that solution for floor collision for now, but I'm sure as hell open to other collision systems 
	velocity.y += fall_accel
	if velocity.y > fall_max and not fastfall:
		velocity.y = fall_max
	if velocity.y > fastfall_speed and fastfall:
		velocity.y = fastfall_speed



func check_landing():
#Character scripts could either overwrite landingstates on _ready with every default state and their own or just .append() to it.
	if grounded and frame > 0:
		state(LAND)
		refresh_air_options()



func actionablelogic(delta): #a function I made to make ordering stuff that doesn't happen during impactstop easier
	#direction updates. Sprite happens at the end

	$ECB.scale.x = direction
	$Hurtbox.scale.x = direction
	$pECB.scale.x = direction
	invuln_processing()
	state_handler()
	char_state_handler()
	attackcode()
	if maincharacter: get_parent().get_parent().update_debug_display(self,playerindex+'_debug')
	if state in rootedstates:
		velocity.y = fall_accel #makes it so that you don't fall with full fall speed when you slide off after a rooted state.  
		rooted = true #^^^Not doing this at all will fuck the collision needed to make rooted states work in the first place.
	if state in slidestates:
		apply_gravity() #this is still necessary so that rooted states on f0 don't halt velocity
		if not grounded:
			if abs(velocity.x) > drift_max:
				if velocity.x > 0:
					velocity.x = drift_max
				else: velocity.x = drift_max * -1
			state(AIR)
			disable_platform() 
	if state in landingstates:
		check_landing()
	collision_handler(delta)


func ecb_up(): #returns the scene position of the top point of your pECB.
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[0]
func ecb_down(): #returns the scene position of the lower point of your pECB. 
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[2]
func ecb_left(): #left point. Note that this is right-facing, so the left point will become the rightmost point when direction == -1
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[1]
func ecb_right(): #right point. same directional concern as ecb_left()
	return position + $pECB.position + $pECB.get_node('pECB_collision').polygon[3]

func platform_drop(): #ran in state machine, disables platforms if 1/3 is pressed in numpad notation
	#should be put at the start of any state function
	if inputpressed(down) and (inputheld(left) or inputheld(right)):
		disable_platform()
		if not grounded: #If the platform disabling actually worked,
			state(AIR)
	elif (inputpressed(left) or inputpressed(right)) and inputheld(down):
		disable_platform()
		if not grounded: state(AIR)

var collisions = []
var in_platform = true #will trigger dfghjduhpfsdlnjk;hblhnjk;sdfgb;luhjkfsdg
var grounded = false
var pecbgrounded = false
func collision_handler(delta): #For platform/floor/wall collision.
	for x in get_slide_count(): #necessary for rooted states
		if not (get_slide_collision(x).collider in collisions):
			collisions.append(get_slide_collision(x).collider)

	$pECB.current_ecbcheck() #lets you die, done before pECB update so it's essentially the same as checking current frame collision 
	$pECB.position = $ECB.position + velocity/60 #projected ECB pos calculation
	if not (prune_disabledplats($pECB.collisions) != self.collisions and rooted):
		velocity = move_and_slide(velocity, Vector2(0, -1))
		#var collision = move_and_collide(velocity/60)
		#if collision:    #Remnants of me trying to switch to move_and_collide. It kinda sorta works but there's no reason to use it atm
		#	if collision.collider.name.substr(0,5) == 'Floor' or collision.collider.name.substr(0,4) == 'Plat':
		#		collision = move_and_collide(collision.remainder.slide(collision.normal))
	if velocity.y < 0: disable_platform()
	for x in $pECB.collisions: #post velocity move check for pECB
		if x.name.substr(0,4) == 'Plat': #Yes this means that proper plat collision relies on naming the platform objects properly
			if (self.position.x >= x.position.x and self.position.x <= x.position.x + 64*x.scale.x): #Prevents colliding w platforms from the side
				if not in_platform and velocity.y >= 0 and self.position.y < x.position.y:
					pecbgrounded = true
					enable_platform()

		if x.name.substr(0,5) == 'Floor':
			pecbgrounded = true
			disable_platform() #Colliding with the floor in any way will disable platforms. Is this even ok? Haven't found issues so far
	if $pECB.collisions == []:
		pecbgrounded = false
		in_platform = false
	else:
		in_platform = true
	rooted = false
	collisions = []
	if is_on_floor() or false: #remnants of me trying to make move_and_collide work. It still works *sort of* but I realized it's not necessary
		grounded = true #use grounded anyways please it's shorter than is_on_floor()
	else: grounded = false


func prune_disabledplats(collisionlist): #removes platforms from a collision list if they're disabled
	var newlist = []
	for x in collisionlist:
		if x.name.substr(0,4) != 'Plat':
			newlist.append(x)
		else:
			if get_collision_mask_bit(2): newlist.append(x)
	return newlist


func _ready():
	process_priority = 99 #Hopefully makes character code be executed later than hitbox code 
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
	#insert cstick code here. if a cstick input is held, completely wipe motionqueue and append the cstick input. Then, press the button in the buffer
#if blockstop/hitstop > 0: ignore game logic, otherwise decrement hitstop

#game logic.
	debug()
	persistentlogic()

	if impactstop == 0:
		actionablelogic(delta)
		update_animation()


#frame+=1. If hitstop > 0, don't increment frame
	framechange()



func framechange(): #increments the frames, decrements the impactstop timer and stops decrementing frame if impactstop > 0.
	if impactstop > 0:
		impactstop-=1
	if impactstop == 0:
		frame+=1




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
#Add ability to SDI if state == HITSTUN in persistentlogic().
