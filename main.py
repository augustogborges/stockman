# This Python file uses the following encoding: utf-8
import sys
import os
import json
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import QObject, Property, Slot, Signal

class StockItem(object):
    def __init__(self, name, quantity, buyPrice, sellPrice):
        self.name = name
        self.quantity = quantity
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice

class ObjectConvert(QObject):
    #def __init__(self, data_obj: dados[0]):
    def __init__(self, data_obj: StockItem):
        super().__init__()
        self._data = data_obj

    @Property(str)
    def name(self):
        return self._data["name"]

    @Property(int)
    def quantity(self):
        return self._data["quantity"]

    @Property(float)
    def buyPrice(self):
        return self._data["buyPrice"]

    @Property(float)
    def sellPrice(self):
        return self._data["sellPrice"]

    @Property(float)
    def profit(self):
        return self._data["sellPrice"] - self._data["buyPrice"]

dados = []

def listar_itens():
    database = os.path.join(".", "data", "db.json")

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

    num = -1
    for item in dados:
        num += 1
        print("productObject" + str(num))
        print(f"Item: {item['name']}")
        print(f"Quantidade: {item['quantity']}")
        print(f"Custo: {item['buyPrice']}")
        print(f"Venda: {item['sellPrice']}")
        print("-"*30)
        engine.rootContext().setContextProperty("productObject" + str(num), ObjectConvert(dados[num]))

    engine.rootContext().setContextProperty("count", len(dados))

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(Path(__file__).parent)
    engine.loadFromModule("stockman_py", "Main")

    listar_itens()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())               
