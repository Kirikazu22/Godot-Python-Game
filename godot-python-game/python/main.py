from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from process_python_code import process_python_code
import os

app = Flask(__name__, static_folder='dist')
CORS(app)

@app.after_request
def apply_cors(response):
    response.headers["Cross-Origin-Resource-Policy"] = "cross-origin"
    response.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains"
    response.headers["Referrer-Policy"] = "no-referrer-when-downgrade"
    return response

@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/<path:path>')
def serve_files(path):
    return send_from_directory(app.static_folder, path)

def executar_codigo(code, fase):
    """
    Executa o processamento do código Python enviado pelo jogador.
    
    Args:
        code (str): Código Python do jogador.
        fase (int): Número da fase atual.

    Returns:
        tuple: Um dicionário com a resposta ou mensagem de erro e o status HTTP.
    """
    return process_python_code(code, fase)

@app.route('/execute_code', methods=['POST'])
def execute_code():
    print("Recebi requisição do jogo!")
    try:
        data = request.get_json()
        if not data or "code" not in data:
            return jsonify({"error": "Nenhum código enviado"}), 400

        code = data["code"].strip()
        fase = int(data.get("fase", 1))

        if not code:
            return jsonify({"error": "Código vazio"}), 400

        response, status_code = executar_codigo(code, fase)
        return jsonify(response), status_code

    except Exception as e:
        print(f"Erro no servidor: {str(e)}")
        return jsonify({"error": f"Erro interno no servidor: {str(e)}"}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, threaded=True)
