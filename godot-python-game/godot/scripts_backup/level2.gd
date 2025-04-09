extends Node2D

@onready var camera := $camera as Camera2D
@onready var spawnpoint := $spawnpoint  # Um marcador na fase 2, tipo um Position2D

func _ready():
	var player_instance = preload("res://scenes/player.tscn").instantiate()
	add_child(player_instance)
	player_instance.position = spawnpoint.position  # Coloca o player no ponto certo da fase 2
	player_instance.follow_camera(camera)
