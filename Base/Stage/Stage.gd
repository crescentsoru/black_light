extends Node2D


#I'm still not sure how to handle stages, so this script is debug only for now.
#What I mean by this exactly is that there are two ways to implement a stage:
#1- Create a separate scene for each stage
#2- Have a single Stage.tscn, which loads everything it needs to be unique from a file.
#A stage builder would be created in this same game.
#I can handle either one, as I've already made a level builder/loader for Project Tension, though a grid-based one.
#The bigger challenge there would actually be creating good UI/UX for the stage builder, but, the effort would be absolutely worth it.



#which one is better for project architecture?I don't fucking know, which is why you shouldn't take this file seriously yet

#Note that the actual stage and characters are part of the Stage node. This script is attached to the Gaming node which is their parent.
#This is necessary to make sure pausing isn't completely annoying to deal with.

#fuck you github get my goddamn project on the internet
#Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


func _process(delta):
	pass

onready var examplechar = $Stage/ExampleChar
var ispause = false
var whopause = '' #the player who paused the game is specified here
var pauseframe = 0 #for forwarding by 1 frame


var text1 = '' #to make the debug text more bearable to edit
var text2 = ''
var text3 = ''

func _physics_process(delta):
	text1= "gametime= " + str(global.gametime) + "\nvelocity= " + str(examplechar.velocity) + "\nmotionqueue= " + examplechar.motionqueue
	text2= "\nstate= " + str(examplechar.state) + "\nframe= " + str(examplechar.frame) + "\nanalog= " + str(examplechar.analogstick)
	text3= ''
	$UI_persistent/gametime.text = text1 + text2 + text3
	if Input.is_action_just_pressed("p1_pause"):
		if ispause == false:
			ispause = true
			get_node("Stage").pause_mode = Node.PAUSE_MODE_STOP
			get_node("UI_persistent").pause_mode = Node.PAUSE_MODE_PROCESS
			get_tree().paused = true
		else:
			ispause = false
			get_node("Stage").pause_mode = Node.PAUSE_MODE_PROCESS
			get_node("UI_persistent").pause_mode = Node.PAUSE_MODE_PROCESS
			get_tree().paused = false
	if Input.is_action_just_pressed("d_forward") and ispause:
		pauseframe = global.gametime
		get_node("Stage").pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().paused = false
	if ispause and global.gametime == pauseframe+1:
		get_node("Stage").pause_mode = Node.PAUSE_MODE_STOP
		get_tree().paused = true


