extends Node2D

@export_category("Variables")
@onready var animation = $sprite as AnimatedSprite2D

var move_speed: float = 100  # Velocidade do movimento
var acceleration: float = 200.0  # Aceleração ajustada para evitar velocidade excessiva
var friction: float = 300.0  # Controla a desaceleração
var distance_factor: float = 4.0  # Fator ajustado para dobrar a distância percorrida
var direction: Vector2 = Vector2.RIGHT  # Define uma direção inicial (para frente)
var velocity: Vector2 = Vector2.ZERO  # Inicializa com velocidade 0
var state: String = "idle"  # Estado da animação (idle, run)

# Função que avança o jogador
func avancar():
	print("Andando para frente...")
	if direction != Vector2.ZERO:  # Só move se a direção for válida
		velocity += direction * acceleration * 0.5 * distance_factor  # Aplica aceleração suave com fator de distância ajustado
		_set_state()  # Atualiza o estado da animação
	else:
		print("Direção inválida para movimento.")

# Função para mover o jogador para a esquerda (relativo à direção atual)
func moverParaEsquerda():
	print("Movendo para a esquerda...")
	# Aplica uma rotação de 90 graus na direção atual
	direction = direction.rotated(-PI / 2)  # Rotaciona a direção 90 graus para a esquerda
	avancar()
	direction = direction.rotated(PI / 2)

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
	# Aplica o movimento com base na velocidade atual
	position += velocity * delta
	
	# Aplica atrito natural para desacelerar aos poucos
	if velocity.length() > 0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	_set_state()  # Mantém a animação sincronizada com o movimento

# Função para seguir a câmera (mantida conforme solicitado)
func follow_camera(camera):
	var camera_path = camera.get_path()
	$remote.remote_path = camera_path
