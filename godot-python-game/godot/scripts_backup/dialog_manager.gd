extends Node

const message_lines : Array[String] = [
	"Olá, aventureiro!",
	"É muito bom vê-lo por aqui",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"... COMEÇANDO!",
]

@onready var dialog_box_scene = preload("res://scenes/dialog_box.tscn")
var current_line = 0
var dialog_box
var dialog_box_position := Vector2.ZERO
var is_message_active := false
var can_advance_message := false

func start_message(position: Vector2):
	if is_message_active:
		return
	
	dialog_box_position = position
	show_text()
	is_message_active = true

func show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)
	get_tree().root.add_child(dialog_box)
	dialog_box.global_position = dialog_box_position
	# Usa call_deferred para chamar display_message após o nó estar pronto
	dialog_box.call_deferred("display_message", message_lines[current_line])
	can_advance_message = false

func _on_all_text_displayed():
	can_advance_message = true

func _unhandled_input(event):
	if(event.is_action_pressed("advance_message") && is_message_active && can_advance_message):
		dialog_box.queue_free()
		current_line += 1
		if current_line >= message_lines.size():
			is_message_active = false
			current_line = 0
			return
		show_text() 
