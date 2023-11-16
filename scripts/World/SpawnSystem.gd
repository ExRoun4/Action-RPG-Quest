extends YSort

export var bat: PackedScene
export var slime: PackedScene

onready var QS = $"../QuestSystem"
onready var enemyPositions = $"../EnemyPositions"

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	var positions = enemyPositions.get_children()
	if positions.size() > 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var count = 0
		count = rng.randi_range(16, 20)
			
		while(count > 0):
			var rand = 0
			if QS.quest_type == "killslimes":
				rand = 2
			if QS.quest_type == "killbatsandslimes":
				rand = randi()%4
			
			var enemy = null
			var pos = positions[randi()%count]
			if rand == 0 or rand == 1:
				enemy = bat.instance()
			elif rand == 2 or rand == 3:
				enemy = slime.instance()
			enemy.global_position = pos.global_position
			add_child(enemy)
			positions.erase(pos)
			count -= 1
