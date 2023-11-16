extends Node2D

onready var audioP = $AudioStreamPlayer
onready var buttonsNode = $Canvas/Buttons
onready var optionsPanel = $Canvas/OptionsPanel

func _on_Play_pressed():
	playPressSound()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://scenes/PlayerHome.tscn")

func _on_Options_pressed():
	playPressSound()
	buttonsNode.hide()
	optionsPanel.show()

func _on_Quit_pressed():
	playPressSound()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()

func _on_Back_pressed():
	playPressSound()
	buttonsNode.show()
	optionsPanel.hide()

func playPressSound():
	audioP.stream = load("res://Music and Sounds/Menu Select.wav")
	audioP.playing = true
