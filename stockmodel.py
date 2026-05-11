import json
import os
import re
from dataclasses import dataclass
from enum import IntEnum

from PySide6.QtCore import QAbstractListModel, QByteArray, QEnum, QModelIndex, Qt, Slot
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
        with open(database, "r", encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
        for item in dados:
            proddata.append(
                self.StockItem(
                    item["name"], item["quantity"], item["buyPrice"], item["sellPrice"]
                )
            )
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

    @Slot(str, result="int")
    def getEffectiveCount(self, search: str):
        products = self.m_products
        matches = 0
        accentTranslateTable = str.maketrans(
            {
                "á": "a",
                "é": "e",
                "í": "i",
                "ó": "o",
                "ú": "u",
                "â": "a",
                "ê": "e",
                "ô": "o",
                "ã": "a",
                "õ": "o",
                "à": "a",
            }
        )
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if search == "":
            return len(products)
        else:
            for item in products:
                fProdName = re.sub(
                    r"\W", "_", item.name.lower().translate(accentTranslateTable)
                )
                if fSearch in fProdName:
                    matches += 1
            return matches

    @Slot(int, str, result="QVariantMap")
    def get(self, row: int, search: str):
        allprods = self.m_products
        product = self.m_products[row]
        accentTranslateTable = str.maketrans(
            {
                "á": "a",
                "é": "e",
                "í": "i",
                "ó": "o",
                "ú": "u",
                "â": "a",
                "ê": "e",
                "ô": "o",
                "ã": "a",
                "õ": "o",
                "à": "a",
            }
        )
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        prodsFiltered = list(
            filter(
                lambda item: (
                    fSearch
                    in re.sub(
                        r"\W", "_", item.name.lower().translate(accentTranslateTable)
                    )
                ),
                allprods,
            )
        )

        if search == "":
            return {
                "name": product.name,
                "quantity": product.quantity,
                "buyPrice": product.buyPrice,
                "sellPrice": product.sellPrice,
            }
        else:
            for item in prodsFiltered:
                return {
                    "name": prodsFiltered[row].name,
                    "quantity": prodsFiltered[row].quantity,
                    "buyPrice": prodsFiltered[row].buyPrice,
                    "sellPrice": prodsFiltered[row].sellPrice,
                }

    @Slot(result="int")
    def getTotalQuant(self):
        allprods = self.m_products
        stockTotalQuant = 0
        for item in allprods:
            stockTotalQuant += int(item.quantity)
        return stockTotalQuant

    @Slot(result="QVariantMap")
    def getMostIndividualProfit(self):
        allprods = self.m_products
        prodsSorted = sorted(
            allprods,
            key=lambda item: (
                (float(item.sellPrice) - float(item.buyPrice)) * int(item.quantity)
            ),
            reverse=True,
        )

        if len(allprods) > 2:
            profName1 = prodsSorted[0].name
            bigProf1 = (
                float(prodsSorted[0].sellPrice) - float(prodsSorted[0].buyPrice)
            ) * int(prodsSorted[0].quantity)

            profName2 = prodsSorted[1].name
            bigProf2 = (
                float(prodsSorted[1].sellPrice) - float(prodsSorted[1].buyPrice)
            ) * int(prodsSorted[1].quantity)

            return {
                "topOneName": profName1,
                "topOneProf": bigProf1,
                "topTwoName": profName2,
                "topTwoProf": bigProf2,
            }

    @Slot(result="QVariantMap")
    def getLeastIndividualProfit(self):
        allprods = self.m_products
        prodsSorted = sorted(
            allprods,
            key=lambda item: (
                (float(item.sellPrice) - float(item.buyPrice)) * int(item.quantity)
            ),
        )

        if len(allprods) > 2:
            profName1 = prodsSorted[0].name
            lowProf1 = (
                float(prodsSorted[0].sellPrice) - float(prodsSorted[0].buyPrice)
            ) * int(prodsSorted[0].quantity)

            profName2 = prodsSorted[1].name
            lowProf2 = (
                float(prodsSorted[1].sellPrice) - float(prodsSorted[1].buyPrice)
            ) * int(prodsSorted[1].quantity)

            return {
                "topOneName": profName1,
                "topOneProf": lowProf1,
                "topTwoName": profName2,
                "topTwoProf": lowProf2,
            }

    @Slot(result="float")
    def getTotalStockSell(self):
        allprods = self.m_products
        totalStockSell = 0
        for item in allprods:
            totalStockSell += (float(item.sellPrice) - float(item.buyPrice)) * int(
                item.quantity
            )

        return totalStockSell

    @Slot(result="float")
    def getTotalStockCost(self):
        allprods = self.m_products
        totalStockCost = 0
        for item in allprods:
            totalStockCost += float(item.buyPrice) * int(item.quantity)

        return totalStockCost

    @Slot(int, result="QVariantMap")
    def getSortedByTotalProfit(self, row: int):
        allprods = self.m_products
        prodsSorted = sorted(
            allprods,
            key=lambda item: (
                (float(item.sellPrice) - float(item.buyPrice)) * int(item.quantity)
            ),
            reverse=True,
        )
        if row > len(allprods) - 1:
            return {"name": "null", "profit": "null", "percentage": "null"}

        totalStockProfit = 0
        for item in prodsSorted:
            totalStockProfit += (float(item.sellPrice) - float(item.buyPrice)) * int(
                item.quantity
            )

        return {
            "name": prodsSorted[row].name,
            "profit": (
                (float(prodsSorted[row].sellPrice) - float(prodsSorted[row].buyPrice))
                * int(prodsSorted[row].quantity)
            ),
            "percentage": round(
                (
                    (
                        float(prodsSorted[row].sellPrice)
                        - float(prodsSorted[row].buyPrice)
                    )
                    * int(prodsSorted[row].quantity)
                    * 100
                    / totalStockProfit
                )
            ),
        }

    @Slot(int, result="int")
    def getLowQuantityTotal(self, lowThreshold: int):
        allprods = self.m_products
        totalAmount = 0
        for item in allprods:
            if int(item.quantity) <= lowThreshold:
                totalAmount += 1

        return totalAmount

    @Slot(int, int, result="QVariantMap")
    def getSortedByStockQuantity(self, row: int, lowThreshold: int):
        allprods = self.m_products
        prodsSorted = sorted(
            allprods, key=lambda item: int(item.quantity), reverse=True
        )
        if row > len(allprods) - 1:
            return {"name": "null", "amount": "null", "percentage": "null"}

        totalStockAmount = 0
        for item in prodsSorted:
            totalStockAmount += int(item.quantity)

        return {
            "name": prodsSorted[row].name,
            "amount": int(prodsSorted[row].quantity),
            "percentage": round(
                int(prodsSorted[row].quantity) * 100 / totalStockAmount
            ),
            "needsReposition": bool(int(prodsSorted[row].quantity <= lowThreshold)),
        }

    @Slot(int, int, result="QVariantMap")
    def getLowQuantityItems(self, row: int, lowThreshold: int):
        allprods = self.m_products

        prodsSorted = sorted(allprods, key=lambda item: int(item.quantity))
        if row > len(allprods) - 1:
            return {"name": "null", "amount": "null", "percentage": "null"}

        prodsFiltered = list(
            filter(lambda item: item.quantity <= lowThreshold, prodsSorted)
        )

        return {
            "name": prodsFiltered[row].name,
            "amount": int(prodsFiltered[row].quantity),
        }

    @Slot(str, int, float, float)
    def append(self, name: str, quantity: int, buyPrice: float, sellPrice: float):
        database = os.path.join(".", "data", "db.json")

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
        database = os.path.join(".", "data", "db.json")

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
        database = os.path.join(".", "data", "db.json")

        currentData = []

        with open(database, "r", encoding="utf-8") as arquivo:
            currentData = json.load(arquivo)

        del currentData[rmIndex]

        with open(database, "w", encoding="utf-8") as arquivo:
            json.dump(currentData, arquivo, indent=4, ensure_ascii=False)

    @Slot()
    def reloadDB(self):
        self.m_products = self.load_products()
