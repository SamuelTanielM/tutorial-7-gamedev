extends Button

@export var sceneName := "level_1"

func _on_button_pressed():
	if(sceneName == "play again"):
		get_tree().change_scene_to_file(str("res://scenes/level_1.tscn"))
		Inventory.reset()
	else:
		get_tree().change_scene_to_file(str("res://scenes/" + sceneName + ".tscn"))
