extends Node2D

export (PackedScene) var Beer
export (PackedScene) var Ult

var beer_num = 0
var can_shoot = true
var ult = false
onready var sp = $KinematicBody2D.sp


# Called when the node enters the scene tree for the first time.
func _ready():
	$KinematicBody2D.req = true


func _process(_delta):
	var not_gun_anims = ["ult", "fire"]
	if $KinematicBody2D.gun_mode == true and not not_gun_anims.has($AnimationPlayer2.current_animation):
		$AnimationPlayer2.play("gun")

func _input(event):
#CHEFS COAT
	if event.is_action_pressed("z"):
		$KinematicBody2D/Sprite/body.texture = preload("res://assets/players/adam/chef.png")
	elif event.is_action_pressed("x") or event.is_action_pressed("c"):
		$KinematicBody2D/Sprite/body.texture = preload("res://assets/players/adam/body.png")
#SHOOT
	if event.is_action_pressed("x") and can_shoot and $KinematicBody2D.gun_mode:
		_beer_toss()
		
func _on_ReloadTimer_timeout():
	for child in $KinematicBody2D/Sprite/gun.get_children():
		child.show()
	can_shoot = true
	beer_num = 0

func _on_UltTimer_timeout():
	ult = false
	$KinematicBody2D/Sprite/head/eyes.hide()
	$KinematicBody2D/Sprite/laptop.hide()
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(true)
		opponent.SPEED = 400
		opponent.GRAVITY = 50
	if $KinematicBody2D.gun_mode:
		$KinematicBody2D/Sprite/gun.show()
	else:
		$KinematicBody2D/Sprite/body.texture = preload("res://assets/players/adam/chef.png")
		$KinematicBody2D/Sprite/handR/weapon.show()

func _ult():
	ult = true
	#IMMOBALIZE PLAYERS
	for opponent in get_tree().get_nodes_in_group("player"):
		opponent.set_process_input(false)
		opponent.SPEED = 0
		opponent.GRAVITY = 0
		opponent.velocity = Vector2(0,0)
	$KinematicBody2D/Sprite/gun.hide()
	$KinematicBody2D/Sprite/handR/weapon.hide()
	$KinematicBody2D/Sprite/laptop.show()
	$AnimationPlayer2.play("ult")
	var node = Ult.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = Vector2(0,0)
	$UltTimer.start()

func _sp_mini():
	var n = beer_num
	while n < 6:
		_beer_toss()
		n += 1

func _beer_toss():
	$KinematicBody2D/Sprite/gun.get_child(beer_num).hide()
	$AnimationPlayer2.play("fire")
	beer_num += 1
	if beer_num == 6:
		can_shoot = false
		$ReloadTimer.start()
	var node = Beer.instance()
	get_node("/root/main").call_deferred("add_child", node)
	node.position = $KinematicBody2D/Sprite/gun.global_position - Vector2(0,5)
	node._veloc($KinematicBody2D.velocity.x)

#WEAPON DAMAGING OTHERS
func _harm(body):
	var rng = randf()
	body._damage(5 + (3 * rng))
	$KinematicBody2D.sp += 2 + (2 * rng)

func _on_DeathTimer_timeout():
	$KinematicBody2D/Sprite/body.texture = preload("res://assets/players/adam/chef.png")
	_on_ReloadTimer_timeout()
