extends Node

	#Video game specific

var gamename = 'Blacklight pre-release'
var gameversion = 'no'




func _ready():
	pass



	#Match initialization

#Stage
var spawn_1st = Vector2(4110,1900) #1st =/= p1. If there's 2 players and someone plugs into port 3 they should go into spawn_2nd for the sake of a neutral start.
var spawn_2nd = Vector2(6100,4900)#2nd =/= p2


#Character
var p1_char = 'ExampleChar' #the character they picked. Loads a .tscn under that name in the folder of the same name in Characters/
var p1_alt = 0 #the character skin
var p1_mode = '' #for stuff like picking the first Porkyman with Porkyman Trainist or the Xeno 2 girls. Characters interact with this in character scripts in _ready
var p1_controls = [
	'p1_up',
	'p1_down',
	'p1_left',
	'p1_right',
	'p1_attackA',
	'p1_attackB',
	'p1_attackC',
	'p1_attackD',
	'p1_attackE',
	'p1_attackF',
	'p1_dodge',
	'p1_grab',
	'p1_cstickdown',
	'p1_cstickup',
	'p1_cstickleft',
	'p1_cstickright',
	'p1_uptaunt',
	'p1_sidetaunt',
	'p1_downtaunt',
]
var p2_char = 'ExampleChar'
var p2_controls = [
	'p2_up',
	'p2_down',
	'p2_left',
	'p2_right',
	'p2_attackA',
	'p2_attackB',
	'p2_attackC',
	'p2_attackD',
	'p2_attackE',
	'p2_attackF',
	'p2_dodge',
	'p2_grab',
	'p2_cstickdown',
	'p2_cstickup',
	'p2_cstickleft',
	'p2_cstickright',
	'p2_uptaunt',
	'p2_sidetaunt',
	'p2_downtaunt',
]
var p3_char = '' #if empty, don't have a player in that port
var p4_char = ''
var p5_char = ''
var p6_char = ''
var p7_char = ''
var p8_char = ''


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

func resetgame():
	get_tree().change_scene("res://Base/Stage/Stage.tscn")
	gametime = 0

func _physics_process(delta):
	gametime+=1
