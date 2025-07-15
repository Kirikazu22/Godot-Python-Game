import ast
from validator_fases import (
    all_mover_calls_inside_loops,
    get_loop_iterations,
    validar_fase_1,
    validar_fase_2,
    validar_fase_4
)

def process_python_code(code, fase):
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

        # Rejeita código com apenas expressões triviais (ex: só strings ou nomes)
        tem_instrucao_util = False
        for node in ast.walk(tree):
            if isinstance(node, (ast.FunctionDef, ast.For, ast.While, ast.If, ast.With, ast.Try, ast.Assign, ast.AugAssign)):
                tem_instrucao_util = True
                break
            if isinstance(node, ast.Expr):
                if not isinstance(node.value, (ast.Str, ast.Constant, ast.Name)):
                    tem_instrucao_util = True
                    break

        if not tem_instrucao_util:
            return {"error": "O código precisa conter instruções Python válidas."}, 400

    except SyntaxError as e:
        return {"error": f"Erro de sintaxe na linha {e.lineno}: {e.msg}"}, 400

    # Verifica se a fase é válida
    if fase not in valid_calls_fase:
        return {"error": "Fase inválida"}, 400

    # Validações específicas por fase
    if fase == 1:
        erro = validar_fase_1(tree)
        if erro:
            return {"error": erro}, 400

    elif fase == 2:
        erro = validar_fase_2(tree, code)
        if erro:
            return {"error": erro}, 400

    elif fase == 4:
        erro = validar_fase_4(tree, code)
        if erro:
            return {"error": erro}, 400

    commands = []

    def process_loop_body(body, multiplier=1):
        for stmt in body:
            if isinstance(stmt, ast.Expr) and isinstance(stmt.value, ast.Call):
                call = stmt.value
                if isinstance(call.func, ast.Attribute) and isinstance(call.func.value, ast.Name) and call.func.value.id == "jogador":
                    metodo = call.func.attr
                    if fase == 4 and metodo == "falar":
                        if len(call.args) == 1:
                            commands.extend([command_map["falar"]] * multiplier)
                        else:
                            raise ValueError("jogador.falar() deve receber exatamente um argumento.")
                    else:
                        call_str = ast.unparse(stmt).strip()
                        if call_str not in valid_calls_fase[fase]:
                            raise ValueError(f"Comando inválido '{call_str}'")
                        for palavra in command_map:
                            if palavra in call_str:
                                commands.extend([command_map[palavra]] * multiplier)
                else:
                    extract_valid_commands(stmt)
            else:
                extract_valid_commands(stmt)

    def extract_valid_commands(node):
        if isinstance(node, ast.FunctionDef):
            for sub in node.body:
                extract_valid_commands(sub)
        elif isinstance(node, (ast.For, ast.While)):
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
                    if len(call.args) == 1:
                        commands.append(command_map["atravessar_ponte"])
                    else:
                        raise ValueError("atravessar_ponte precisa de um argumento")
                elif fase == 3 and metodo == "abrir_porta":
                    if len(call.args) == 0:
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
                        raise ValueError("abrir_porta() não deve ter argumentos.")
                elif fase == 4 and metodo == "falar":
                    if len(call.args) == 1:
                        commands.append(command_map["falar"])
                    else:
                        raise ValueError("jogador.falar() deve receber exatamente um argumento.")
                else:
                    raise ValueError(f"Comando inválido '{ast.unparse(node).strip()}'")
            else:
                for child in ast.iter_child_nodes(node):
                    extract_valid_commands(child)

    try:
        for node in tree.body:
            extract_valid_commands(node)
    except ValueError as ve:
        return {"error": f"Erro na linha {getattr(node, 'lineno', '?')}: {ve}"}, 400

    return {"response": commands}, 200
