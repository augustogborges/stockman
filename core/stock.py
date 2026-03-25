import json 
import os

# Opção de adicionar itens
def adicionar_itens (item, quantidade, valorCusto, valorFinal):
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
        "item": item,
        "valor_venda": valorFinal,
        "preco_custo": valorCusto,
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
        print(f"Item: {item['item']}")
        print(f"Quantidade: {item['quantidade']}")
        print(f"Custo: {item['preco_custo']}")
        print(f"Venda: {item['valor_venda']}")
        print("-"*30)

adicionar_itens("vaca leiteira", 50, 1400, 3000)
listar_itens()
