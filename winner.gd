extends Control

func _ready():
	$scorelabel.text = "Score: " + str(global.lastscore)
	$menubutton.grab_focus()

func gotomenu():
	get_tree().change_scene_to_file("res://menu.tscn")
