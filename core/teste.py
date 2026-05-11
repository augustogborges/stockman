import json
import os
import base64
import re
import random

'''item = input("Digite o item: ")
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
'''

'''username = "alex".encode('utf-8')
enc = base64.b32encode(username).decode('utf-8').replace("'", '"')
dec = base64.b32decode(enc.replace('"', "'").encode('utf-8')).decode('utf-8')
print(dec)'''

def usernameCreator():
    symbols = ["!", "@", "#", "&", "*", "-", "_"]
    usersData = [{"username": "abc!123"}, {"username": "def!123"}, {"username": "ghi!123"}]
    while True:
        #username = re.sub(r'\W', "_", input()) + symbols[random.randint(0,6)] + str(random.randint(100,999))
        username = input() + "!" + "123"
        check = list(filter(lambda item: item["username"] == username, usersData))
        if (len(check) != 0):
            continue
        else:
            break
    return username

print(usernameCreator())