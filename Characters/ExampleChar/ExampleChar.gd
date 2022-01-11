extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'


func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),80,30,95,50,9, \
		{'type':'strike',
		'path':[Vector2(96,-64)],})

	if frame == 17:
		state(STAND)
	apply_traction2x()

func memehitbox_state():

	rooted = true
	if frame == 0: invulns['strike'] = 5
	if frame == 8:
		create_hitbox(rectangle(128,64),120,10,100,290,9000, \
		{'type':'projectile', 'hitstopmod':1.0,
		'path':[Vector2(96,0)],
		'speedX':1750, 'speedY':0, 'sprite':'red',
		})
	apply_traction2x()
	velocity.y = fall_accel
	if frame == 32:
		state(STAND)

func upb_state():
	if frame == 0:
		velocity.x = velocity.x / 2
		velocity.y = 0
		landinglag = 10
	if frame == 2:
		velocity.y = - 2100


	if frame == 3:
		velocity.y -= 500
	if frame == 4:
		velocity.y -= 290
		if inputheld(left) and velocity.x > -1200:
			velocity.x = -1200
		if inputheld(right) and velocity.x < 1200:
			velocity.x = 1200
	if frame >= 5:
		apply_gravity()
		check_landing()
	
	if frame == 6:
		create_hitbox(rectangle(98,128),40,100,35,100,1, \
		{'type':'strike',
		'path':[Vector2(98,0)],})
	if frame == 8:
		create_hitbox(rectangle(84,220),110,50,125,80,12, \
		{'type':'strike',
		'path':[Vector2(128,-102)],})
	
	if frame == 12:
		if velocity.x >= 900: velocity.x = 900
		if velocity.x <= -900: velocity.x = -900
	
	if frame >= 26 and frame <= 42:
		air_friction()


	if frame == 42:
		landinglag = 15
	if frame == 48:
		state(FREEFALL)


func attackcode():
	if groundnormal_ok():
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
	if state in [DASH,JUMPSQUAT]: #upb 
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
	if airattack_ok():
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			state(UPB)


func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): memehitbox_state()
	if state_check(UPB): upb_state()


func _physics_process(delta):
	pass
