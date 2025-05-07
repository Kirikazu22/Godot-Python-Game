from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS

app = Flask(__name__, static_folder='dist')

# Habilita CORS globalmente para todas as rotas
CORS(app)

# Configuração de cabeçalhos de segurança e controle de cache
@app.after_request
def apply_cors(response):
    response.headers["Cross-Origin-Resource-Policy"] = "cross-origin"
    response.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains"
    response.headers["Referrer-Policy"] = "no-referrer-when-downgrade"
    return response

# Servir a página principal do jogo
@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

# Servir arquivos estáticos (JS, CSS, WASM, etc.)
@app.route('/<path:path>')
def serve_files(path):
    return send_from_directory(app.static_folder, path)

import ast

def process_python_code(code):
    valid_commands = {"avancar()": "FRENTE", "virarAEsquerda()": "ESQUERDA"}
    responses = []
    
    # Verifica erro de sintaxe antes de processar os comandos
    try:
        ast.parse(code)  # Apenas analisa a sintaxe, sem executar nada
    except SyntaxError as e:
        return {"error": f"Erro de sintaxe na linha {e.lineno}: {e.msg}"}, 400
    
    # Processar os comandos linha por linha
    lines = code.split("\n")
    for i, line in enumerate(lines, start=1):  # Numeração começa em 1
        line = line.strip()
        if line in valid_commands:
            responses.append(valid_commands[line])
        elif line:  # Ignora linhas vazias
            return {"error": f"Erro na linha {i}: Comando inválido '{line}'"}, 400

    return {"response": responses}, 200


# Endpoint para executar comandos enviados pelo jogo
@app.route('/execute_code', methods=['POST'])
def execute_code():
    print("Recebi requisição do jogo!")
    try:
        # Verifica se o JSON foi enviado corretamente
        data = request.get_json()
        if not data or "code" not in data:
            return jsonify({"error": "Nenhum código enviado"}), 400

        code = data["code"].strip()
        if not code:
            return jsonify({"error": "Código vazio"}), 400

        # Processa o código e retorna os comandos válidos ou erro
        response, status_code = process_python_code(code)
        return jsonify(response), status_code

    except Exception as e:
        print(f"Erro no servidor: {str(e)}")  # Log do erro no servidor
        return jsonify({"error": f"Erro interno no servidor: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8000, threaded=True)
