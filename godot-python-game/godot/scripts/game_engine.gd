extends Control

var udp_client: PacketPeerUDP
var server_ip: String = "127.0.0.1"  # IP do servidor Python
var server_port: int = 4242  # Porta do servidor Python
var file_dialog: FileDialog

func _ready():
	# Configuração do FileDialog
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.py ; Python Files", "*.* ; All Files"]  # Para ver todos os arquivos
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	add_child(file_dialog)

	# Configuração do cliente UDP
	udp_client = PacketPeerUDP.new()

# Exibe o FileDialog ao pressionar o botão
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

# Envia o conteúdo do arquivo para o servidor Python
func send_python_code(python_code: String):
	print("Enviando código Python para o servidor...")
	udp_client.set_dest_address(server_ip, server_port)
	var result = udp_client.put_packet(python_code.to_utf8_buffer())
	if result == OK:
		print("Código enviado com sucesso.")
		# Espera pela resposta do servidor
		await wait_for_response()

func wait_for_response():
	# Aguarda uma resposta do servidor
	while udp_client.get_available_packet_count() == 0:
		# Espera o próximo quadro antes de continuar
		await get_tree().create_timer(0).timeout
	
	var response = udp_client.get_packet().get_string_from_utf8()
	print("Resposta recebida do servidor:", response)
