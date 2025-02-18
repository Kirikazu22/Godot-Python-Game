extends Node2D

@onready var camera := $camera as Camera2D  # Assumindo que o node da câmera tem o nome "camera"
@onready var player = $player


func _ready():
	player.follow_camera(camera)  # Passando a câmera como argumento para a função
