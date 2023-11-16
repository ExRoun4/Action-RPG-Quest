extends CanvasLayer

onready var audioP = $"../AudioPlayer"
onready var timer = $PausePanel/Timer
onready var anim = $PausePanel/Anim
onready var deathAnim = $DeathPanel/Anim
onready var changeSceneAnim = $ChangeScene/Anim

onready var gloriaNPC = $"../YSort/GloriaNPC"

var paused = false

func _input(delta):
	if Input.is_action_just_pressed("pause"):
		if gloriaNPC != null:
			if gloriaNPC.state == gloriaNPC.REWARD:
				return
				
		if timer.time_left <= 0:
			timer.start(0.4)
			if !paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				paused = true
				get_tree().paused = true
				anim.play("Pause")
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				paused = false
				get_tree().paused = false
				anim.play("Unpause")

func deathAnimation():
	deathAnim.play("Death")
	
func playPressSound():
	audioP.stream = load("res://Music and Sounds/Menu Select.wav")
	audioP.playing = true

func _on_Menu_pressed():
	playPressSound()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Menu.tscn")

func _on_Retry_pressed():
	playPressSound()
	changeSceneAnim.play("In")
	deathAnim.play("Out")
	if paused:
		get_tree().paused = false
		anim.play("Unpause")
		
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
	get_tree().reload_current_scene()
