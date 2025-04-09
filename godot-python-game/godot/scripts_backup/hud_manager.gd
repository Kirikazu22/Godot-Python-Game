extends Control

@onready var commands = $MarginContainer/HBoxContainer/commands
@export var disponible_commands = "COMANDOS DISPONÍVEIS:
avancar()
virarAEsquerda()"

# Called when the node enters the scene tree for the first time.
func _ready():
	commands.text = disponible_commands
