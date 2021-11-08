extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'

func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,128),60,40,70,15,3, \
		{'id': 1,
		'track':'normal' })

	if frame == 16:
		state(STAND)

func memehitbox_state():
	if frame == 2:
		create_hitbox(rectangle(256,256),60,40,70,15,9999, {})
	
	if frame == 16:
		state(STAND)



func char_state_handler():
	if state_check(JAB): jab_state()
	if state_check(MEMEHITBOX): memehitbox_state()

func _physics_process(delta):
	if state == STAND:
		if motionqueue[-1] == "5" and inputpressed(attackA):
			state(JAB)
		if motionqueue[-1] == "5" and inputpressed(attackB):
			state(MEMEHITBOX)
