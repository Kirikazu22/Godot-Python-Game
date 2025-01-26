extends Control

var udp_client: PacketPeerUDP
var server_ip: String = "127.0.0.1"  # IP do servidor Python
var server_port: int = 4242  # Porta do servidor Python
var file_dialog: FileDialog
var response_received: bool = false

@onready var player = get_node("../player")  # Caminho relativo ao nó atual

var response_timer: Timer  # Variável para o timer de resposta
var command_timer: Timer  # Timer para controlar o tempo entre os comandos
var is_executing_command: bool = false  # Flag para verificar se estamos executando um comando
var command_queue: Array = []  # Fila para armazenar os comandos a serem executados

func _ready():
	# Configura o cliente UDP
	udp_client = PacketPeerUDP.new()
	udp_client.set_dest_address(server_ip, server_port)

	# Criação do Timer para aguardar resposta
	response_timer = Timer.new()
	response_timer.wait_time = 3.0  # 3 segundos para aguardar a resposta
	response_timer.one_shot = true  # Dispara apenas uma vez
	response_timer.connect("timeout", Callable(self, "_on_response_timeout"))
	add_child(response_timer)  # Adiciona o timer ao nó

	# Criação do Timer para aguardar entre comandos
	command_timer = Timer.new()
	command_timer.one_shot = true
	command_timer.connect("timeout", Callable(self, "_on_command_timeout"))
	add_child(command_timer)

	# Configuração do FileDialog para enviar arquivos Python
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.py ; Python Files", "*.* ; All Files"]  # Para ver todos os arquivos
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	add_child(file_dialog)

	# Teste de comunicação UDP
	test_udp_communication()

# Função chamada quando o tempo de resposta do servidor expira
func _on_response_timeout():
	print("Tempo de resposta do servidor esgotado.")
	if udp_client.get_available_packet_count() > 0:
		var response = udp_client.get_packet().get_string_from_utf8()
		print("Resposta recebida fora do tempo esperado:", response)
	else:
		print("Nenhuma resposta foi recebida.")

# Teste inicial de comunicação UDP
func test_udp_communication():
	var test_message = "avancar()"  # Mensagem de teste para o servidor
	var result = udp_client.put_packet(test_message.to_utf8_buffer())
	if result == OK:
		print("Mensagem de teste enviada ao servidor:", test_message)
		response_timer.start()  # Inicia o timer
	else:
		print("Falha ao enviar a mensagem de teste.")

	# Aguarda diretamente pela resposta para validar
	# Vamos agora usar a função de resposta de forma assíncrona
	await wait_for_response()

# Função para aguardar pela resposta do servidor
func wait_for_response() -> String:
	print("Aguardando resposta do servidor...")
	response_timer.start()

	# Bloqueia até que a resposta seja recebida ou o tempo esgote
	while response_timer.time_left > 0:
		if udp_client.get_available_packet_count() > 0:
			var server_response = udp_client.get_packet().get_string_from_utf8()  # Captura a resposta do servidor
			print("Resposta recebida do servidor:", server_response)
			process_response(server_response)  # Processa a resposta no game_engine
			response_timer.stop()  # Para o timer se uma resposta for recebida
			return server_response  # Retorna a resposta com o novo nome da variável

	print("Tempo de resposta do servidor esgotado.")
	return "Nenhuma resposta foi recebida."

# Processa as respostas dos comandos recebidos do servidor
func process_response(response: String):
	var commands = response.split("\n")
	for command in commands:
		command = command.strip_edges()

		# Verifica se o comando é válido antes de adicionar à fila
		if command == "FRENTE" or command == "ESQUERDA":  # Adicione outros comandos válidos aqui
			command_queue.append(command)  # Adiciona o comando válido na fila

	execute_next_command()  # Começa a execução dos comandos na fila

# Executa o próximo comando da fila
func execute_next_command():
	if command_queue.size() > 0 and !is_executing_command:
		is_executing_command = true  # Marca que estamos processando um comando
		var command = command_queue.pop_front()  # Remove o primeiro comando da fila
		print("Executando comando:", command)  # Log para depuração

		if command == "FRENTE":
			player.avancar()  # Executa o movimento para frente
		elif command == "ESQUERDA":
			player.moverParaEsquerda()  # Nova função para mover para a esquerda

		# Inicia o timer para garantir que o próximo comando será executado após um intervalo
		command_timer.start(0.5)  # Ajuste o tempo de espera entre os comandos

func _on_command_timeout():
	# Chamado quando o timer expira, permitindo a execução do próximo comando
	is_executing_command = false  # Libera a execução de novos comandos
	execute_next_command()  # Executa o próximo comando da fila

# Abre a janela de seleção de arquivo para enviar código Python
func _on_button_pressed():
	file_dialog.popup_centered()  # Abre a janela de seleção de arquivos

# Manipula o arquivo selecionado
func _on_file_selected(path: String):
	print("Arquivo selecionado:", path)
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var python_code = file.get_as_text()
			file.close()
			send_python_code(python_code)
		else:
			print("Erro ao abrir o arquivo:", path)
	else:
		print("Arquivo não encontrado:", path)

# Envia o código Python para o servidor e aguarda a resposta
func send_python_code(code: String):
	print("Enviando código para o servidor Python...")
	udp_client.put_packet(code.to_utf8_buffer())  # Corrigido: Usando to_utf8_buffer() em vez de to_utf8
	print("Código enviado:", code)
	await wait_for_response()  # Aguarda pela resposta do servidor
