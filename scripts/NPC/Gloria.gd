extends KinematicBody2D

onready var save = $"../.."

export var accel = 300
export var max_speed = 50
export var friction = 200
export var wander_target_range = 4

var velocity = Vector2.ZERO
enum { IDLE, WANDER, REWARD}
var state = IDLE

var facing = "right"

onready var sprite = $AnimatedSprite
onready var wanderController = $WanderController
onready var text = $Text

onready var QS = $"../../QuestSystem"
var dialogueOpened = false
export var quests: Array
export var dialogueMessages: Array

onready var dialogue = $"../../Canvas/Dialogue"
onready var dialogueText = $"../../Canvas/Dialogue/Text"

onready var changeSceneAnim = $"../../Canvas/ChangeScene/Anim"
onready var endingAnim = $"../../Canvas/Ending/Anim"

var player = null

func _ready():
	sprite.animation = "IdleDown"
	sprite.frame = 0
	sprite.playing = true

func openDialogue():
	if QS.current_quest == 0:
		dialogueText.text = "Hello sweetie! Wanna work for hot night?\n'Enter' - YEEEES!!!"
	else:
		if QS.current_quest < QS.maxQuests:
			if QS.questKills[0] == QS.maxQuestKills[0] and QS.questKills[1] == QS.maxQuestKills[1]:
				var rand = randi()%3
				dialogueText.text = dialogueMessages[0][rand]
			else:
				var rand = randi()%3
				dialogueText.text = dialogueMessages[1][rand]
		else:
			if QS.questKills[0] == QS.maxQuestKills[0] and QS.questKills[1] == QS.maxQuestKills[1]:
				dialogueText.text = "Well, i think you need reward for that work. Come on\n'Enter' - Get reward"
			else:
				var rand = randi()%3
				dialogueText.text = dialogueMessages[1][rand]
				
func _process(delta):
	if dialogueOpened:
		if Input.is_action_just_pressed("enter"):
			if QS.questKills[0] == QS.maxQuestKills[0] and QS.questKills[1] == QS.maxQuestKills[1]:
				if QS.current_quest == QS.maxQuests:
					dialogueOpened = false
					state = REWARD
					changeSceneAnim.play("In")
					endingAnim.play("Animate")
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					save.resetGame()
					return
				
				dialogueText.text = quests[QS.current_quest][0]
				QS.quest_name = quests[QS.current_quest][1]
				if quests[QS.current_quest][2] != null:
					QS.quest_name = quests[QS.current_quest][1]+"\n"+quests[QS.current_quest][2]
				
				QS.quest_type = quests[QS.current_quest][3]
				QS.maxQuestKills = [quests[QS.current_quest][4], quests[QS.current_quest][5]]
					
				if QS.current_quest < QS.maxQuests:
					QS.questKills = [0, 0]
					QS.current_quest += 1

func _physics_process(delta):
	if dialogueOpened:
		dialogue.show()
	else:
		dialogue.hide()
		
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			
			if player != null:
				var posX = global_position.x-player.global_position.x
				
				if posX > 10 or posX < -10:
					if player.global_position.x > global_position.x:
						facing = "right"
					if player.global_position.x < global_position.x:
						facing = "left"
				else:
					if player.global_position.y < global_position.y:
						facing = "up"
					if player.global_position.y > global_position.y:
						facing = "down"
				
				if !dialogueOpened:
					text.show()
				else:
					text.hide()
				
				if Input.is_action_just_pressed("action"):
					if !dialogueOpened:
						dialogueOpened = true
						openDialogue()
			else:
				text.hide()
				
				if dialogueOpened:
					dialogueOpened = false
				
			if facing == "up":
				sprite.play("IdleUp")
			if facing == "down":
				sprite.play("IdleDown")
			if facing == "right":
				sprite.play("IdleRight")
			if facing == "left":
				sprite.play("IdleLeft")
		
			if wanderController.get_time_left() == 0:
				update_wander()
				
				
		WANDER:
			if player != null:
				state = IDLE
				return
			
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta)
			
			if facing == "up":
				sprite.play("WalkUp")
			if facing == "down":
				sprite.play("WalkDown")
			if facing == "right":
				sprite.play("WalkRight")
			if facing == "left":
				sprite.play("WalkLeft")
				
			if global_position.distance_to(wanderController.target_position) <= wander_target_range:
				update_wander()
		REWARD:
			text.hide()
			
	velocity = move_and_slide(velocity)
	
func accelerate_towards_point(point, delta):
	var dir = global_position.direction_to(point)
	velocity = velocity.move_toward(dir * max_speed, accel * delta)
		
	if dir.x > -0.6:
		facing = "right"
	elif dir.x < 0.6:
		facing = "left"
	
	if dir.x < 0.6 and dir.x > -0.6:
		if dir.y < 0:
			facing = "up"
		elif dir.y > 0:
			facing = "down"
	
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_PlayerDetector_body_entered(body):
	if body.collision_layer == 2:
		player = body


func _on_PlayerDetector_body_exited(body):
	if body.collision_layer == 2:
		player = null
