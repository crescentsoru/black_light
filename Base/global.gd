extends Node

	#Game specific & code

var gamename = 'Blacklight pre-release'
var gameversion = 'no'


func _ready():
	pass



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
