from dataclasses import dataclass
from enum import IntEnum
from collections import defaultdict

import os
import json
import re

from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Stocker"
QML_IMPORT_MAJOR_VERSION = 1

class StockItem(object):
    def __init__(self, name, quantity, buyPrice, sellPrice):
        self.name = name
        self.quantity = quantity
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice

@QmlElement
class StockModel(QAbstractListModel):

    @QEnum
    class StockRole(IntEnum):
        NameRole = Qt.ItemDataRole.DisplayRole
        QuantityRole = Qt.ItemDataRole.UserRole
        BuyPriceRole = Qt.ItemDataRole.UserRole + 1
        SellPriceRole = Qt.ItemDataRole.UserRole + 2

    @dataclass
    class StockItem:
        name: str
        quantity: int
        buyPrice: float
        sellPrice: float

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.m_products = self.load_products()

    def load_products(self):
        proddata = []
        database = os.path.join(".", "data", "db.json")
        dados = []
        num = -1
        with open(database, "r", encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
        for item in dados:
            num += 1
            proddata.append(self.StockItem(item['name'], item['quantity'], item['buyPrice'], item['sellPrice']))
            print(item['name'], item['quantity'], item['buyPrice'], item['sellPrice'])
        return proddata

    def rowCount(self, parent=QModelIndex()):
        return len(self.m_products)

    def data(self, index: QModelIndex, role: int):
        row = index.row()
        if row < self.rowCount():
            product = self.m_products[row]
            if role == StockModel.StockRole.NameRole:
                return product.name
            if role == StockModel.StockRole.QuantityRole:
                return product.quantity
            if role == StockModel.StockRole.BuyPriceRole:
                return product.buyPrice
            if role == StockModel.StockRole.SellPriceRole:
                return product.sellPrice
        return None

    def roleNames(self):
        roles = super().roleNames()
        roles[StockModel.StockRole.NameRole] = QByteArray(b"name")
        roles[StockModel.StockRole.QuantityRole] = QByteArray(b"quantity")
        roles[StockModel.StockRole.BuyPriceRole] = QByteArray(b"buyPrice")
        roles[StockModel.StockRole.SellPriceRole] = QByteArray(b"sellPrice")
        return roles

    @Slot(str, result='int')
    def getEffectiveCount(self, search: str):
        products = self.m_products
        matches = 0
        accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a"})
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return len(products)
        else:
            for item in products:
                fProdName = re.sub(r"\W", "_", item.name.lower().translate(accentTranslateTable))
                if fSearch in fProdName:
                    matches += 1
            return matches

    @Slot(int, str, result='QVariantMap')
    def get(self, row: int, search: str):
        allprods = self.m_products
        product = self.m_products[row]
        accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a"})
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return {"name": product.name, "quantity": product.quantity,
                    "buyPrice": product.buyPrice, "sellPrice": product.sellPrice}
        else:
            for item in allprods: 
                fProdName = re.sub(r"\W", "_", item.name.lower().translate(accentTranslateTable))
                if (fSearch in fProdName):
                    return {"name": item.name, "quantity": item.quantity,
                        "buyPrice": item.buyPrice, "sellPrice": item.sellPrice}

    @Slot(int, result='QVariantMap')
    def getSortedByTotalProfit(self, row:int):
        allprods = self.m_products
        prodsSorted = sorted(allprods, key=lambda item: ((float(item.sellPrice) - float(item.buyPrice)) * int(item.quantity)), reverse=True)
        if (row > len(allprods) - 1):
            return {"name": "null", "profit": "null", "percentage": "null"}

        totalStockProfit = 0
        for item in prodsSorted:
            totalStockProfit += ((float(item.sellPrice) - float(item.buyPrice)) * int(item.quantity))

        return {"name": prodsSorted[row].name, "profit": ((float(prodsSorted[row].sellPrice) - float(prodsSorted[row].buyPrice)) * int(prodsSorted[row].quantity)), "percentage": round(((float(prodsSorted[row].sellPrice) - float(prodsSorted[row].buyPrice)) * int(prodsSorted[row].quantity) * 100 / totalStockProfit))}

    @Slot(str, int, float, float)
    def append(self, name: str, quantity: int, buyPrice: float, sellPrice: float):
        database =  os.path.join(".", "data", "db.json")

        existdata = []

        with open(database, "r", encoding="utf-8") as arquivo:
            existdata = json.load(arquivo)

        newAdd = {
            "name": name,
            "quantity": quantity,
            "buyPrice": buyPrice,
            "sellPrice": sellPrice,
        }

        existdata.append(newAdd)

        with open(database, "w", encoding="utf-8") as arquivo:
            json.dump(existdata, arquivo, indent=4, ensure_ascii=False)

    @Slot(int, int, float, float)
    def edit(self, index, newQuant, newBuy, newSell):
        database =  os.path.join(".", "data", "db.json")

        existdata = []

        with open(database, "r", encoding="utf-8") as arquivo:
            existdata = json.load(arquivo)

        existdata[index]["quantity"] = newQuant
        existdata[index]["buyPrice"] = newBuy
        existdata[index]["sellPrice"] = newSell

        with open(database, "w", encoding="utf-8") as arquivo:
            json.dump(existdata, arquivo, indent=4, ensure_ascii=False)

    @Slot(int)
    def eliminate(self, rmIndex):
        database =  os.path.join(".", "data", "db.json")

        currentData = []

        with open(database, "r", encoding="utf-8") as arquivo:
            currentData = json.load(arquivo)

        del currentData[rmIndex]

        with open(database, "w", encoding="utf-8") as arquivo:
            json.dump(currentData, arquivo, indent=4, ensure_ascii=False)

    @Slot()
    def reloadDB(self):
        self.m_products = self.load_products()