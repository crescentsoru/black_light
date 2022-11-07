extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'


func _ready():
	#Stats
	pass


func jab_state():
	apply_gravity()
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),80,30,95,50,9, \
		{'type':'strike',
		'path':[Vector2(96,-64)],})

	if frame == 17:
		grabinvuln(500)
		state(STAND)
	apply_traction2x()
	
func fair_state():
	aerial_acceleration()
	if frame == 0: landinglag = hardland
	if frame == 4: 
		landinglag = 11
		create_hitbox(rectangle(200,64),160,50,115,40,16, \
		{'type':'strike',
		'path':[Vector2(120,64)],})
	if frame == 24: landinglag = hardland
	if frame == 30:
		state(AIR)

func nair_state():
	aerial_acceleration()
	if frame == 0: landinglag = hardland
	if frame == 3: landinglag = 8
	if frame == 3: 
		create_hitbox(rectangle(80,64),70,70,120,98,3, \
		{'type':'strike',
		'path':[Vector2(150,0)],})
	if frame == 18:
		landinglag = hardland
	if frame == 23:
		state(AIR)

func neutralb_state():
	breverse()
	rooted = true
	if frame == 0: invulns['strike'] = 5
	if frame == 10:
		create_hitbox(rectangle(128,64),120,10,100,290,9000, \
		{'type':'projectile', 'hitstopmod':1.0,
		'path':[Vector2(96,0)],
		'speedX':1750, 'speedY':0, 'sprite':'red',
		})
	apply_traction2x()
	velocity.y = fall_accel
	if frame == 28:
		state(STAND)

func upb_state():
	breverse()
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
		if inputheld(left) and direction == -1 and velocity.x > -1200:
			velocity.x = -1200
		if inputheld(right) and direction == 1 and velocity.x < 1200:
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
		
	
	if frame > 5: ledgegrab_ok = true
	
	if frame == 42:
		landinglag = 10
	if frame == 48:
		state(FREEFALL)


func attackcode():
	if groundnormal_ok():
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if motionqueue[-1] == '7': flip()
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
	if state in [DASH,JUMPSQUAT]: #upb 
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if motionqueue[-1] == '7':
				flip()
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
	if airattack_ok():
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if motionqueue[-1] == '7': flip()
			state(UPB)
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(NAIR)
		if ((direction == 1 and motionqueue[-1] == "6") or (direction == -1 and motionqueue[-1] == "4")) and inputpressed(attackA): #help this sucks alot
			state(FAIR)

func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): neutralb_state()
	if state_check(UPB): upb_state()
	if state_check(FAIR): fair_state()
	if state_check(NAIR): nair_state()


func _physics_process(delta):
	pass
