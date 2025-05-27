extends Node2D

@export_category("Variables")
@onready var animation = $sprite as AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT
var state: String = "idle"
var tween: Tween  # Guardamos uma referência ao tween atual

func avancar():
	print("Andando para frente...")
	if direction != Vector2.ZERO:
		var deslocamento = direction.normalized() * 100
		tween = create_tween()
		tween.tween_property(self, "position", position + deslocamento, 0.5)
		tween.connect("finished", Callable(self, "_on_tween_finished"))
		_set_state("run")
	else:
		print("Direção inválida para movimento.")

func moverParaCima():
	print("Movendo para a esquerda...")
	if direction != Vector2.ZERO:
		var deslocamento = direction.rotated(-PI / 2) * 135
		tween = create_tween()
		tween.tween_property(self, "position", position + deslocamento, 0.5)
		tween.connect("finished", Callable(self, "_on_tween_finished"))
		_set_state("run")
	else:
		print("Direção inválida para movimento.")

func moverParaBaixo():
	print("Movendo para baixo...")
	direction = Vector2.DOWN # Direção para baixo
	avancar()

func _set_state(novo_estado: String):
	if animation.name != novo_estado:
		animation.play(novo_estado)
	state = novo_estado

func _on_tween_finished():
	_set_state("idle")

func _ready():
	_set_state("idle")

func follow_camera(camera):
	var camera_path = camera.get_path()
	$remote.remote_path = camera_path
