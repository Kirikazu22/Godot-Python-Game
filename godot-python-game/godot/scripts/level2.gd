extends Node2D

const lines : Array[String] = [
	"Crie uma função para descobrir qual é a ponte segura. O código deve conter pelo menos um loop (while ou for). O número correto não pode inserido diretamente. A resposta é dada pelo menor resultado positivo da divisão inteira sucessiva do número 27.
"
]

@onready var camera := $camera as Camera2D
@onready var game_engine = $game_engine
@onready var code_input = $CanvasLayer/Code_Input
@onready var submit_btn = $CanvasLayer/Code_Input/submit_btn
@onready var close_btn = $CanvasLayer/Code_Input/close_btn
@onready var error_label = $CanvasLayer/Code_Input/error_label
@onready var dialog_position = $dialog_position
@onready var player = $player
@onready var hud = $HUD
@onready var animation_player = $AnimationPlayer
@onready var color_rect = $AnimationPlayer/ColorRect
@onready var skip_hud = $CanvasLayer/Skip_Hud
@onready var hud_code_input = $CanvasLayer/Hud_Code_Input
@onready var hud_dialog_box = $CanvasLayer/Hud_Dialog_Box
@onready var code_input_button_label = $CanvasLayer/Hud_Code_Input/label
@onready var dialog_box_button_label = $CanvasLayer/Hud_Dialog_Box/label
@onready var commands = $HUD/Control/MarginContainer/HBoxContainer/commands

func _ready():
	Globals.current_lvl = self
	Globals.next_fase = 3
	commands.text = "COMANDOS DISPONÍVEIS:
	jogador.atravessar_ponte()"
	color_rect.visible = true
	animation_player.play("appear")
	# "Cutscene" de abertura
	camera.position = Vector2(0,255)
	camera.zoom = Vector2(3.5,3.5)
	await get_tree().create_timer(2.0).timeout
	color_rect.visible = false
	camera.position = Vector2(-96,-11)
	camera.zoom = Vector2(1,1)
	await get_tree().create_timer(1.0).timeout
	skip_hud.visible = true
	DialogManager.start_message(dialog_position.global_position, lines)
	DialogManager.message_fully_displayed.connect(_on_message_fully_displayed)

func _on_message_fully_displayed():
	skip_hud.visible = false
	await get_tree().create_timer(0.5).timeout
	code_input.visible = true
	hud.visible = true

	# Conecta botões com segurança
	if submit_btn:
		if submit_btn.pressed.is_connected(_on_submit_btn_pressed):
			submit_btn.pressed.disconnect(_on_submit_btn_pressed)
		submit_btn.pressed.connect(_on_submit_btn_pressed)
	else:
		print("Erro: Botão de envio não encontrado!")

	if close_btn:
		if close_btn.pressed.is_connected(_on_close_btn_pressed):
			close_btn.pressed.disconnect(_on_close_btn_pressed)
		close_btn.pressed.connect(_on_close_btn_pressed)
	else:
		print("Erro: Botão de fechar não encontrado!")

	if code_input.visible:
		code_input.grab_focus()
	
	# Passando o player_instance para o game_engine
	game_engine.set_player(player)

func _on_close_btn_pressed():
	code_input.visible = false
	hud.visible = false
	hud_code_input.visible = true
	hud_dialog_box.visible = true

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

func _send_code_to_game_engine(code: String):
	if game_engine and game_engine.has_method("send_python_code"):
		game_engine.send_python_code(code, 2)
	else:
		print("Erro: GameEngine não encontrado ou função inexistente.")

func _on_goal_area_entered(area):
	call_deferred("_go_to_next_level")

func _go_to_next_level():
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_hud_code_input_pressed():
	code_input.visible = true
	hud.visible = true
	hud_code_input.visible = false
	hud_dialog_box.visible = false

func _on_hud_dialog_box_pressed():
	hud_code_input.visible = false
	hud_dialog_box.visible = false
	DialogManager.start_message(dialog_position.global_position, lines)
	skip_hud.visible = true

func _on_hud_code_input_mouse_entered():
	code_input_button_label.visible = true

func _on_hud_code_input_mouse_exited():
	code_input_button_label.visible = false

func _on_hud_dialog_box_mouse_entered():
	dialog_box_button_label.visible = true

func _on_hud_dialog_box_mouse_exited():
	dialog_box_button_label.visible = false
