extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartsFull
onready var heartUIEmpty = $HeartsEmpty

onready var player = get_node("/root/World/YSort/Player")

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15
		
func set_max_hearts(value):
	max_hearts = max(value, 1)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = hearts * 15

func _ready():
	max_hearts = player.maxHP
	hearts = player.currentHP
