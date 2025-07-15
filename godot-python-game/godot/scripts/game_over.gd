extends Control

@onready var next_level_btn = $VBoxContainer/Next_Level_Btn

func _ready():
	if Globals.next_fase == 5:
		next_level_btn.visible = false

func _on_next_level_btn_pressed():
	if Globals.next_fase == 2:
		get_tree().change_scene_to_file("res://scenes/level2.tscn")
	elif Globals.next_fase == 3:
		get_tree().change_scene_to_file("res://scenes/level3.tscn")
	elif Globals.next_fase == 4:
		get_tree().change_scene_to_file("res://scenes/level4.tscn")

func _on_quit_game_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/main_title.tscn")
