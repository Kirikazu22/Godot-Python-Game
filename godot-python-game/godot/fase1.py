def mover_personagem():
    if frente_livre():
        andar_para_frente()
    else:
        virar_para_direita()
