extends Control

@onready var next_level_btn = $VBoxContainer/Next_Level_Btn

func _ready():
	if Globals.current_lvl == 3:
		next_level_btn.visible = false

func _on_next_level_btn_pressed():
	if Globals.current_lvl == 1:
		get_tree().change_scene_to_file("res://scenes/level2.tscn")
	elif Globals.current_lvl == 2:
		get_tree().change_scene_to_file("res://scenes/level3.tscn")

func _on_quit_game_btn_pressed():
	get_tree().quit()
