extends Node

@onready var dialog_box_scene = preload("res://scenes/dialog_box.tscn")

var message_lines: Array[String] = []
var current_line := 0
var dialog_box
var dialog_box_position := Vector2.ZERO
var is_message_active := false
var can_advance_message := false
signal message_fully_displayed

func start_message(position: Vector2, lines: Array[String]) -> void:
	if is_message_active:
		return

	message_lines = lines
	current_line = 0
	dialog_box_position = position
	is_message_active = true
	_show_text()

func _show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)

	get_tree().current_scene.add_child(dialog_box)
	dialog_box.global_position = dialog_box_position

	dialog_box.call_deferred("display_text", message_lines[current_line])
	can_advance_message = false

func _on_all_text_displayed():
	can_advance_message = true
	if current_line < message_lines.size() - 1:
		var timer := Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.0
		add_child(timer)
		timer.timeout.connect(_advance_message)
		timer.start()
	else:
		# Última linha, espera um pouco e remove a caixa
		var cleanup_timer := Timer.new()
		cleanup_timer.one_shot = true
		cleanup_timer.wait_time = 1.0
		add_child(cleanup_timer)
		cleanup_timer.timeout.connect(_end_dialog)
		cleanup_timer.start()
		message_fully_displayed.emit()

func _advance_message():
	if !is_message_active or !can_advance_message:
		return

	dialog_box.queue_free()
	current_line += 1

	if current_line >= message_lines.size():
		_end_dialog()
	else:
		_show_text()

func _end_dialog():
	is_message_active = false
	current_line = 0
	if is_instance_valid(dialog_box):
		dialog_box.queue_free()
