import json
import os

# carrega estoque do banco de dados .json
def carregar_estoque():
    database = os.path.join("..", "data", "db.json")

    if os.path.exists(database):
        with open(database, "r", encoding="utf-8") as arquivo:
            try:
                dados = json.load(arquivo)
                return dados
            except json.JSONDecodeError:
                return []
    return []
