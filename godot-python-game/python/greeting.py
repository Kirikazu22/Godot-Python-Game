import socket
from difflib import SequenceMatcher
from constants import SERVER_IP, SERVER_PORT

# Modelos de códigos Python para comparação
MODEL_CODES = [
    """import socket
from constants import SERVER_IP, SERVER_PORT

client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.settimeout(1)

client_socket.sendto("Hello from Python!".encode(), (SERVER_IP, SERVER_PORT))

data, (recv_ip, recv_port) = client_socket.recvfrom(1024)
print(f"Received: '{data.decode()}' {recv_ip}:{recv_port}")"""
]

def compare_code(input_code):
    """Compara o código recebido com os modelos e retorna a maior semelhança."""
    best_match = 0
    for model_code in MODEL_CODES:
        similarity = SequenceMatcher(None, input_code, model_code).ratio()
        best_match = max(best_match, similarity)
    return best_match

# Configuração do socket UDP
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind((SERVER_IP, SERVER_PORT))

print(f"Servidor rodando em {SERVER_IP}:{SERVER_PORT}...")

while True:
    # Recebe código Python da Godot
    data, addr = server_socket.recvfrom(65507)
    received_code = data.decode('utf-8')

    print(f"Código recebido de {addr}:\n{received_code}")

    # Compara o código recebido com os modelos
    similarity = compare_code(received_code)
    if similarity == 1.0:
        response = "O código está correto!"
    else:
        response = f"A semelhança com o modelo é de {similarity * 100:.2f}%."

    # Envia a resposta de volta para a Godot
    server_socket.sendto(response.encode('utf-8'), addr)
    print(f"Resposta enviada para {addr}: {response}")