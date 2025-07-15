import ast

def all_mover_calls_inside_loops(tree):
    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
            if isinstance(node.func.value, ast.Name) and node.func.value.id == "jogador" and node.func.attr == "mover":
                parents = []
                current = node
                while hasattr(current, 'parent'):
                    current = current.parent
                    parents.append(current)
                if not any(isinstance(p, (ast.For, ast.While)) for p in parents):
                    return False
    return True

def get_loop_iterations(node, fase):
    def erro(msg):
        lineno = getattr(node, "lineno", "?")
        raise ValueError(f"Erro na linha {lineno}: {msg}")

    if isinstance(node, ast.For):
        if isinstance(node.iter, ast.Call) and isinstance(node.iter.func, ast.Name) and node.iter.func.id == "range":
            args = node.iter.args
            if len(args) == 1 and isinstance(args[0], ast.Constant):
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

def validar_fase_1(tree):
    if not all_mover_calls_inside_loops(tree):
        return "Você deve usar uma estrutura de repetição para atravessar o pântano. Repetir manualmente o comando 'jogador.mover(...)' pode fazer o jogador afundar. Use 'for' ou 'while' para seguir boas práticas!"
    return None

def validar_fase_2(tree, code):
    class LoopFinder(ast.NodeVisitor):
        def __init__(self):
            self.tem_loop = False
        def visit_For(self, node): self.tem_loop = True
        def visit_While(self, node): self.tem_loop = True

    loop_finder = LoopFinder()
    loop_finder.visit(tree)
    if not loop_finder.tem_loop:
        return "Use um loop ('for' ou 'while') para resolver o enigma da ponte."

    class FunctionCollector(ast.NodeVisitor):
        def __init__(self):
            self.funcoes_definidas = set()
        def visit_FunctionDef(self, node):
            self.funcoes_definidas.add(node.name)

    collector = FunctionCollector()
    collector.visit(tree)

    class PonteValidator(ast.NodeVisitor):
        def __init__(self, funcoes_definidas):
            self.funcoes_definidas = funcoes_definidas
            self.erro = None
        def visit_Call(self, node):
            if isinstance(node.func, ast.Attribute):
                if isinstance(node.func.value, ast.Name) and node.func.value.id == "jogador" and node.func.attr == "atravessar_ponte":
                    if len(node.args) == 1:
                        arg = node.args[0]
                        if isinstance(arg, ast.Call) and isinstance(arg.func, ast.Name):
                            if arg.func.id not in self.funcoes_definidas:
                                self.erro = f"A função '{arg.func.id}' usada não foi definida no seu código."
                        else:
                            self.erro = "Você deve passar o resultado de uma função que você definiu como argumento."
            self.generic_visit(node)

    validator = PonteValidator(collector.funcoes_definidas)
    validator.visit(tree)
    if validator.erro:
        return validator.erro

    class JogadorMock:
        def __init__(self):
            self.resposta = None
        def atravessar_ponte(self, valor):
            self.resposta = valor

    jogador_mock = JogadorMock()
    try:
        exec(code, {"jogador": jogador_mock})
        if jogador_mock.resposta != 1:
            return f"Resposta incorreta. Você escolheu a ponte {jogador_mock.resposta}."
    except Exception as e:
        return f"Erro ao executar o código: {e}"

    return None

def validar_fase_4(tree, code):
    tem_funcao = False
    for node in ast.walk(tree):
        if isinstance(node, (ast.For, ast.While)):
            return "Não use estruturas de repetição (for ou while) na fase 4."
        if isinstance(node, ast.FunctionDef):
            tem_funcao = True

    if not tem_funcao:
        return "Você deve definir uma função para resolver essa fase."

    class JogadorMock:
        def __init__(self):
            self.faladas = []
        def falar(self, palavra):
            self.faladas.append(palavra)

    jogador_mock = JogadorMock()
    exec_env = {"jogador": jogador_mock}
    try:
        compiled_code = compile(code, filename="<jogo>", mode="exec")
        exec(compiled_code, exec_env)
    except Exception as e:
        return f"Erro ao executar o código: {e}"

    if not jogador_mock.faladas:
        return "Você deve chamar jogador.falar() ao menos uma vez."

    if jogador_mock.faladas[-1] != "E":
        return f"A última palavra falada foi '{jogador_mock.faladas[-1]}', mas deveria ser 'E'."

    return None
