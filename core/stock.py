import json 
import os

# Opção de adicionar itens
def adicionar_itens (name, quantidade, valorCusto, valorFinal):
    database =  os.path.join("..", "data", "db.json")

    if os.path.exists(database):
        with open(database, "r", encoding="utf-8") as arquivo:
            try:
                dados = json.load(arquivo)
            except json.JSONDecodeError:
                dados = []
    else:
        dados = []

    novo_item = {
        "name": name,
        "sellPrice": valorFinal,
        "buyPrice": valorCusto,
        "quantidade": quantidade
    }

    dados.append(novo_item)

    with open(database, "w", encoding="utf-8") as arquivo:
        json.dump(dados, arquivo, indent=4, ensure_ascii=False)

def listar_itens():
    database = os.path.join("..", "data", "db.json")

    if os.path.exists(database):
        with open(database, "r", encoding="utf-8") as arquivo:
            try:
                dados = json.load(arquivo)
            except json.JSONDecodeError:
                print("Banco vazio.")
                return
    else:
        print("Banco não existe.")
        return

    for item in dados:
        print(f"Nome: {item['name']}")
        print(f"Quantidade: {item['quantity']}")
        print(f"Custo: {item['buyPrice']}")
        print(f"Venda: {item['sellPrice']}")
        print("-"*30)

listar_itens()
