import json
import os

# Lista para armazenar novos itens repetidos, se houver
novos_itens = []

# Função de entrada de dados
def adicionar_item(dados):
    while True:
        # validar item
        while True:
            item = input("Digite o item: ")
            if not item.isdigit():
                break
            else:
                print("❌ Item não pode ser apenas número!")

        # validar quantidade
        while True:
            quant = input("Digite a quantidade: ")
            if quant.isdigit():
                quant = int(quant)
                break
            else:
                print("❌ Digite apenas números!")

        # adicionar item na lista
        dados.append({
            "item": item,
            "quantidade": quant
        })

        continuar = input("Deseja adicionar mais um item? (s/n): ").lower()

        if continuar != "s":
            break
# Definição de Listar Itens
def listar_itens(dados):
    if not dados:
        print("Nenhum item encontrado.")
        return

    print("\n===== LISTA DE ITENS =====")
    
    for i, item in enumerate(dados):
        print(f"{i} - Item: {item['item']} | Quantidade: {item['quantidade']}")


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
    print("2 - Listar Itens")
    print("3 - Sair")

    opcao = input("Escolha uma opção: ")

    if opcao == "1":
        adicionar_item(dados)
        salvar_dados(dados)

    elif opcao == "2":
        listar_itens(dados)

    elif opcao == "3":
        break

    else:
        print("Opção inválida!")