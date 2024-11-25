extends Node2D

@onready var text = $text
@onready var area = $area

@export var lines : Array[String] = [
	""
]

func _unhandled_input(event):
	if area.get_overlapping_bodies().size() > 0:
		text.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			text.hide()
			DialogManager.start_message(global_position, lines)
	else:
		text.hide()
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
