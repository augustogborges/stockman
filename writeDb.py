import json
import os

# Lista para armazenar novos itens repetidos, se houver
novos_itens = []

# Função de entrada de dados
def adicionar_item(dados):
    while True:
        item = input("Digite o item: ")
        quant = input("Digite a quantidade: ")

        dados.append({
            "item": item,
            "quantidade": quant
        })

        continuar = input("Deseja adicionar mais um item? (s/n): ").lower()

        if continuar != "s":
            break

# Definicao de salvar dados
def salvar_dados(dados):
    with open("dB.json", "w", encoding="utf-8") as arquivo:
        json.dump(dados, arquivo, indent=4, ensure_ascii=False)
    print("Itens adicionados com sucesso!")

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

# Painel principal
while True:
    print("\n===== MENU =====")
    print("1 - Adicionar item")
    print("2 - Sair")

    opcao = input("Escolha uma opção: ")

    if opcao == "1":
        adicionar_item(dados)
        salvar_dados(dados)

    elif opcao == "2":
        break

    else:
        print("Opção inválida!")