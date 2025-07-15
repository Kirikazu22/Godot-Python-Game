extends Control

func _on_next_level_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/level2.tscn")

func _on_quit_game_btn_pressed():
	get_tree().quit()
