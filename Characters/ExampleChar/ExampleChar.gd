extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'


func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),40,15,100,50,9, \
		{'id':50,
		'type':'strike', 'hitstopmod':16.0,
		'path':[Vector2(96,-64)],})
		invulns['projectile'] = 3000
	if frame == 16:
		state(STAND)
	apply_traction2x()

func memehitbox_state():
	apply_traction2x()
	velocity.y = fall_accel
	rooted = true
	if frame == 8:
		create_hitbox(rectangle(256,128),80,45,70,100,9000, \
		{'id':50,
		'type':'projectile', 'hitstopmod':1.0,'hitstopmod_self':1.0,
		'path':[Vector2(96,0)],
		'speedX':1750, 'speedY':0, 'sprite':'red',
		})


	if frame == 32:
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
