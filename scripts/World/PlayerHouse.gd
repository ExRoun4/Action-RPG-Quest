extends Node2D

var player = null
var state = "toHome"
var change = false

onready var worldChangeSceneAnim = $"../../Canvas/ChangeScene/Anim"
onready var houseChangeSceneAnim = $"../Canvas/ChangeScene/Anim"

onready var text = $Text
onready var houseText = $houseText

onready var QS = $"../../QuestSystem"
onready var QH = $"../QuestSystem"

func _ready():
	yield(get_tree().create_timer(0.3), "timeout")
	if worldChangeSceneAnim != null:
		worldChangeSceneAnim.play("Out")
	if houseChangeSceneAnim != null:
		houseChangeSceneAnim.play("Out")
		
func _process(delta):
	if player != null:
		if state == "toHome":
			text.show()
		else:
			houseText.show()
	else:
		if text != null:
			text.hide()
		if houseText != null:
			houseText.hide()
	
	if Input.is_action_pressed("action"):
		if !change:
			if player != null and state == "toHome":
				goToHome()
			if player != null and state == "toWorld":
				goToWorld()
			
func _on_Detector_body_entered(body):
	if body.collision_layer == 2:
		player = body
		state = "toHome"

func _on_Detector_body_exited(body):
	if body.collision_layer == 2:
		player = null
		state = "none"

func _on_houseDetector_body_entered(body):
	if body.collision_layer == 2:
		player = body
		state = "toWorld"

func _on_houseDetector_body_exited(body):
	if body.collision_layer == 2:
		player = null
		state = "none"

func goToHome():
	worldChangeSceneAnim.play("In")
	yield(get_tree().create_timer(1), "timeout")
	if QS != null:
		QS.save.saveGame()
		
	get_tree().change_scene("res://scenes/PlayerHome.tscn")
	
func goToWorld():
	houseChangeSceneAnim.play("In")
	yield(get_tree().create_timer(1), "timeout")
	if QH != null:
		QH.save.saveGame()
		
	get_tree().change_scene("res://scenes/World.tscn")
