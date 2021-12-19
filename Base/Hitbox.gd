extends Area2D


var creator = [] #The owner of the hitbox
var creatorobject = []
var createdstate = 'jab'
var stalingentry = 'jab'
var collisions = []
var frame = 0
var fuckshit = 0
var direction = 1


var damage = 3
var damage_base = 3 #the value you use if you don't want staling to mess with things
var kb_base = 15
var kb_growth = 100
var angle = 30
var duration = 10
var id = 0
onready var path = Path2D.new().get_curve()
var hitboxtype = 'strike' #follows the character
var hitboxtype_interaction = 'strike' #hitstop, deletion when creator state ends
var hitstopmod = 1.0
var hitstopmod_self = 1.0
var element = 'normal'
var group = ''
var hitboxpriority = 0
var knockdowntype = 'normal' #allows for different behavior when a character hits the ground.
var hitstunmod = 0.4 #don't change this unless you know wtf you're doing. Nintendo sure didn't 

#projectile specific
var hitsleft = 1
var speedX = 100
var speedY = 0



func _ready(): #happens BEFORE initialization in Player.gd apparently
	process_priority = 5 #Don't change this. Makes hitbox physics_process code be processed earlier than character code, eliminating a frame of lag. 
	connect( "area_entered", self, "on_area_enter")
	connect( "area_exited", self, "on_area_exit")
func update_path():
	if path.get_point_count() > 0:
		var length_percentage = path.get_baked_length()*(float(frame)/duration)
		position = creator.position + (path.interpolate_baked(length_percentage))



func on_area_enter(area):
	collisions.append(area)
	if area.name.substr(0,7) == 'Hurtbox':
		area.get_parent().process_priority = 89 #Do not change this!!! Fixes the impactstop offset bug, sort of 
		creator.process_priority = 109

func on_area_exit(area):
	if area in collisions: collisions.erase(area)
	

func impact(character): #called when you want to attack a character
	if (not (self.group in character.hitqueue)):
		if character.invulntype == 'intangible':
			if hitboxtype == 'projectile' and character.invulns['projectile'] == 0:
				character.currenthits.append(self)
				hitsleft -= 1
			if hitboxtype == 'strike' and character.invulns['strike'] == 0:
				character.currenthits.append(self)
				hitsleft -= 1
		else:
			character.currenthits.append(self)
			hitsleft -= 1



#if character.maincharacter: character.get_parent().get_parent().update_debug_display(character,character.playerindex+'_debug')
#(kb_growth*0.01) * ((14*(character.percentage/10+damage/10)*(damage/10+2))/(character.weight + 100)+18) + kb_base
#kb_growth/100 * (((14*(character.percentage/10+damage/10) * (damage/10 + 2))  / (character.weight+100)) + 18   )  + kb_base


func clash(hitbox2): #called when you clash with a hitbox without colliding with their creator
	#fail checks like clash state only for self.creator on projectiles or transcendental priority will be handled here 
	print ("clashed    " + str(hitbox2))


var handled_characters = [] #ignores characters which already have been clashed with or attacked
func hitbox_collide():
	for x in collisions:
		if x.name == 'Hitbox' and x.creator != creator: 
			for y in collisions:
				if y.name == 'Hurtbox' and y.get_parent() == x.creator: #should also check for projectile sdjlhn;ngkhjfgAAH AHJDFg look I'll do the specific clash stuff after I'm done doing basic hitstun
					impact(y.get_parent())
					handled_characters.append(y.get_parent())
			if not (x.creator in handled_characters):
				if x.priority == 0 and self.priority == 0:
					clash(x)
		if x.name == 'Hurtbox' and x.get_parent() != creator:
			if not (x.get_parent() in handled_characters):
				impact(x.get_parent())
	handled_characters = []


func _physics_process(delta):
	if hitboxtype == 'strike':
		update_path()
		if createdstate != creator.state:
			queue_free()
	if hitboxtype == 'projectile':
		position.x += speedX/60 * direction
		position.y += speedY/60
		if hitsleft <= 0:
			queue_free()
	hitbox_collide()
	if hitboxtype_interaction != 'strike' or (hitboxtype_interaction == 'strike' and creator.impactstop == 0):
		frame+=1
	if frame == duration: queue_free()
