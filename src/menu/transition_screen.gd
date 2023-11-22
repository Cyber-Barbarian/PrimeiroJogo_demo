extends CanvasLayer

@onready var animation: AnimationPlayer = get_node("AnimationPlayer")


var scene_path:String = ""
var can_quit:bool = false

func fade_in() ->void:
	animation.play("fadein")
	



func _on_animation_player_animation_finished(anim_name:String) -> void:
	if anim_name == "fadein":
		if can_quit:
			get_tree().quit()
			return

		get_tree().change_scene_to_file(scene_path)
		animation.play("fadeout")
		
