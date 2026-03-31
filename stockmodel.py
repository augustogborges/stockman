# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

from dataclasses import dataclass
from enum import IntEnum
from collections import defaultdict

import os
import json

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

    @Slot(int, result='QVariantMap')
    def get(self, row: int):
        product = self.m_products[row]
        return {"name": product.name, "quantity": product.quantity,
                "buyPrice": product.buyPrice, "sellPrice": product.sellPrice}

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

        existdata(newAdd)

        with open(database, "w", encoding="utf-8") as arquivo:
            json.dump(existdata, arquivo, indent=4, ensure_ascii=False)