import json
import os

# Lista para armazenar novos itens repetidos, se houver
novos_itens = []

# Entrada de dados
while True:
    item = input("Digite o item: ")
    quant = input("Digite a quantidade do item: ")

    novos_itens.append({
        "item": item,
        "quantidade": quant
    })

    continuar = input("Tem mais algum item a adicionar? (s/n): ").lower()
    if continuar != "s":
        break

# Carregar dados existentes
dados = []

if os.path.exists("dB.json"):
    with open("dB.json", "r", encoding="utf-8") as arquivo:
        try:
            dados = json.load(arquivo)
        except:
            dados = []

# Junta os dados antigos com os novos
dados.extend(novos_itens)

# Salvar no JSON
with open("dB.json", "w", encoding="utf-8") as arquivo:
    json.dump(dados, arquivo, indent=4, ensure_ascii=False)

print("Dados salvos com sucesso!")