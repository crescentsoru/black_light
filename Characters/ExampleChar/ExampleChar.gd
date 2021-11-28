extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'


func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),65,30,95,50,9, \
		{'id':50,
		'type':'strike', 'hitstopmod':1.0,
		'path':[Vector2(96,-64)],})

	if frame == 17:
		state(STAND)
	apply_traction2x()

func memehitbox_state():

	rooted = true
	if frame == 0: invulns['strike'] = 5
	if frame == 8:
		create_hitbox(rectangle(128,64),180,30,112,280,9000, \
		{'id':50,
		'type':'projectile', 'hitstopmod':1.0,
		'path':[Vector2(96,0)],
		'speedX':1750, 'speedY':0, 'sprite':'red',
		})
		
	apply_traction2x()
	velocity.y = fall_accel
	if frame == 32:
		state(STAND)

func attackcode():
	if groundattack_ok():
		if motionqueue[-1] == "5" and inputpressed(attackA):
			stateA(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			stateA(MEMEHITBOX)

func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): memehitbox_state()


func _physics_process(delta):
	pass
