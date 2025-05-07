import socket

# Funções que o jogador pode usar no código
def avancar():
    with open("respostas.txt", "a") as f:
        f.write("FRENTE\n")

def virarAEsquerda():
    with open("respostas.txt", "a") as f:
        f.write("ESQUERDA\n")

def validate_code(received_code):
    """
    Valida o código recebido, verificando se contém apenas comandos válidos.
    Retorna None se não houver erros, ou uma mensagem de erro caso haja.
    """
    valid_commands = {"avancar()", "virarAEsquerda()"}
    for line in received_code.split("\n"):
        line = line.strip()
        if line and line not in valid_commands:
            return f"Comando inválido encontrado: '{line}'"
    return None

def execute_code(received_code):
    """Interpreta e executa as funções do código recebido, escrevendo no arquivo 'respostas.txt'."""
    # Limpa o arquivo de respostas antes de cada execução
    try:
        with open("respostas.txt", "w") as f:
            f.write("")  # Limpa o conteúdo do arquivo antes de começar a escrever novas respostas
    except Exception as e:
        return f"Erro ao limpar arquivo de respostas: {e}"

    # Dicionário de comandos que o jogador pode usar
    commands = {
        "avancar()": avancar,
        "virarAEsquerda()": virarAEsquerda,
    }

    # Lista para armazenar as saídas de cada comando
    results = []

    # Processa cada linha do código recebido
    for line in received_code.split("\n"):
        line = line.strip()  # Remove espaços extras
        if line in commands:
            try:
                print(f"Executando comando: {line}")  # Log de depuração
                commands[line]()  # Chama a função correspondente
                results.append(f"Comando executado: {line}")
            except Exception as e:
                results.append(f"Erro ao executar comando '{line}': {e}")
        elif line:  # Se a linha não for vazia e não for válida
            results.append(f"Comando desconhecido: {line}")

    # Lê o conteúdo do arquivo de respostas para incluir na saída final
    try:
        with open("respostas.txt", "r") as file:
            responses = file.read().strip()
            if responses:
                results.append("Respostas registradas no arquivo:")
                results.append(responses)
    except Exception as e:
        results.append(f"Erro ao ler arquivo de respostas: {e}")

    # Retorna todas as respostas de uma vez, separadas por linha
    return "\n".join(results)

# Configuração do socket UDP
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_address = ("127.0.0.1", 4242)
server_socket.bind(server_address)

print(f"Servidor rodando em {server_address[0]}:{server_address[1]}...")

try:
    while True:
        # Recebe código Python da Godot
        try:
            data, addr = server_socket.recvfrom(1024)  # Buffer para o código
            received_code = data.decode('utf-8')
        except Exception as e:
            print(f"Erro ao receber dados: {e}")
            continue

        print(f"Código recebido de {addr}:\n{received_code}")

        # Valida o código antes de executar
        error_message = validate_code(received_code)
        if error_message:
            response = f"Erro de validação: {error_message}"
        else:
            # Executa o código e lê o arquivo de respostas
            response = execute_code(received_code)

        # Envia a resposta de volta para a Godot
        try:
            server_socket.sendto(response.encode('utf-8'), addr)
            print(f"Resposta enviada para {addr}:\n{response}")
        except Exception as e:
            print(f"Erro ao enviar resposta: {e}")
except KeyboardInterrupt:
    print("\nServidor encerrado.")
finally:
    server_socket.close()
