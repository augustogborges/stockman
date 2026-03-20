import json
import os

#Entrada de dados

item = input("Digite o item: ")
quant = input("Digite a quantidade do item: ")

dados = {}

with open("dB.json", "r", encoding="utf-8") as dadosExist:
    try:
        dados = json.load(dadosExist)
    except:
        dados = {}

dados.update({item: quant})

# salvar no arquivo JSON
with open("dB.json", "w", encoding="utf-8") as itens:
    json.dump(dados, itens, indent=4, ensure_ascii=False)

print("Dados salvos com sucesso!")
