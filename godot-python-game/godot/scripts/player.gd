extends Node2D

@export_category("Variables")
@onready var animation = $sprite as AnimatedSprite2D

var move_speed: float = 100  # Velocidade do movimento
var direction: Vector2 = Vector2.RIGHT  # Define uma direção inicial (para frente)
var velocity: Vector2 = Vector2.ZERO  # Inicializa com velocidade 0
var state: String = "idle"  # Estado da animação (idle, run)
var distance_factor: float = 2.0  # Fator para aumentar a distância de movimento (padrão é 1.0)

# Função que avança o jogador
func avancar():
	print("Movendo para frente... com direção:", direction)
	if direction != Vector2.ZERO:  # Só move se a direção for válida
		velocity = direction * move_speed * distance_factor  # Aumenta a distância percorrida, sem alterar a velocidade
		_set_state()  # Atualiza o estado da animação
	else:
		print("Direção inválida para movimento.")

# Função para mover o jogador para a esquerda (relativo à direção atual)
func moverParaEsquerda():
	print("Movendo para a esquerda... com direção:", direction)
	# Aplica uma rotação de 90 graus na direção atual
	direction = direction.rotated(-PI / 2)  # Rotaciona a direção 90 graus para a esquerda
	velocity = direction * move_speed * distance_factor  # Movimento para a esquerda
	direction = direction.rotated(PI / 2)
	_set_state()  # Atualiza o estado da animação

# Atualiza a animação com base no estado de movimento
func _set_state():
	if velocity == Vector2.ZERO:
		state = "idle"
	else:
		state = "run"

	if animation.name != state:
		animation.play(state)

# Atualiza a posição do jogador com base na velocidade e movimento
func _process(delta):
	# Fazendo a desaceleração gradual do movimento com move_toward
	if velocity != Vector2.ZERO:
		position += velocity * delta  # Atualiza a posição com a velocidade calculada
		# Reduz a velocidade na direção X e Y até que chegue a 0
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
		velocity.y = move_toward(velocity.y, 0, move_speed * delta)
	else:
		velocity = Vector2.ZERO  # Se o jogador não está se movendo, zera a velocidade
		animation.play("idle")

# Função para seguir a câmera (mantida conforme solicitado)
func follow_camera(camera):
	var camera_path = camera.get_path()
	$remote.remote_path = camera_path
