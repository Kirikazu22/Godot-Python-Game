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

# Processamento dos comandos enviados pelo jogo
def process_python_code(code):
    valid_commands = {"avancar()", "virarAEsquerda()"}
    responses = []
    for line in code.split("\n"):
        line = line.strip()
        if line in valid_commands:
            responses.append(f"Comando executado: {line}")
        else:
            responses.append(f"Comando inválido: {line}")
    return "\n".join(responses)

# Endpoint para executar comandos enviados pelo jogo
@app.route('/execute_code', methods=['POST'])
def execute_code():
    try:
        data = request.get_json()
        code = data.get('code', '')

        if code:
            response = process_python_code(code)
            return jsonify({"response": response}), 200
        else:
            return jsonify({"error": "Nenhum código enviado"}), 400
    except Exception as e:
        return jsonify({"error": f"Erro no servidor: {str(e)}"}), 500
        
@app.route('/<path:path>')
def serve_static_files(path):
    return send_from_directory(app.static_folder, path)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8000, threaded=True)
