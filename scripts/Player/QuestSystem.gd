extends Node2D

onready var save = get_parent()

var current_quest = 0
var quest_name = "Kill 4 bats"
var quest_type = "killbats"
var maxQuests = 6
var questKills = [0, 0]
var maxQuestKills = [4, 0]

var gloriaPos = Vector2.ZERO
onready var gloria = $"../YSort/GloriaNPC"

onready var questTitle = $"../Canvas/Quests/QuestCount"
onready var quest = $"../Canvas/Quests/Quest"
onready var questProgress = $"../Canvas/Quests/QuestProgress"

export var location = "world"

func _ready():
	var savedData = save.loadGame()
	if savedData == null:
		save.saveGame()
	else:
		current_quest = savedData.current_quest
		quest_name = savedData.quest_name
		quest_type = savedData.quest_type
		maxQuests = savedData.maxQuests
		questKills = savedData.questKills
		maxQuestKills = savedData.maxQuestKills
		gloriaPos = savedData.gloriaPos
		if gloria != null:
			gloria.global_position = gloriaPos

func _process(delta):
	if gloria != null:
		gloriaPos = gloria.global_position
		
	if location == "home": return
	
	if current_quest == 0: 
		questTitle.hide()
		quest.hide()
		questProgress.hide()
	else:
		questTitle.show()
		quest.show()
		questProgress.show()
		
		questTitle.text = "Quest "+str(current_quest)
		quest.text = quest_name
		if quest_type == "killbats" or quest_type == "killslimes":
			if questKills[0] == maxQuestKills[0]:
				questProgress.text = "  DONE"
			else:
				questProgress.text = str(questKills[0])+" / "+str(maxQuestKills[0])
		else:
			if questKills[0] == maxQuestKills[0] and questKills[1] == maxQuestKills[1]:
				questProgress.text = "  DONE"
			else:
				questProgress.text = str(questKills[0])+" / "+str(maxQuestKills[0])+"\n"+str(questKills[1])+" / "+str(maxQuestKills[1])
