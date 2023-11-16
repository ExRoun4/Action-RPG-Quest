extends KinematicBody2D

export var maxHP = 1
onready var currentHP = maxHP

var velocity = Vector2.ZERO
var roll_velocity = Vector2.RIGHT

const max_speed = 100
const roll_speed = 150
const accel = 500
const friction = 500

export var damage = 1

onready var animTree = $AnimationTree
onready var animState = animTree.get("parameters/playback")

onready var canvas = $"../../Canvas"
onready var audioP = $AudioStreamPlayer
onready var attackRange = $AttackRange

onready var quests = $"../../QuestSystem"

export var location = "world"

enum{ MOVE, ROLL, ATTACK }
var state = MOVE

const hitEffect = preload("res://prefabs/Overlap And Effects/HitEffect.tscn")
const hurtSound = preload("res://prefabs/Overlap And Effects/PlayerHurtSound.tscn")

var hitPlayer = false
var hitDamage = 0

var attacking = false

func _ready():
	$AttackRange.knockback_vector = roll_velocity
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	
	setAnimTreeBlend(Vector2(1, 0))
	
func _process(delta):
	if hitPlayer and $HitTimer.time_left <= 0:
		$HitTimer.start(0.6)
		currentHP -= hitDamage
		$"../../Canvas/HeartUI".set_hearts(currentHP)
		
		var effect = hitEffect.instance()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)
		
		var hurt = hurtSound.instance()
		get_tree().current_scene.add_child(hurt)
		$BlinkEffect.play("Blink")
		
		if currentHP <= 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			canvas.deathAnimation()
			queue_free()
			
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
			
func move_state(delta):
	if Input.is_action_just_pressed("attack") and !attacking and location == "world":
		state = ATTACK
		return
			
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_velocity = input_vector
		attackRange.knockback_vector = input_vector
		
		setAnimTreeBlend(input_vector)
		
		animState.travel("Walk")
		velocity = velocity.move_toward(input_vector * max_speed, accel * delta)
	else:
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			
	move()

	if Input.is_action_just_pressed("roll"):
		state = ROLL
		if !audioP.playing:
			audioP.stream = load("res://Music and Sounds/Evade.wav")
			audioP.playing = true
			

func roll_state():
	velocity = roll_velocity * roll_speed
	move()
	
	animState.travel("Roll")
	
	yield(get_tree().create_timer(0.37), "timeout")
	velocity *= 0.8
	state = MOVE

func move():
	velocity = move_and_slide(velocity)
	
func attack_state():
	velocity = Vector2.ZERO
	if !attacking:
		attacking = true
	
		animState.travel("Attack")
		if !audioP.playing:
			audioP.stream = load("res://Music and Sounds/Swipe.wav")
			audioP.playing = true
		
		yield(get_tree().create_timer(0.3), "timeout")
		state = MOVE
		attacking = false

func attack(attackRangeRotation: int):
	attackRange.rotation_degrees = attackRangeRotation
	attackRange.get_child(0).disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	attackRange.get_child(0).disabled = true

func setAnimTreeBlend(vector: Vector2):
	animTree.set("parameters/Idle/blend_position", vector)
	animTree.set("parameters/Walk/blend_position", vector)
	animTree.set("parameters/Roll/blend_position", vector)
	animTree.set("parameters/Attack/blend_position", vector)
	
func _on_Hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		hitPlayer = true
		hitDamage = body.damage

func _on_Hitbox_body_exited(body):
	if body.is_in_group("Enemy"):
		hitPlayer = false
