extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("button"):
		button.pressed.connect(on_button_pressed.bind(button.name))

func on_button_pressed(button_name: String) ->void:
	match button_name:
		"New Game":
			#get_tree().change_scene_to_file("res://src/Level/level.tscn")
			TransitionScreen.scene_path = "res://src/Level/level.tscn"
			TransitionScreen.fade_in()
			
		"Quit":
			
			TransitionScreen.can_quit = true
			TransitionScreen.fade_in()
			#get_tree().quit()
			
