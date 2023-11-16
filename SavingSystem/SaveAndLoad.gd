extends Node2D

export var _savegame: Resource
const save_game_path := "user://savegame.tres"

onready var QS = $QuestSystem

onready var player = get_node("YSort/Player")

func saveGame():
	_savegame.gloriaPos = QS.gloriaPos
	_savegame.current_quest = QS.current_quest
	_savegame.quest_name = QS.quest_name
	_savegame.quest_type = QS.quest_type
	_savegame.maxQuests = QS.maxQuests
	_savegame.questKills = QS.questKills
	_savegame.maxQuestKills = QS.maxQuestKills
	
	ResourceSaver.save(save_game_path, _savegame)
	
func resetGame():
	_savegame.gloriaPos = Vector2(155, -85)
	_savegame.current_quest = 0
	_savegame.quest_name = "none"
	_savegame.quest_type = "none"
	_savegame.maxQuests = 6
	_savegame.questKills = [0, 0]
	_savegame.maxQuestKills = [0, 0]
	
	ResourceSaver.save(save_game_path, _savegame)
	
static func loadGame():
	if ResourceLoader.exists(save_game_path):
		var value = ResourceLoader.load(save_game_path)
		if value is SaveAndLoad:
			return value
	return null
