extends Node2D

const lines : Array[String] = [
	"Olá, aventureiro!","É muito bom vê-lo por aqui",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"... COMEÇANDO!",
]

@onready var camera := $camera as Camera2D
@onready var game_engine = $game_engine
@onready var code_input = $Code_Input
@onready var error_label = $Code_Input/error_label
@onready var submit_btn = $Code_Input/submit_btn
@onready var close_btn = $Code_Input/close_btn 
@onready var dialog_position = $dialog_position
@onready var player = $player

func _ready():
	player.follow_camera(camera)
	
	# "Cutscene" de abertura
	camera.zoom = Vector2(3.5,3.5)
	await get_tree().create_timer(2.0).timeout
	camera.zoom = Vector2(1.5,1.5)
	await get_tree().create_timer(1.0).timeout
	DialogManager.start_message(dialog_position.global_position, lines)
	
	# Conecta botões com segurança
	if submit_btn:
		if submit_btn.pressed.is_connected(_on_submit_btn_pressed):
			submit_btn.pressed.disconnect(_on_submit_btn_pressed)
		submit_btn.pressed.connect(_on_submit_btn_pressed)
	else:
		print("Erro: Botão de envio não encontrado!")
	
	if code_input.visible:
		code_input.grab_focus()
	
	# Passando o player_instance para o game_engine
	game_engine.set_player(player)
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

func _on_goal_area_entered(area):
	call_deferred("_go_to_next_level")

func _go_to_next_level():
	get_tree().change_scene_to_file("res://scenes/level2.tscn")
