extends Node2D



func _ready():
	pass



func _process(delta):
	if $GoBack.pressed: get_tree().change_scene("res://Base/Stage/Stage.tscn")
	if $Player1.pressed: get_node("Node").switch_player(1)
	if $Player2.pressed: get_node("Node").switch_player(2)
	if $Player3.pressed: get_node("Node").switch_player(3)
