extends Area2D

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	# Use call_deferred para evitar conflitos de física
	call_deferred("_change_scene")

func _change_scene():
	get_tree().change_scene_to_file("res://scenes/level2.tscn")
