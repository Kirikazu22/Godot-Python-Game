extends CharacterBody2D

const AIR_FRICTION := 0.5

@export_category("Variables")
@export var _move_speed: float = 200.0
@onready var remote := $remote as RemoteTransform2D
@onready var animation = $sprite as AnimatedSprite2D


var direction : Vector2 = Vector2(0,0)
var knockback_vector := Vector2.ZERO
var state = "idle"


func _physics_process(_delta : float) -> void:
	velocity = direction * _move_speed
	
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"):
		direction.y = 1
	else:
		direction.y = 0
	
	if Input.is_action_pressed("right"):
		direction.x = 1
		animation.scale.x = 1
	elif Input.is_action_pressed("left"):
		direction.x = -1
		animation.scale.x = -1
	else:
		direction.x = 0
	
	_set_state()
	move_and_slide()


func follow_camera(camera):
	var camera_path = camera.get_path()
	remote.remote_path = camera_path
	
func _set_state():
	if direction.x != 0 or direction.y != 0:
		state = "run"
	elif direction.x == 0 and direction.y == 0 and state == "run":
		state = "idle"
	if animation.name != state:
		animation.play(state)


func _on_sprite_animation_finished():
	state = "idle"
