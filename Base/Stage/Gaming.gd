extends Node2D


#I'm still not sure how to handle stages, so this script is debug only for now.
#What I mean by this exactly is that there are two ways to implement a stage:
#1- Create a separate scene for each stage
#2- Have a single Stage.tscn, which loads everything it needs to be unique from a file.
#A stage builder would be created in this same game for implementation 2.
#I can handle either one, as I've already made a level builder/loader for Project Tension, though a grid-based one.
#The bigger challenge there would actually be creating good UI/UX for the stage builder, but, the effort would be absolutely worth it.
#which one is better for project architecture? I don't fucking know, which is why you shouldn't take this file seriously yet

#Note that the actual stage and characters are part of the Stage node. This script is attached to the Gaming node which is their parent.
#This is necessary to make sure pausing isn't completely annoying to deal with.

#Called when the node enters the scene tree for the first time.
func _ready():
	global.GamingNode = self
	initialize_players()


func init_player(port):
	if global.player_data[port][0] != '':
		#Load Port
		var data = global.player_data[port]
		var portnode_load = load("res://Base/Port.tscn")
		var portnode_instance = portnode_load.instance() 
		get_node("Stage").call_deferred('add_child',portnode_instance)
		portnode_instance.stocks = global.stockcount
		portnode_instance.initialize_buttons(global.player_data[port][3])
		portnode_instance.playerindex = port
		
		#Load Character
		var character_load = load('res://Characters/' + global.player_data[port][0] + "/" + global.player_data[port][0] + ".tscn")
		var character_instance = character_load.instance()
		portnode_instance.call_deferred('add_child',character_instance) #I forgot why call_deferred was good I'm just copying stuff
		portnode_instance.character = character_instance
		character_instance.position = global.spawns[port-1] + self.position 
		character_instance.spawnpoint = character_instance.position
		character_instance.playerindex = port
		character_instance.initialize_buttons(global.player_data[port][3]) #I don't know how to remove this cleanly. this is the messiest part of the code
		character_instance.stocks = global.stockcount #remove later
		character_instance.Port = portnode_instance #ref to node
		character_instance.FileSystemFolder = 'res://Characters/' + global.player_data[port][0] + "/"
		$Stage/Camera.targets.append(character_instance)


func initialize_players():
	var playercount = []
	for x in [global.player_data[1],global.player_data[2]]: # change later
		if x[0] != '':
			playercount.append(x) #not useful rn, len(playercount) will be useful when deciding start positions with different amount of players
	init_player(1)
	init_player(2)
	init_player(3)
	init_player(4)
	init_player(5)


var pause_default = false
var ispause = false
var whopause = '' #the player who paused the game is specified here
var pauseframe = 0 #for forwarding by 1 frame
var pausehold = 0 #increments every frame forward is held, if it's 30 then go realtime as long as frame forward is held


func update_debug_display(caller,textobj='p1_debug'):
	$UI_persistent.get_node(textobj).text = "gametime= " + str(global.gametime) \
	 + "\nvelocity= " + str(caller.velocity) + "\nmotionqueue= " + caller.currentmotion \
	 + "\nstate= " + str(caller.state) + "\nframe= " + str(caller.frame) + " imp= " + str(caller.impactstop) + "\nanalog= " + str(caller.Port.analogstick) \
	+ "\n" + str(caller.Port.stocks) + " stocks  " + str(caller.percentage/float(10)) + "%  " \
	+ "\nattackstate = " + caller.attackstate \
	+ "\nstate_called = " + str(caller.state_called)
#the fact that dividing returns an integer by default is easily one of the worst features they put into gdscript from python
#like what the fuck who wants this specific behavior in a scripting language

func _physics_process(delta):
	if Input.is_action_just_pressed('d_record'): #Moved it here so I could reset the game while paused
		ispause = false
		get_node("Stage").pause_mode = Node.PAUSE_MODE_PROCESS
		get_node("UI_persistent").pause_mode = Node.PAUSE_MODE_PROCESS
		get_tree().paused = false
		global.replaying = false
		global.resetgame() #wipes the replay file
	if Input.is_action_pressed('d_forward'): pausehold+=1
	else: pausehold = 0
	if Input.is_action_just_pressed('d_c'):
		pass
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



