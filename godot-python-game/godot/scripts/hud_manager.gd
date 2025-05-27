extends CanvasLayer

@onready var commands = $Control/MarginContainer/HBoxContainer/commands
var disponible_commands = "COMANDOS DISPONÍVEIS:
jogador.mover('direita')
jogador.mover('esquerda')
jogador.mover('baixo')
jogador.mover('cima')"

func _ready():
	commands.text = disponible_commands
