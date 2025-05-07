extends MarginContainer

@onready var letter_timer_display = $letter_timer_display
@onready var text_label = $label_margin/text_label

const MAX_WIDTH = 256

var text = ""
var letter_index = 0
var letter_display_timer := 0.07
var space_display_timer := 0.05
var punctuation_display_timer := 0.2

signal text_display_finished()

func display_text(text_to_display: String):
	text = text_to_display
	text_label.text = ""
	letter_index = 0
	_display_letter()

func _display_letter():
	if letter_index >= text.length():
		text_display_finished.emit()
		return

	text_label.text += text[letter_index]

	match text[letter_index]:
		"!", "?", ",", ".":
			letter_timer_display.start(punctuation_display_timer)
		" ":
			letter_timer_display.start(space_display_timer)
		_:
			letter_timer_display.start(letter_display_timer)

	letter_index += 1

func _on_letter_timer_display_timeout():
	_display_letter()
