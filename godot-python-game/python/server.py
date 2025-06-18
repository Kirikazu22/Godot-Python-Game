from flask import Flask, request, jsonify, send_from_directory  # Importa as funcionalidades principais do Flask
from flask_cors import CORS  # Permite requisições de outros domínios (CORS)
import ast  # Biblioteca usada para analisar o código Python como árvore sintática abstrata

# Inicializa a aplicação Flask, definindo a pasta 'dist' como estática (frontend)
app = Flask(__name__, static_folder='dist')
CORS(app)  # Habilita CORS para comunicação entre domínios diferentes (por ex: servidor e jogo)

# Middleware que aplica cabeçalhos de segurança e políticas de CORS
@app.after_request
def apply_cors(response):
    response.headers["Cross-Origin-Resource-Policy"] = "cross-origin"
    response.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains"
    response.headers["Referrer-Policy"] = "no-referrer-when-downgrade"
    return response

# Rota principal, que entrega o index.html do frontend
@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

# Rota que serve outros arquivos estáticos da pasta 'dist'
@app.route('/<path:path>')
def serve_files(path):
    return send_from_directory(app.static_folder, path)

# Função auxiliar que verifica se todos os comandos jogador.mover(...) estão dentro de loops
def all_mover_calls_inside_loops(tree):
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
            if isinstance(node.func.value, ast.Name) and node.func.value.id == "jogador" and node.func.attr == "mover":
                # Sobe na árvore para ver se está dentro de um loop
                parents = []
                current = node
                while hasattr(current, 'parent'):
                    current = current.parent
                    parents.append(current)
                if not any(isinstance(p, (ast.For, ast.While)) for p in parents):
                    return False  # Encontrou comando fora de loop
    return True

def get_loop_iterations(node, fase):
    def erro(msg):
        lineno = getattr(node, "lineno", "?")
        raise ValueError(f"Erro na linha {lineno}: {msg}")

    if isinstance(node, ast.For):
        if (
            isinstance(node.iter, ast.Call)
            and isinstance(node.iter.func, ast.Name)
            and node.iter.func.id == "range"
        ):
            args = node.iter.args
            if len(args) == 1 and isinstance(args[0], ast.Constant) and isinstance(args[0].value, int):
                n = args[0].value
            elif len(args) == 2 and all(isinstance(arg, ast.Constant) for arg in args):
                n = args[1].value - args[0].value
            else:
                n = None

            if n is not None:
                if fase == 1 and n != 5:
                    erro("O número de repetições está errado.")
                elif fase != 1 and n > 50:
                    erro("O número máximo de repetições permitido é 50.")
                return n

    elif isinstance(node, ast.While):
        if fase == 1:
            erro("Loops 'while' não são permitidos na fase 1.")
        if isinstance(node.test, ast.Compare):
            right = node.test.comparators[0]
            if isinstance(right, ast.Constant) and isinstance(right.value, int):
                n = right.value
                if n > 50:
                    erro("O número máximo de repetições permitido é 50.")
                return n

    return None

# Função principal que processa o código Python enviado pelo jogador
def process_python_code(code, fase):
    import ast  # Reimporta ast localmente por segurança

    # Define os comandos permitidos por fase
    valid_calls_fase = {
        1: {"jogador.mover('direita')", "jogador.mover('esquerda')", "jogador.mover('baixo')", "jogador.mover('cima')"},
        2: {"jogador.atravessar_ponte()"},
        3: {"jogador.abrir_porta()"},
        4: {"jogador.falar()"}
    }

    # Mapeia os comandos para nomes internos do jogo
    command_map = {
        "cima": "CIMA",
        "baixo": "BAIXO",
        "esquerda": "ESQUERDA",
        "direita": "DIREITA",
        "atravessar_ponte": "ATRAVESSAR_PONTE",
        "abrir_porta": "ABRIR_PORTA",
        "falar": "FALAR"
    }

    # Tenta analisar o código com AST
    try:
        tree = ast.parse(code)
        for node in ast.walk(tree):
            for child in ast.iter_child_nodes(node):
                child.parent = node

# Verificação: rejeitar código que só tem expressões triviais (como strings soltas ou nomes soltos)
        tem_instrucao_util = False
        for node in ast.walk(tree):
    # Instruções reais (controle de fluxo, chamadas de função, definições etc.)
            if isinstance(node, (ast.FunctionDef, ast.For, ast.While, ast.If, ast.With, ast.Try, ast.Assign, ast.AugAssign)):
                tem_instrucao_util = True
                break
    # Expressão válida se for chamada de função ou algo mais elaborado
            if isinstance(node, ast.Expr):
                if not isinstance(node.value, (ast.Str, ast.Constant, ast.Name)):
                    tem_instrucao_util = True
                    break

        if not tem_instrucao_util:
            return {"error": "O código precisa conter instruções Python válidas."}, 400

    except SyntaxError as e:
        return {"error": f"Erro de sintaxe na linha {e.lineno}: {e.msg}"}, 400

    # Verifica se a fase existe
    if fase not in valid_calls_fase:
        return {"error": "Fase inválida"}, 400

    # Verificação específica para fase 1 (uso de repetição obrigatório)
    if fase == 1:
        if not all_mover_calls_inside_loops(tree):
            return {
                "error": "Você deve usar uma estrutura de repetição para atravessar o pântano. "
                         "Repetir manualmente o comando 'jogador.mover(...)' pode fazer o jogador afundar. "
                         "Use 'for' ou 'while' para seguir boas práticas!"
            }, 400

    # Verificação específica para fase 4
    if fase == 4:
        # 1. Verifica se não usa for/while e se tem ao menos uma função
        tem_funcao = False
        for node in ast.walk(tree):
            if isinstance(node, (ast.For, ast.While)):
                return {"error": "Não use estruturas de repetição (for ou while) na fase 4."}, 400
            if isinstance(node, ast.FunctionDef):
                tem_funcao = True

        if not tem_funcao:
            return {"error": "Você deve definir uma função para resolver essa fase."}, 400

        # 2. Cria mock para jogador que registra as palavras faladas
        class JogadorMock:
            def __init__(self):
                self.faladas = []

            def falar(self, palavra):
                # Se a palavra for um objeto AST Constant, pega o valor
                # Mas como executamos, deve ser já a string
                self.faladas.append(palavra)

        jogador_mock = JogadorMock()
        exec_env = {"jogador": jogador_mock}

        try:
            # Compila e executa o código no escopo com o mock
            compiled_code = compile(code, filename="<jogo>", mode="exec")
            exec(compiled_code, exec_env)
        except Exception as e:
            return {"error": f"Erro ao executar o código: {e}"}, 400

        # 3. Verifica se jogador.falar foi chamado pelo menos uma vez
        if not jogador_mock.faladas:
            return {"error": "Você deve chamar jogador.falar() ao menos uma vez."}, 400

        # 4. Verifica se a última palavra falada é "E"
        if jogador_mock.faladas[-1] != "E":
            return {
                "error": f"A última palavra falada foi '{jogador_mock.faladas[-1]}', mas deveria ser 'E'."
            }, 400

    # Verificação específica para fase 2 (uso de loop e argumento dinâmico)
    if fase == 2:
        # Verifica se existe loop
        class LoopFinder(ast.NodeVisitor):
            def __init__(self):
                self.tem_loop = False
            def visit_For(self, node): self.tem_loop = True
            def visit_While(self, node): self.tem_loop = True

        loop_finder = LoopFinder()
        loop_finder.visit(tree)
        if not loop_finder.tem_loop:
            return {"error": "Use um loop ('for' ou 'while') para resolver o enigma da ponte."}, 400

        # Pega os nomes das funções definidas pelo jogador
        class FunctionCollector(ast.NodeVisitor):
            def __init__(self):
                self.funcoes_definidas = set()
            def visit_FunctionDef(self, node):
                self.funcoes_definidas.add(node.name)

        collector = FunctionCollector()
        collector.visit(tree)

        # Valida que jogador.atravessar_ponte() recebe uma chamada a uma dessas funções
        class PonteValidator(ast.NodeVisitor):
            def __init__(self, funcoes_definidas):
                self.funcoes_definidas = funcoes_definidas
                self.erro = None
            def visit_Call(self, node):
                if isinstance(node.func, ast.Attribute):
                    if isinstance(node.func.value, ast.Name) and node.func.value.id == "jogador" and node.func.attr == "atravessar_ponte":
                        if len(node.args) == 1:
                            arg = node.args[0]
                            # Verifica se o argumento é uma chamada de função definida pelo jogador
                            if isinstance(arg, ast.Call) and isinstance(arg.func, ast.Name):
                                if arg.func.id not in self.funcoes_definidas:
                                    self.erro = f"A função '{arg.func.id}' usada não foi definida no seu código."
                            else:
                                self.erro = "Você deve passar o resultado de uma função que você definiu como argumento."
                self.generic_visit(node)

        validator = PonteValidator(collector.funcoes_definidas)
        validator.visit(tree)
        if validator.erro:
            return {"error": validator.erro}, 400

        # Executa o código num ambiente isolado com um mock
        class JogadorMock:
            def __init__(self):
                self.resposta = None
            def atravessar_ponte(self, valor):
                self.resposta = valor

        jogador_mock = JogadorMock()
        try:
            exec(code, {"jogador": jogador_mock})
            if jogador_mock.resposta != 1:
                return {"error": f"Resposta incorreta. Você escolheu a ponte {jogador_mock.resposta}."}, 400
        except Exception as e:
            return {"error": f"Erro ao executar o código: {e}"}, 400

    # Lista de comandos extraídos
    commands = []

    # Processa comandos dentro de um loop, multiplicando conforme número de iterações
    def process_loop_body(body, multiplier=1):
        for stmt in body:
            if isinstance(stmt, ast.Expr) and isinstance(stmt.value, ast.Call):
                call_str = ast.unparse(stmt).strip()
                if call_str not in valid_calls_fase[fase]:
                    raise ValueError(f"Comando inválido '{call_str}'")
                for palavra in command_map:
                    if palavra in call_str:
                        commands.extend([command_map[palavra]] * multiplier)
            else:
                extract_valid_commands(stmt)

        # Extrai comandos válidos do código (recursivamente)
    def extract_valid_commands(node):
        if isinstance(node, ast.FunctionDef):
            for sub in node.body:
                extract_valid_commands(sub)
        elif isinstance(node, ast.For) or isinstance(node, ast.While):
            iterations = get_loop_iterations(node, fase)
            if iterations is not None:
                process_loop_body(node.body, iterations)
            else:
                process_loop_body(node.body, 1)
            for sub in getattr(node, 'orelse', []):
                extract_valid_commands(sub)
        elif isinstance(node, ast.If):
            for sub in node.body:
                extract_valid_commands(sub)
            for sub in getattr(node, 'orelse', []):
                extract_valid_commands(sub)
        elif isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
            call = node.value
            if isinstance(call.func, ast.Attribute) and isinstance(call.func.value, ast.Name) and call.func.value.id == "jogador":
                metodo = call.func.attr

                if fase == 1 and metodo == "mover":
                    if len(call.args) == 1 and isinstance(call.args[0], ast.Constant):
                        direcao = call.args[0].value
                        if direcao in command_map:
                            commands.append(command_map[direcao])
                        else:
                            raise ValueError(f"Direção inválida '{direcao}'")
            
                elif fase == 2 and metodo == "atravessar_ponte":
                    if len(call.args) == 1:  # Aceita qualquer tipo de argumento
                        commands.append(command_map["atravessar_ponte"])
                    else:
                        raise ValueError("atravessar_ponte precisa de um argumento")
            
                elif fase == 3 and metodo == "abrir_porta":
                    if len(call.args) == 0:
                        # Verifica se uma função de busca foi chamada anteriormente
                        buscar_chamada = any(
                            isinstance(n, ast.Expr)
                            and isinstance(n.value, ast.Call)
                            and isinstance(n.value.func, ast.Name)
                            and n.value.func.id == "buscar_senha"
                            for n in ast.walk(tree)
                        )
                        if not buscar_chamada:
                            raise ValueError("Você deve chamar a função 'buscar_senha()' antes de abrir a porta.")
                        commands.append(command_map["abrir_porta"])
                    else:
                        raise ValueError("Comando inválido: abrir_porta() não deve ter argumentos.")
                else:
                    raise ValueError(f"Comando inválido '{ast.unparse(node).strip()}'")
            else:
                for child in ast.iter_child_nodes(node):
                    extract_valid_commands(child)

    # Tenta extrair os comandos válidos do código
    try:
        for node in tree.body:
            extract_valid_commands(node)
    except ValueError as ve:
        return {"error": f"Erro na linha {getattr(node, 'lineno', '?')}: {ve}"}, 400

    return {"response": commands}, 200

# Rota que recebe requisições do jogo com o código Python do jogador
@app.route('/execute_code', methods=['POST'])
def execute_code():
    print("Recebi requisição do jogo!")
    try:
        data = request.get_json()
        if not data or "code" not in data:
            return jsonify({"error": "Nenhum código enviado"}), 400

        code = data["code"].strip()
        fase = int(data.get("fase", 1))  # Assume fase 1 como padrão

        if not code:
            return jsonify({"error": "Código vazio"}), 400

        response, status_code = process_python_code(code, fase)
        return jsonify(response), status_code

    except Exception as e:
        print(f"Erro no servidor: {str(e)}")
        return jsonify({"error": f"Erro interno no servidor: {str(e)}"}), 500

# Inicia o servidor Flask na porta 8000
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8000, threaded=True)
