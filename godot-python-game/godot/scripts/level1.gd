extends Node2D

@onready var camera := $camera as Camera2D
@onready var player = $player
@onready var engine = $engine

func _ready():
	player.follow_camera(camera)
