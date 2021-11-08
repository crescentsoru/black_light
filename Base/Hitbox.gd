extends Area2D


var creator = [] #The owner of the hitbox
var createdstate = 'jab'
var collisions = []
var frame = 0
var fuckshit = 0

var damage = 3
var kb_base = 20
var kb_growth = 100
var angle = 30
var duration = 10
var id = 0
onready var path = Path2D.new().get_curve()
var hitboxtype = 'melee' #follows the character
var hitboxtype_interaction = 'melee' #hitstop, deletion when creator state ends
var group = ''


var knockdowntype = 'normal' #allows for different behavior when a character hits the ground.
var hitstunmod = 0.4 #don't change this unless you know wtf you're doing. Nintendo sure didn't 

func _ready(): #happens BEFORE initialization in Player.gd apparently
	process_priority = 5 #Don't change this. Makes hitbox physics_process code be processed earlier than character code, eliminating a frame of lag. 
	connect( "area_entered", self, "on_area_enter")

func update_path():
	if path.get_point_count() > 0:
		var length_percentage = path.get_baked_length()*(float(frame)/duration)
		position = creator.position + (path.interpolate_baked(length_percentage))



func on_area_enter(area):
	collisions.append(area)

func attack(character): #called when you want to attack a character
	print ("attacked  " + str(character))
	if character.blocking:
		pass
	else: #attacking
		character.hitstunknockback = kb_growth/100 * (((14*(character.percentage/10+damage/10) * (damage/10 + 2))  / (character.weight+100)) + 18   )  + kb_base
		character.percentage+=damage
		character.hitstunmod = hitstunmod
		character.hitstunknockdown = knockdowntype

		character.state('hitstun') #this should be last otherwise there will be no hitstun on the first hit
		
		if creator.position.x < character.position.x or (creator.position.x == character.position.x and creator.direction==1):
			character.velocity.x = cos(deg2rad(angle))*character.hitstunknockback*20 #the 20 is arbitrary
			character.velocity.y = sin(deg2rad(-angle))*character.hitstunknockback*20
		if creator.position.x > character.position.x or (creator.position.x == character.position.x and creator.direction==-1):
			character.velocity.x = cos(deg2rad(-1*(angle+90) -90))*character.hitstunknockback*20
			character.velocity.y = sin(deg2rad(-1*(-angle+90) -90))*character.hitstunknockback*20

#(kb_growth*0.01) * ((14*(character.percentage/10+damage/10)*(damage/10+2))/(character.weight + 100)+18) + kb_base


func clash(hitbox2): #called when you clash with a hitbox without colliding with their creator
	pass #fail checks like clash state only for self.creator on projectiles or transcendental priority will be handled here 
	print ("clashed    " + str(hitbox2))


var handled_characters = [] #ignores characters which already have been clashed with or attacked
func hitbox_collide():
	for x in collisions:
		if x.name == 'Hitbox' and x.creator != creator: 
			for y in collisions:
				if y.name == 'Hurtbox' and y.get_parent() == x.creator: #should also check for projectile sdjlhn;ngkhjfgAAH AHJDFg look I'll do the specific clash stuff after I'm done doing basic hitstun
					attack(y.get_parent())
					handled_characters.append(y.get_parent())
			if not (x.creator in handled_characters) :clash(x)
		if x.name == 'Hurtbox' and x.get_parent() != creator:
			if not (x.get_parent() in handled_characters): attack(x.get_parent())
	
	
	handled_characters = []


func _physics_process(delta):
	if hitboxtype == 'melee':
		update_path()
		if createdstate != creator.state:
			queue_free()
	hitbox_collide()
	collisions = []
	frame+=1
	if frame == duration: queue_free()
