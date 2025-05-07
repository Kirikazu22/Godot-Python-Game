* O Enigma das Pontes — Jogo Educacional com Python e Godot 4

Este projeto é um jogo educacional desenvolvido com [Godot 4](https://godotengine.org/) que visa ensinar lógica de programação para iniciantes por meio de desafios interativos. Os jogadores avançam pelas fases escrevendo comandos em Python, que são interpretados e transformados em ações no jogo — como mover o personagem, interagir com objetos ou resolver enigmas.

Objetivo

O objetivo do jogo é proporcionar uma forma lúdica e interativa de aprender programação básica, utilizando estruturas como `if`, operadores de comparação, entrada com `input()` e lógica condicional aplicada a desafios visuais.

Funcionamento geral

1. O jogador digita comandos Python no campo de entrada.
2. O código é enviado ao servidor, que executa o script de forma controlada.
3. A resposta do servidor é enviada de volta para o jogo.
4. O jogador se move ou recebe feedback visual e textual dependendo do resultado da execução.

Modificações

1. Validação de código Python
Agora o jogo impede a execução de scripts inválidos. Isso garante que apenas códigos que realmente tentam resolver o enigma sejam aceitos.

2. Exibição de erros
Mensagens de erro de código Python (ex: erro de sintaxe ou comando não suportado) são agora exibidas de forma clara para o jogador, com feedback adequado na interface.

Tecnologias utilizadas

- [Godot Engine 4.x](https://godotengine.org/)
- Python 3 (executado em servidor via socket UDP)
- GDScript
- HTML5 (versão exportada para Web)
