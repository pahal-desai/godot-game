extends Control

func _ready():
	$scorelabel.text = "Score: " + str(global.lastscore)
	$restartbutton.grab_focus()

func gotomenu():
	get_tree().change_scene_to_file("res://menu.tscn")

func restartgame():
	get_tree().change_scene_to_file(global.lastgame)
