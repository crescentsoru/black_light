extends Area2D

export var blastzonetype = 'kill' #kill= side and low blastzone, kills on touch. top= top, only kills if you're in tumble/hitstun



func _ready():
	connect( "body_entered", self, "on_body_enter")


func on_body_enter(body):
	pass
