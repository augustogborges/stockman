# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import QObject, Property, Slot

QML_IMPORT_NAME = "io.qt.textproperties"
QML_IMPORT_MAJOR_VERSION = 1

class StockItem(object):
    def __init__(self, name, quantity, buyPrice, sellPrice, profit):
        self.name = name
        self.quantity = quantity
        self.buyPrice = buyPrice
        self.sellPrice = sellPrice
        self.profit = profit

class ObjectConvert(QObject):
    def __init__(self, data_obj: StockItem):
        super().__init__()
        self._data = data_obj

    @Property(str)
    def name(self):
        return self._data.name

    @Property(int)
    def quantity(self):
        return self._data.quantity

    @Property(float)
    def buyPrice(self):
        return self._data.buyPrice

    @Property(float)
    def sellPrice(self):
        return self._data.sellPrice

    @Property(float)
    def profit(self):
        return self._data.profit

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(Path(__file__).parent)
    engine.loadFromModule("stockman_py", "Main")
    
    obj_raw = StockItem("Bolacha",3,2.0,2.5,0.5)
    obj_convert = ObjectConvert(obj_raw)
    engine.rootContext().setContextProperty("productObject", obj_convert)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())               
