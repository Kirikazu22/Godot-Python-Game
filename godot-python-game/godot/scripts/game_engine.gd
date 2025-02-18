extends Node

@onready var http_request : HTTPRequest
@onready var player = get_node("../player")
@onready var error_label : Label

var server_url = "http://127.0.0.1:8000"  # Endereço do servidor
var response_received: bool = false
var command_queue: Array = []
var is_executing_command: bool = false

func _ready():
	# Verifica se o nó HTTPRequest existe na cena
	http_request = get_node("HTTPRequest")  # Ajuste o caminho para o nó correto
	error_label = get_node("/root/level1/ErrorLabel") as Label  # Ajuste o caminho para o nó correto

	if error_label:
		error_label.visible = false  # Esconde a mensagem de erro inicialmente
	else:
		print("Erro: Label de erro não encontrada!")

	if http_request:
		print("HTTPRequest inicializado corretamente.")
	else:
		print("Erro: HTTPRequest não foi inicializado. Verifique se o nó existe na cena.")

# Envia código para o servidor
func send_python_code(code: String):
	if code.is_empty():
		print("Nenhum código inserido.")
		return
	
	print("Enviando código para o servidor...")
	send_message(code)

# Envia mensagem HTTP para o servidor
func send_message(message: String):
	if not http_request:
		print("Erro: HTTPRequest não inicializado.")
		return
	
	var headers = ["Content-Type: application/json"]
	var body = '{"code": "' + message + '"}'  # Ajuste o corpo para enviar o código como string JSON
	var response = http_request.request(server_url + "/execute_code", headers, HTTPClient.METHOD_POST, body)
	if response != OK:
		print("Erro ao enviar requisição HTTP")

# Processa resposta do servidor
func _on_http_request_request_completed(result, response_code, headers, body):
	response_received = true
	
	if response_code == 200:
		var response = body.get_string_from_utf8()
		print("Resposta do servidor: ", response)
		
		if response == "erro":
			show_error("Comando inválido!")
		else:
			execute_command(response)
	else:
		print("Erro ao comunicar com o servidor. Código de resposta: ", response_code)

# Executa o comando recebido do servidor
func execute_command(command: String):
	if not is_executing_command:
		is_executing_command = true
		player.execute(command)
		is_executing_command = false

# Exibe mensagem de erro na tela
func show_error(message: String):
	if error_label:
		error_label.text = message
		error_label.visible = true
	else:
		print("Erro: Label de erro não encontrada!")
