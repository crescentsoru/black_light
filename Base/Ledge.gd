extends Area2D


var occupying = [] #the character holding the ledge
var occupyframes = 0 #if 0, anyone can grab

var direction = 1 #-1 and 1 like characters. 
var floorpos = Vector2(0,0) #the position the character uses for stuff like getup, getup attack. All pos vars are relative to ledgebox position
var releasepos = Vector2(0,0) #the position you're in if you release ledge by pressing back.
var grabpos = Vector2(0,0) #the position you're snapped to when you grab ledge. Should be same as releasepos but go buckwild I guess


func _ready():
	pass



func _physics_process(delta):
	pass
