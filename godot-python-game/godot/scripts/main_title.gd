extends Control

func _on_next_level_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")

func _on_quit_game_btn_pressed():
	get_tree().quit()

func _on_credits_btn_pressed():
	pass
