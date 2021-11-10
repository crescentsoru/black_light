extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'


func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),45,15,100,50,9, \
		{'id': 1,
		'type':'melee', 'hitstopmod':1.0,'hitstopmod_self':1.0,
		'path':[Vector2(128,-64)],})

	if frame == 16:
		state(STAND)

func memehitbox_state():
	if frame == 2:
		create_hitbox(rectangle(256,256),30,10,40,80,9999, {})
	
	if frame == 16:
		state(STAND)


const GROUNDATTACKSTATES = [STAND,CROUCHSTART,CROUCH,CROUCHEXIT,WALK,DASHEND,BRAKE,RUN]

func groundedattack_ok():
	if state in GROUNDATTACKSTATES:
		return true
	else:
		
		return false

func attackcode():
	if groundedattack_ok():
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)

func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): memehitbox_state()


func _physics_process(delta):
	if state == STAND:
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)
