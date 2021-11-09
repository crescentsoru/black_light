extends Node2D


#I'm still not sure how to handle stages, so this script is debug only for now.
#What I mean by this exactly is that there are two ways to implement a stage:
#1- Create a separate scene for each stage
#2- Have a single Stage.tscn, which loads everything it needs to be unique from a file.
#A stage builder would be created in this same game for implementation 2.
#I can handle either one, as I've already made a level builder/loader for Project Tension, though a grid-based one.
#The bigger challenge there would actually be creating good UI/UX for the stage builder, but, the effort would be absolutely worth it.
#which one is better for project architecture?I don't fucking know, which is why you shouldn't take this file seriously yet

#Note that the actual stage and characters are part of the Stage node. This script is attached to the Gaming node which is their parent.
#This is necessary to make sure pausing isn't completely annoying to deal with.

#Called when the node enters the scene tree for the first time.
func _ready():
	initialize_players()



func _process(delta):
	pass



func initialize_players():
	var playercount = []
	for x in [global.p1_data,global.p2_data]:
		if x[0] != '':
			playercount.append(x) #not useful rn, len(playercount) will be useful when deciding start positions with different amount of players
	if global.p1_data[0] != '':
		var p1_load = load('res://Characters/' + global.p1_data[0] + "/" + global.p1_data[0] + ".tscn")
		var p1_instance = p1_load.instance()
		get_node("Stage").call_deferred('add_child',p1_instance) #I forgot why call_deferred was good I'm just copying stuff
		p1_instance.position = global.spawn_1st + self.position
		p1_instance.spawnpoint = p1_instance.position
		p1_instance.playerindex = "p1"
		p1_instance.initialize_buttons(global.p1_data[3])
		p1_instance.stocks = global.stockcount
	if global.p2_data[0] != '':
		var p2_load = load('res://Characters/' + global.p2_data[0] + "/" + global.p2_data[0] + ".tscn")
		var p2_instance = p2_load.instance()
		get_node("Stage").call_deferred('add_child',p2_instance)
		p2_instance.position = global.spawn_2nd + self.position
		p2_instance.spawnpoint = p2_instance.position
		p2_instance.playerindex = "p2"
		p2_instance.initialize_buttons(global.p2_data[3])
		p2_instance.stocks = global.stockcount
	if global.p3_data[0] != '':
		var p3_load = load('res://Characters/' + global.p3_data[0] + "/" + global.p3_data[0] + ".tscn")
		var p3_instance = p3_load.instance()
		get_node("Stage").call_deferred('add_child',p3_instance)
		p3_instance.position = global.spawn_3rd + self.position
		p3_instance.spawnpoint = p3_instance.position
		p3_instance.playerindex = "p3"
		p3_instance.initialize_buttons(global.p3_data[3])
		p3_instance.stocks = global.stockcount


var ispause = false
var whopause = '' #the player who paused the game is specified here
var pauseframe = 0 #for forwarding by 1 frame
var pausehold = 0 #increments every frame forward is held, if it's 30 then go realtime as long as frame forward is held


func update_debug_display(caller,textobj='p1_debug'):
	$UI_persistent.get_node(textobj).text = "gametime= " + str(global.gametime) \
	 + "\nvelocity= " + str(caller.velocity) + "\nmotionqueue= " + caller.motionqueue \
	 + "\nstate= " + str(caller.state) + "\nframe= " + str(caller.frame) + "\nanalog= " + str(caller.analogstick) \
	 + "\n" + str(caller.stocks) + " stocks  " + str(caller.percentage/10) + "%  " 


func _physics_process(delta):
	if Input.is_action_just_pressed('d_record'): #Moved it here so I could reset the game while paused
		global.replaying = false
		global.resetgame() #wipes the replay file
	if Input.is_action_pressed('d_forward'): pausehold+=1
	else: pausehold = 0
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
	if Input.is_action_pressed("d_forward") and ispause and pausehold >= 30:
		pauseframe = global.gametime
		get_node("Stage").pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().paused = false



