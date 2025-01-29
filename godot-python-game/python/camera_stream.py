import socket
from difflib import SequenceMatcher
from constants import SERVER_IP, SERVER_PORT

# Modelos de códigos Python para comparação
MODEL_CODES = [
    # Fase 1
    """if frente_livre():
    andar_para_frente()
elif direita_livre():
    virar_para_direita()
else:
    virar_para_esquerda()""",
    # Fase 2
    """for cristal in lista_de_cristais:
    mover_ate(cristal.posicao)
    pegar_cristal()""",
    # Fase 3
    """class NPC:
    def __init__(self, nome, tipo):
        self.nome = nome
        self.tipo = tipo

    def interagir(self):
        if self.tipo == "cavaleiro":
            print(f"{self.nome} vende um mapa!")
        elif self.tipo == "soldado":
            print(f"{self.nome} dá uma chave!")

npcs = [cavaleiro, soldado, orc]
for npc in npcs:
    npc.interagir()"""
]

# Função para comparar o código recebido com os modelos
def compare_code(input_code):
    """Compara o código recebido com os modelos e retorna o índice do melhor modelo e a maior semelhança."""
    best_match_index = -1
    best_match = 0
    for index, model_code in enumerate(MODEL_CODES):
        similarity = SequenceMatcher(None, input_code, model_code).ratio()
        if similarity > best_match:
            best_match = similarity
            best_match_index = index
    return best_match_index, best_match

# Configuração do socket UDP
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind((SERVER_IP, SERVER_PORT))

print(f"Servidor rodando em {SERVER_IP}:{SERVER_PORT}...")

while True:
    # Recebe código Python da Godot
    data, addr = server_socket.recvfrom(65507)  # Buffer para o código
    received_code = data.decode('utf-8')

    print(f"Código recebido de {addr}:\n{received_code}")

    # Compara o código recebido com os modelos
    model_index, similarity = compare_code(received_code)
    if model_index == -1 or similarity < 0.5:  # Nenhum modelo suficientemente próximo
        response = "O código não corresponde a nenhum modelo conhecido."
    else:
        if similarity == 1.0:
            response = f"Parabéns! O código está 100% correto para a fase {model_index + 1}."
        else:
            response = (
                f"A semelhança com o modelo da fase {model_index + 1} é de {similarity * 100:.2f}%."
            )

    # Envia a resposta de volta para a Godot
    server_socket.sendto(response.encode('utf-8'), addr)
    print(f"Resposta enviada para {addr}: {response}")