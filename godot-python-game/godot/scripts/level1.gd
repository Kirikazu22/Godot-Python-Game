extends Node2D

@onready var camera := $camera as Camera2D
@onready var player = $player
@onready var game_engine = $game_engine
@onready var code_input = $Code_Input
@onready var submit_btn = $Code_Input/submit_btn
@onready var close_btn = $Code_Input/close_btn

func _ready():
	player.follow_camera(camera)
	code_input.visible = false

	if submit_btn:
		submit_btn.pressed.connect(_on_submit_btn_pressed)
	else:
		print("Erro: Botão de envio não encontrado!")

	if close_btn:
		close_btn.pressed.connect(_on_close_btn_pressed)
	else:
		print("Erro: Botão de fechar não encontrado!")

# Alterna a visibilidade do painel de código
func _on_game_engine_pressed():
	code_input.visible = !code_input.visible
	if code_input.visible:
		code_input.grab_focus()

func _on_close_btn_pressed():
	code_input.visible = false

func _on_submit_btn_pressed():
	var python_code = code_input.text.strip_edges()
	if python_code.is_empty():
		print("Código vazio!")
		return

	print("Código válido enviado:", python_code)
	_send_code_to_game_engine(python_code)

func _send_code_to_game_engine(code: String):
	if game_engine:
		game_engine.send_python_code(code)
	else:
		print("Erro: GameEngine não encontrado.")
