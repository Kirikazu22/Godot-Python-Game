extends Node

var current_level
var http_request: HTTPRequest
var player_instance
var fila_comandos: Array = []
var executando_comandos: bool = false

func _ready():
	# Cria um nó HTTPRequest e conecta seu sinal de conclusão.
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

func set_player(player):
	player_instance = player

func set_current_level(level):
	current_level = level

# Nova função para enviar código ao servidor Flask
func send_python_code(code: String, fase):
	if code.is_empty():
		print("Erro: Código vazio enviado!")
		return

	print("Enviando código para o servidor:", code)

	var body = JSON.stringify({"code": code, "fase": fase})
	var headers = ["Content-Type: application/json"]

	var error = http_request.request("http://127.0.0.1:8000/execute_code", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Erro na requisição HTTP:", error)

func _processar_fila():
	if fila_comandos.is_empty():
		executando_comandos = false
		return

	var comando = fila_comandos.pop_front()
	_execute_command(comando)

	# Aguarda 0.5 segundos antes de executar o próximo comando
	await get_tree().create_timer(0.5).timeout
	_processar_fila()

# Função chamada quando a requisição HTTP for completada.
func _http_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()

	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var response = json.get_data()

			if "response" in response:
				#for command in response["response"]:
					#_execute_command(command)
				fila_comandos = response["response"]
				executando_comandos = true
				_processar_fila()
				
				# Exibir mensagem de sucesso
				if current_level:
					current_level.exibir_mensagem_erro("Comandos executados com sucesso!")
			else:
				if current_level:
					current_level.exibir_mensagem_erro("Erro: resposta inválida do servidor")
		else:
			if current_level:
				current_level.exibir_mensagem_erro("Erro ao processar resposta do servidor.")
	
	elif response_code == 400:
		var json = JSON.new()
		var parse_result = json.parse(response_text)

		if parse_result == OK:
			var response = json.get_data()
			if "error" in response:
				
				if current_level:
					current_level.exibir_mensagem_erro(response["error"])  # Exibe o erro exato do servidor
			else:
				if current_level:
					current_level.exibir_mensagem_erro("Erro 400: Resposta inválida do servidor.")
		else:
			if current_level:
				current_level.exibir_mensagem_erro("Erro ao processar mensagem de erro do servidor.")

	else:
		if current_level:
			current_level.exibir_mensagem_erro("Erro ao comunicar com o servidor. Código: " + str(response_code))

# Função para executar o comando e mover o jogador
func _execute_command(command):
	if command == "DIREITA":
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
	
	elif command == "ESQUERDA":
		player_instance.moverParaEsquerda()
	
	elif command == "CIMA":
		player_instance.moverParaCima()
	
	elif command == "BAIXO":
		player_instance.moverParaBaixo()
	
	#ADICIONAR COMANDOS DAS PRÓXIMAS FASES
	elif command == "ATRAVESSAR_PONTE":
		await get_tree().create_timer(0.5).timeout
		player_instance.moverParaCima()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
		await get_tree().create_timer(0.5).timeout
		player_instance.avancar()
	
	elif command == "ABRIR_PORTA":
		await get_tree().create_timer(0.5).timeout
		player_instance.moverParaCima()
		await get_tree().create_timer(0.5).timeout
		player_instance.moverParaCima()
	
	else:
		print("Comando inválido:", command)
