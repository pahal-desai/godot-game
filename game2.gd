extends Node2D

var score = 0
var gameover = false
var tilelifetime = 2.0
var winscore = 20

func spawntile():
	if gameover:
		return

	var isred = randf() < 0.35

	var tile = ColorRect.new()
	tile.size = Vector2(60, 60)
	tile.position = Vector2(randf_range(20, 720), randf_range(60, 520))

	if isred:
		tile.color = Color(0.9, 0.15, 0.15)
		tile.set_meta("type", "red")
	else:
		tile.color = Color(0.2, 0.85, 0.3)
		tile.set_meta("type", "green")

	tile.add_to_group("tiles")
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.gui_input.connect(tileclick.bind(tile))
	add_child(tile)

	var timer = get_tree().create_timer(tilelifetime)
	timer.timeout.connect(removetile.bind(tile))

func tileclick(event, tile):
	if gameover:
		return
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return

	var type = tile.get_meta("type")
	if type == "red":
		lose()
		return

	score += 1
	updatescore()
	tile.queue_free()

	if score >= winscore:
		win()

func removetile(tile):
	if is_instance_valid(tile):
		tile.queue_free()

func updatescore():
	$scorelabel.text = "Score: " + str(score)

func increasedifficulty():
	if gameover:
		return

	if tilelifetime > 0.8:
		tilelifetime -= 0.2

	if $spawntimer.wait_time > 0.4:
		$spawntimer.wait_time -= 0.1

func lose():
	gameover = true
	$spawntimer.stop()
	$difficultytimer.stop()
	global.lastscore = score
	global.lastgame = "res://game2.tscn"
	get_tree().change_scene_to_file("res://death.tscn")

func win():
	gameover = true
	$spawntimer.stop()
	$difficultytimer.stop()
	global.lastscore = score
	get_tree().change_scene_to_file("res://winner.tscn")
