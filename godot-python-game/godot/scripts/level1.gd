extends Node2D

@onready var camera := $camera as Camera2D
@onready var game_engine = $game_engine
@onready var code_input = $Code_Input
@onready var error_label = $Code_Input/error_label
@onready var submit_btn = $Code_Input/submit_btn
@onready var close_btn = $Code_Input/close_btn 
@onready var spawnpoint = $spawnpoint


func _ready():
	var player_instance = preload("res://scenes/player.tscn").instantiate()
	add_child(player_instance)
	player_instance.position = spawnpoint.position
	player_instance.follow_camera(camera)
	code_input.visible = false
	# Desconecta sinais duplicados antes de conectar novamente
	if submit_btn:
		if submit_btn.pressed.is_connected(_on_submit_btn_pressed):
			submit_btn.pressed.disconnect(_on_submit_btn_pressed)
		submit_btn.pressed.connect(_on_submit_btn_pressed)
	else:
		print("Erro: Botão de envio não encontrado!")
	
	# Cena Inicial:
	# jogador anda e começa uma "cutscene"
	# é explicado o que ele precisa fazer na fase
	# e a janela para enviar código é aberta
	code_input.visible = !code_input.visible
	if code_input.visible:
		code_input.grab_focus()
	
	# Passando o player_instance para o game_engine
	game_engine.set_player(player_instance)
	game_engine.set_level1(self)

	if close_btn:
		if close_btn.pressed.is_connected(_on_close_btn_pressed):
			close_btn.pressed.disconnect(_on_close_btn_pressed)
		close_btn.pressed.connect(_on_close_btn_pressed)
	else:
		print("Erro: Botão de fechar não encontrado!")

func _on_close_btn_pressed():
	code_input.visible = false

func _on_submit_btn_pressed():
	var python_code = code_input.text.strip_edges()
	if python_code.is_empty():
		print("Código vazio!")
		return
	#code_input.visible = false
	
	#Futuramente verificar o código antes de enviar
	print("Código válido enviado:", python_code)
	_send_code_to_game_engine(python_code)

func exibir_mensagem_erro(mensagem: String):
	error_label.text= ""
	# Define a mensagem como placeholder do campo de código
	error_label.text = mensagem  # Define o texto no label
	error_label.add_color_override("font_color", Color.RED)  # Opcional: altera a cor do texto para vermelho

func _send_code_to_game_engine(code: String):
	if game_engine and game_engine.has_method("send_python_code"):
		game_engine.send_python_code(code)
	else:
		print("Erro: GameEngine não encontrado ou função inexistente.")
