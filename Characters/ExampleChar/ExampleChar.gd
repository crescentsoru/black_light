extends 'res://Base/Player.gd'

const MEMEHITBOX = 'memehitbox'

func _ready():
	#Stats
	pass


func jab_state():
	if frame == 2: #frame 3 jab
		create_hitbox(rectangle(64,64),60,40,70,15,9, \
		{'id': 1,
		'track':'normal',
		'path':[Vector2(128,-64),Vector2(256,-64),Vector2(1000,0)],})

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
