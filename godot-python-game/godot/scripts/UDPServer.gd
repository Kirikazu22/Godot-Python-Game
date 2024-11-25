extends Node

var udp_server: UDPServer
var udp_client: PacketPeerUDP  # Cliente UDP para enviar ao Python
var port: int = 4242
var python_ip: String = "127.0.0.1"  # IP do servidor Python
var python_port: int = 4243         # Porta do servidor Python

func _ready():
	# Inicializa o servidor UDP para escutar na porta especificada
	udp_server = UDPServer.new()
	var result = udp_server.listen(port)
	if result == OK:
		print("Servidor UDP escutando na porta", port)
	else:
		print("Erro ao iniciar o servidor UDP:", result)
	
	# Inicializa o cliente UDP para enviar código ao servidor Python
	udp_client = PacketPeerUDP.new()

func _process(delta: float) -> void:
	# Escuta conexões do cliente
	udp_server.poll()
	if udp_server.is_connection_available():
		var peer: PacketPeerUDP = udp_server.take_connection()
		var packet = peer.get_packet()
		var python_code = packet.get_string_from_utf8()
		print("Código Python recebido:\n", python_code)
		
		# Envia o código Python para o servidor Python para processamento
		var response = send_code_to_python(python_code)

		# Envia a resposta do servidor Python de volta para o cliente
		peer.put_packet(response.to_utf8_buffer())

func send_code_to_python(python_code: String) -> String:
	# Envia o código Python para o servidor Python via UDP e recebe a resposta
	udp_client.set_dest_address(python_ip, python_port)
	var result = udp_client.put_packet(python_code.to_utf8_buffer())

	# Verifica se o envio foi bem-sucedido
	if result == OK:
		print("Código enviado para o servidor Python com sucesso.")
		# Agora recebe a resposta do servidor Python
		var response = ""
		if udp_client.get_available_packet_count() > 0:
			var response_packet = udp_client.get_packet()
			response = response_packet.get_string_from_utf8()
			print("Resposta recebida do servidor Python:", response)
		else:
			print("Nenhuma resposta recebida do servidor Python.")
		return response
	else:
		print("Erro ao enviar o código para o servidor Python.")
		return "Erro ao enviar código."
