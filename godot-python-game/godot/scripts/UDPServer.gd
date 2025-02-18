extends Node

var udp_server: UDPServer
var port: int = 4242

func _ready():
	udp_server = UDPServer.new()
	var result = udp_server.listen(port)
	if result == OK:
		print("Servidor UDP escutando na porta", port)
	else:
		print("Erro ao iniciar o servidor UDP:", result)

func _process(delta: float) -> void:
	udp_server.poll()
	if udp_server.is_connection_available():
		var peer = udp_server.take_connection()
		var packet = peer.get_packet()
		var python_code = packet.get_string_from_utf8()
		print("Código recebido:\n", python_code)
		
		# Lógica para enviar o código ao servidor Python e retornar a resposta
		var response = handle_python_code(python_code)
		peer.put_packet(response.to_utf8_buffer())

func handle_python_code(python_code: String) -> String:
	# Evitar duplicação ao gravar respostas
	var unique_responses = []
	var response = ""

	# Processar o código
	var commands = python_code.split("\n")
	for command in commands:
		command = command.strip_edges()
		if command == "avancar()" and "FRENTE" not in unique_responses:
			unique_responses.append("FRENTE")
		elif command == "virarAEsquerda()" and "ESQUERDA" not in unique_responses:
			unique_responses.append("ESQUERDA")

	# Preparar a resposta final
	response = "\n".join(unique_responses)
	return response
