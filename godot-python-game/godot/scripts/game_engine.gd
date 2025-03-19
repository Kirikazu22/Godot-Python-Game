extends Node

var http_request: HTTPRequest
var player_instance
var level1_instance

func _ready():
	# Cria um nó HTTPRequest e conecta seu sinal de conclusão.
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)

func set_player(player):
	player_instance = player
	
func set_level1(level1):
	level1_instance = level1

# Nova função para enviar código ao servidor Flask
func send_python_code(code: String):
	if code.is_empty():
		print("Erro: Código vazio enviado!")
		return
	
	print("Enviando código para o servidor:", code)
	
	# Prepara o corpo da requisição POST com o código a ser enviado
	var body = JSON.stringify({"code": code})

	# Define os cabeçalhos corretamente
	var headers = ["Content-Type: application/json"]

	# Envia a requisição POST para o servidor Flask
	var error = http_request.request("http://127.0.0.1:8000/execute_code", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Erro na requisição HTTP:", error)

# Função chamada quando a requisição HTTP for completada.
func _http_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()

	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(response_text)
		
		if parse_result == OK:
			var response = json.get_data()

			if "response" in response:
				for command in response["response"]:
					_execute_command(command)
				
				# Exibir mensagem de sucesso
				if level1_instance:
					level1_instance.exibir_mensagem_erro("Comandos executados com sucesso!")
			else:
				if level1_instance:
					level1_instance.exibir_mensagem_erro("Erro: resposta inválida do servidor")
		else:
			if level1_instance:
				level1_instance.exibir_mensagem_erro("Erro ao processar resposta do servidor.")
	
	elif response_code == 400:
		var json = JSON.new()
		var parse_result = json.parse(response_text)

		if parse_result == OK:
			var response = json.get_data()
			if "error" in response:
				if level1_instance:
					level1_instance.exibir_mensagem_erro(response["error"])  # Exibe o erro exato do servidor
			else:
				if level1_instance:
					level1_instance.exibir_mensagem_erro("Erro 400: Resposta inválida do servidor.")
		else:
			if level1_instance:
				level1_instance.exibir_mensagem_erro("Erro ao processar mensagem de erro do servidor.")

	else:
		if level1_instance:
			level1_instance.exibir_mensagem_erro("Erro ao comunicar com o servidor. Código: " + str(response_code))

# Função para executar o comando e mover o jogador
func _execute_command(command):
	if command == "FRENTE":
		#if player:
		player_instance.avancar()
		#else:
			#print("Erro: jogador não encontrado!")
	elif command == "ESQUERDA":
		#if player:
		player_instance.moverParaEsquerda()
		#else:
			#print("Erro: jogador não encontrado!")
	else:
		print("Comando inválido:", command)
