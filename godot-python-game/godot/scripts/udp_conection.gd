extends Node

var udp_client: PacketPeerUDP
var server_ip: String = "127.0.0.1"  # IP do servidor Python
var server_port: int = 4242  # Porta do servidor Python

func _ready() -> void:
	# Inicializa o cliente UDP
	udp_client = PacketPeerUDP.new()
	print("Cliente UDP inicializado.")

func send_python_code(python_code: String) -> void:
	print("Enviando código Python para o servidor...")

	# Envia o código Python ao servidor
	udp_client.set_dest_address(server_ip, server_port)
	var success = udp_client.put_packet(python_code.to_utf8_buffer())
	if success == OK:
		print("Código enviado com sucesso.")
	else:
		print("Erro ao enviar o código.")
