extends Node2D

var score = 0
var speed = 200.0
var gameover = false
var enemyspeed = 80.0
var winscore = 15

func _ready():
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	$player/playershape.shape = shape

func _process(delta):
	if gameover:
		return

	moveplayer(delta)
	checkenemies(delta)
	checkcollectibles()

func moveplayer(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	if direction.length() > 0:
		direction = direction.normalized()

	$player.position += direction * speed * delta

	$player.position.x = clamp($player.position.x, 12, 788)
	$player.position.y = clamp($player.position.y, 12, 588)

func spawnenemy():
	if gameover:
		return

	var enemy = Area2D.new()
	enemy.name = "enemy"
	enemy.add_to_group("enemies")

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	var sizeval = randi_range(20, 50)
	rect.size = Vector2(sizeval, sizeval)
	shape.shape = rect
	enemy.add_child(shape)

	var sprite = Polygon2D.new()
	var half = sizeval / 2.0
	sprite.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half)
	])
	sprite.color = Color(0.9, 0.15, 0.15)
	enemy.add_child(sprite)

	var side = randi() % 4
	if side == 0:
		enemy.position = Vector2(randf_range(50, 750), -30)
	elif side == 1:
		enemy.position = Vector2(randf_range(50, 750), 630)
	elif side == 2:
		enemy.position = Vector2(-30, randf_range(50, 550))
	else:
		enemy.position = Vector2(830, randf_range(50, 550))
	var target = Vector2(randf_range(100, 700), randf_range(100, 500))
	enemy.set_meta("direction", (target - enemy.position).normalized())

	add_child(enemy)

func checkenemies(delta):
	var playerrect = Rect2($player.position - Vector2(12, 12), Vector2(24, 24))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dir = enemy.get_meta("direction")
		enemy.position += dir * enemyspeed * delta

		if enemy.position.x < -100 or enemy.position.x > 900:
			enemy.queue_free()
			continue
		if enemy.position.y < -100 or enemy.position.y > 700:
			enemy.queue_free()
			continue

		var enemysize = enemy.get_child(0).shape.size
		var enemyrect = Rect2(enemy.position - enemysize / 2, enemysize)
		if playerrect.intersects(enemyrect):
			lose()

func spawncollectible():
	if gameover:
		return

	var coin = Area2D.new()
	coin.name = "coin"
	coin.add_to_group("collectibles")

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 8
	shape.shape = circle
	coin.add_child(shape)

	var sprite = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(8):
		var angle = i * TAU / 8
		points.append(Vector2(cos(angle), sin(angle)) * 8)
	sprite.polygon = points
	sprite.color = Color(1.0, 0.85, 0.0)
	coin.add_child(sprite)

	coin.position = Vector2(randf_range(40, 760), randf_range(40, 560))
	add_child(coin)

func checkcollectibles():
	if gameover:
		return
	var playerrect = Rect2($player.position - Vector2(12, 12), Vector2(24, 24))

	for coin in get_tree().get_nodes_in_group("collectibles"):
		var coinrect = Rect2(coin.position - Vector2(8, 8), Vector2(16, 16))
		if playerrect.intersects(coinrect):
			score += 1
			updatescore()
			coin.queue_free()
			if score >= winscore:
				win()

func updatescore():
	$scorelabel.text = "Score: " + str(score)

func increasedifficulty():
	if gameover:
		return

	enemyspeed += 10

	if $enemytimer.wait_time > 0.5:
		$enemytimer.wait_time -= 0.15

func lose():
	gameover = true
	$enemytimer.stop()
	$collectibletimer.stop()
	$difficultytimer.stop()
	global.lastscore = score
	global.lastgame = "res://game1.tscn"
	get_tree().change_scene_to_file("res://death.tscn")

func win():
	gameover = true
	$enemytimer.stop()
	$collectibletimer.stop()
	$difficultytimer.stop()
	global.lastscore = score
	get_tree().change_scene_to_file("res://winner.tscn")
