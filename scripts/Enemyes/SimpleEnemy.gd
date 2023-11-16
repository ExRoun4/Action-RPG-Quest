extends KinematicBody2D

export var maxHP = 1
onready var currentHP = maxHP
export var damage = 1

var knockback = Vector2.ZERO

const hitEffect = preload("res://prefabs/Overlap And Effects/HitEffect.tscn")
const deathSound = preload("res://prefabs/Overlap And Effects/EnemyDeathSound.tscn")

export var accel = 300
export var max_speed = 50
export var friction = 200
export var wander_target_range = 4

var velocity = Vector2.ZERO
enum { IDLE, WANDER, CHASE }
var state = CHASE
export var enemyType = "Bat"


var player = null

onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var sprite = $AnimatedSprite
onready var audioP = $AudioStreamPlayer

func _ready():
	sprite.animation = "Idle"
	sprite.frame = 0
	sprite.playing = true
	
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):
	if currentHP <= 0:
		return
		
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
				
			if enemyType == "Slime":
				sprite.play("Idle")
				
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= wander_target_range:
				update_wander()
				
		CHASE:
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400 
	velocity = move_and_slide(velocity)
	
func accelerate_towards_point(point, delta):
	var dir = global_position.direction_to(point)
	velocity = velocity.move_toward(dir * max_speed, accel * delta)
	sprite.flip_h = velocity.x < 0
	if enemyType == "Slime":
		sprite.play("Walkin")
	
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
	
func seek_player():
	if player != null:
		state = CHASE
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hitbox_area_entered(area):
	if area.name == "AttackRange":
		if currentHP > 0:
			currentHP -= area.get_parent().damage
			var effect = hitEffect.instance()
			effect.global_position = global_position - Vector2(0, 8)
			get_tree().current_scene.add_child(effect)
			$BlinkEffect.play("Blink")
		
		if currentHP <= 0:
			if $CollisionShape2D != null:
				$CollisionShape2D.queue_free()
			$Shadow.hide()
			sprite.play("Death")
			
			var hurt = deathSound.instance()
			get_tree().current_scene.add_child(hurt)
			
			var quests = get_node("/root/World/YSort/Player").quests
			if enemyType == "Bat":
				if quests.quest_type == "killbats" or quests.quest_type == "killbatsandslimes":
					if quests.questKills[0] < quests.maxQuestKills[0]:
						quests.questKills[0] += 1
			elif enemyType == "Slime":
				if quests.quest_type == "killslimes":
					if quests.questKills[0] < quests.maxQuestKills[0]:
						quests.questKills[0] += 1
				if quests.quest_type == "killbatsandslimes":
					if quests.questKills[1] < quests.maxQuestKills[1]:
						quests.questKills[1] += 1
					
			if enemyType == "Slime":
				yield(get_tree().create_timer(0.45), "timeout")
			else:
				yield(get_tree().create_timer(0.99), "timeout")
			queue_free()
		
		if self != null:
			knockback = area.knockback_vector * 120

func _on_PlayerDetector_body_entered(body):
	if body.collision_layer == 2:
		player = body

func _on_PlayerDetector_body_exited(body):
	if body.collision_layer == 2:
		player = null
