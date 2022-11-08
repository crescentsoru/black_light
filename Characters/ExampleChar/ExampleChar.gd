extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'
const BIGPROJECTILE = 'bigprojectile'


#Cancel legends
#0= State you're switching to
#1= The first frame you can cancel from. Not adding a last frame restriction for this character, do what you want with your chars
#2= Input. TO DO: add shorthands for stuff like upb so it checks all diagonals. Also s at the start for smash attacks instead of [3]
#3= Smash attack. If false, tilt input is ok, if true, smash input necessary



const gatlings = {
	JAB : [[MEMEHITBOX,9,"5B",false],[BIGPROJECTILE,9,"236B",false],[UPB,1,"8B",false],[UPB,1,"7B",false],[UPB,1,"9B",false]]
	
	
	
	
	
	
	
}



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

func dtilt_state():
	apply_gravity()
	if frame == 3: #essentially a crouching 4f jab
		create_hitbox(rectangle(64,64),80,30,95,50,10, \
		{'type':'strike',
		'path':[Vector2(96,64)],})
	if frame == 15:
		grabinvuln(500)
		state(CROUCH)
	apply_traction2x()
	
func dsmash_state(): #dont smoke gas station weed
	apply_gravity()
	if frame == 4	:
		create_hitbox(rectangle(200,64),300,50,95,50,6, \
		{'type':'strike',
		'path':[Vector2(96,120)],})
	if frame == 15:
		grabinvuln(500)
		state(CROUCH)
	apply_traction2x()


func fair_state():
	aerial_acceleration()
	if frame == 0: landinglag = hardland
	if frame == 6:
		playsfx("swoosh.wav")
		landinglag = 11
		create_hitbox(rectangle(200,64),160,45,115,40,16, \
		{'type':'strike',
		'path':[Vector2(120,64)],})
	if frame == 24: landinglag = hardland
	if frame == 40:
		state(AIR)

func nair_state():
	aerial_acceleration()
	if frame == 0: landinglag = hardland
	if frame == 3: landinglag = 8
	if frame == 3: 
		create_hitbox(rectangle(80,64),70,60,140,98,3, \
		{'type':'strike',
		'path':[Vector2(150,0)],})
	if frame == 18:
		landinglag = hardland
	if frame == 23:
		state(AIR)

func neutralb_state():
	breverse()
	rooted = true
	if frame == 8:
		create_hitbox(rectangle(128,64),120,10,100,290,9000, \
		{'type':'projectile', 'hitstopmod':1.0,
		'path':[Vector2(96,0)],
		'speedX':1750, 'speedY':0, 'sprite':'red',
		}) #These are literally just Falco dair stats
	apply_traction2x()
	velocity.y = fall_accel
	if frame == 32:
		state(STAND)

func bigprojectile_state():
	breverse()
	rooted = true
	apply_traction()
	apply_gravity()
	if frame == 20:
		create_hitbox(rectangle(128,64),140,70,90,50,9000, \
		{'type':'projectile', 'hitstopmod':1.0,
		'path':[Vector2(96,0)],
		'speedX':4000, 'speedY':0, 'sprite':'red',
		})
	if frame == 29: state(STAND)




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

	if frame >= 5:
		apply_gravity()
		check_landing()
	
	if frame == 6:
		create_hitbox(rectangle(98,128),40,100,35,100,1, \
		{'type':'strike',
		'path':[Vector2(98,0)],})
	if frame == 8:
		if inputheld(left) and direction == -1 and velocity.x > -1200:
			velocity.x = -1200
		if inputheld(right) and direction == 1 and velocity.x < 1200:
			velocity.x = 1200
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
		if (check_motion("236") or check_motion("2365")) and inputpressed(attackB): #placeholder
			state(BIGPROJECTILE)
		elif motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if currentmotion[-1] == '7' : flip() #destroy this stupid shit later 
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
		if currentmotion[-1] in ['1','2','3'] and inputpressed(attackA):
			if inputheld(down,smashattacksensitivity):
				state(DSMASH)
			else:
				state(DTILT)
	if state in [DASH,JUMPSQUAT]: #upb 
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if currentmotion[-1] == '7': flip()
			state(UPB)
		if inputheld(dodge) and inputpressed(attackA):
			state(NEUTRALGRAB)
	if airattack_ok():
		if not airoptions_exhausted() and motionqueue[-1] in ['7','8','9'] and inputpressed(attackB):
			if currentmotion[-1] == '7': flip()
			state(UPB)
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(NAIR)
		if ((direction == 1 and motionqueue[-1] == "6") or (direction == -1 and motionqueue[-1] == "4")) and inputpressed(attackA): #help this sucks alot
			state(FAIR)
	
	
	
	
	
	
	
	check_gatlings() #Always always always have this last in the function 

func check_gatlings():
	for curstate in gatlings:
		if state == curstate:
			for x in gatlings[curstate]:
				if frame == 0: print (x)



func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): neutralb_state()
	if state_check(BIGPROJECTILE): bigprojectile_state()
	if state_check(UPB): upb_state()
	if state_check(FAIR): fair_state()
	if state_check(NAIR): nair_state()
	if state_check(DTILT): dtilt_state()
	if state_check(DSMASH): dsmash_state()
	

func _physics_process(delta):
	pass
