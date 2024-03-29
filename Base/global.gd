extends Node

	#Video game specific

var gamename = 'Blacklight'
var gameversion = 'alpha v0.3 Lunar Eclipse'
var versionstate = "In-Progress"
var debug = true 


func _ready():
	pass



	#Button config stuff I don't understand
var p1_device = {'device':0,'axisx':0,'axisy':0,'keyboard':false,'joypad':true}


	#Match initialization
#Match info
var stagename = 'thebattlefield'
var gamemode = 'versus'
var stockcount = 4
var thetimer = 28800 #in frames. 28800= 8 min.
var friendlyfire = true #if true, teammates can hit one another
var teams = { #has player indexes here
	'red' : [],
	'blue' : [],
	'green' : [],
	'yellow' : [],
	'purple' : [],
	'cyan' : [], 
	'white' : [],
	'brown' : [], #or black 
}
var RNGseed = 'ffffffff' #haven't decided on a format
var gameend = 99999999 #the frametime when the replay ends. 

#Stage
#This should probably be in stage but I haven't made a stage builder yet so its fine

var GamingNode = []


var spawn_1st := Vector2(4110,4900) #1st =/= p1. If there's 2 players and someone plugs into port 3 they should go into spawn_2nd for the sake of a neutral start.
var spawn_2nd := Vector2(6100,4900)#2nd =/= p2
var spawn_3rd := Vector2(5000,4900) #left center
var spawn_4th := Vector2(5500,4900) #right center
var spawn_5th := Vector2(5250,4900) #dead center


var spawns = [Vector2(4110,4900), Vector2(5000,4900), Vector2(6100,4900),  Vector2(5500,4900), Vector2(5250,4900)]

#Character



var player_data = {
					1 : [
	'ExampleChar', #[0]Character codename. Loads them from Characters/. Also lets the init funcs know the port is empty if it's == ''. 
	0, #[1]Character alt/skin
	'', #[2]Mode. For stuff like picking the first Porkyman with Porkyman Trainist or the Xeno 2 girls. Character scripts interact w this in _ready
	['p1_up','p1_down','p1_left','p1_right','p1_jump','p1_attackA','p1_attackB','p1_attackC','p1_attackD','p1_attackE','p1_attackF', 
	'p1_dodge','p1_grab','p1_cstickdown','p1_cstickup','p1_cstickleft','p1_cstickright','p1_uptaunt','p1_sidetaunt','p1_downtaunt',
	],#[3]An array for controls
	{}, #[4]replay
	]
	,
					2 : [
	'ExampleChar',
	0, 
	'',
	['p2_up','p2_down','p2_left','p2_right','p2_jump','p2_attackA','p2_attackB','p2_attackC','p2_attackD','p2_attackE','p2_attackF', 
	'p2_dodge','p2_grab','p2_cstickdown','p2_cstickup','p2_cstickleft','p2_cstickright','p2_uptaunt','p2_sidetaunt','p2_downtaunt',
	],
	{}, 
	]
	,
					3: [
	'',
	0, 
	'',
	['p3_up','p3_down','p3_left','p3_right','p3_jump','p3_attackA','p3_attackB','p3_attackC','p3_attackD','p3_attackE','p3_attackF',
	'p3_dodge','p3_grab','p3_cstickdown','p3_cstickup','p3_cstickleft','p3_cstickright','p3_uptaunt','p3_sidetaunt','p3_downtaunt',
	],
	{}, 
	]
	,
					4 : [
	'',
	0, 
	'',
	['p4_up','p4_down','p4_left','p4_right','p4_jump','p4_attackA','p4_attackB','p4_attackC','p4_attackD','p4_attackE','p4_attackF', 
	'p4_dodge','p4_grab','p4_cstickdown','p4_cstickup','p4_cstickleft','p4_cstickright','p4_uptaunt','p4_sidetaunt','p4_downtaunt',
	],
	{}, 
	]
	,
					5 : [
	'',
	0, 
	'',
	['p5_up','p5_down','p5_left','p5_right','p5_jump','p5_attackA','p5_attackB','p5_attackC','p5_attackD','p5_attackE','p5_attackF', 
	'p5_dodge','p5_grab','p5_cstickdown','p5_cstickup','p5_cstickleft','p5_cstickright','p5_uptaunt','p5_sidetaunt','p5_downtaunt',
	],
	{}, 
	]
	,
					6 : [] #do later
					,7 : []
					,8 : []
	
	
		}












	#Match specific variables & code
var gametime = 0
var fullreplay = {} #Don't put Vector2s in here!!! Godot JSON exports those as Strings!!!!!
var replaying = false #checks controllable on reload
var replayname = 'testreplay'
var replaynum = 0



func replay_savefile():
	var savefile = File.new()
	savefile.open('res://Replays/'+replayname+str(replaynum)+'.blre', File.WRITE)
	savefile.store_line(to_json(fullreplay))
	savefile.close()

func replay_loadfile():
	var loadfile = File.new()
	if not loadfile.file_exists('res://Replays/' + replayname + str(replaynum) + '.blre'): #if no file then break
		return
	loadfile.open('res://Replays/' + replayname + str(replaynum) + '.blre', File.READ)
	var file2list = loadfile.get_as_text()
	fullreplay = parse_json(file2list)
	loadfile.close()

func replay_loadfile_d():
	replay_loadfile()
	resetgame()

func compilereplay(): #This is probably ran multiple times hope it doesn't shit the fucking bed later when replays get longer
	fullreplay = {
		'gameinfo' : [gamename,gameversion], #gameinfo contains info like the game name and version.
		'matchinfo' : [stagename,gamemode,RNGseed,stockcount,thetimer,friendlyfire,teams],
		'p_data' : [player_data[1],player_data[2],player_data[3],player_data[4],player_data[5],player_data[6],player_data[7],player_data[8]], #initialization vars, inputs
		'end' : gameend,
		}


func resetgame():
	get_tree().change_scene("res://Base/Stage/Stage.tscn")
	gametime = 0

func _physics_process(delta):
	gametime+=1
