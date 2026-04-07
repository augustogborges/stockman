import json
import os

item = input("Digite o item: ")
quant = int(input("Digite a quantidade do item: "))

dados = {}

if os.path.exists("dB.json"):
    with open("dB.json", "r", encoding="utf-8") as dadosExist:
        try:
            dados = json.load(dadosExist)
        except json.JSONDecodeError:
            dados = {}
else:
    dados = {}

dados.update({item: quant})

with open("dB.json", "w", encoding="utf-8") as itens:
    json.dump(dados, itens, indent=4, ensure_ascii=False)

print("Dados salvos com sucesso!")