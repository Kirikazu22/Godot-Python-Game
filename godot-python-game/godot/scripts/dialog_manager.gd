extends Node

@onready var dialog_box_scene = preload("res://scenes/dialog_box.tscn")

var message_lines: Array[String] = []
var current_line := 0
var dialog_box
var dialog_box_position := Vector2.ZERO
var is_message_active := false
var can_advance_message := false
var text_fully_shown := false

signal message_fully_displayed

func start_message(position: Vector2, lines: Array[String]) -> void:
	if is_message_active:
		return

	message_lines = lines
	current_line = 0
	dialog_box_position = position
	is_message_active = true
	text_fully_shown = false
	_show_text()

func _show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)

	get_tree().current_scene.add_child(dialog_box)
	dialog_box.global_position = dialog_box_position

	dialog_box.call_deferred("display_text", message_lines[current_line])
	can_advance_message = false
	text_fully_shown = false

func _on_all_text_displayed():
	can_advance_message = true
	text_fully_shown = true
	# Agora o texto está completamente visível, aguarda a tecla 'P' para prosseguir ou encerrar

func _advance_message():
	if !is_message_active or !can_advance_message:
		return

	if is_instance_valid(dialog_box):
		dialog_box.queue_free()
	current_line += 1

	if current_line >= message_lines.size():
		_end_dialog()
	else:
		_show_text()

func _end_dialog():
	is_message_active = false
	current_line = 0
	text_fully_shown = false
	if is_instance_valid(dialog_box):
		dialog_box.queue_free()
	# Emite sinal após fechar a dialog box
	message_fully_displayed.emit()

func _unhandled_input(event):
	if !is_message_active:
		return

	if event.is_action_pressed("skip_dialog"):
		if is_instance_valid(dialog_box):
			if !text_fully_shown:
				dialog_box.skip_text()
			else:
				_advance_message()
