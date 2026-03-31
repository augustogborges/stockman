# This Python file uses the following encoding: utf-8
import sys
import os
import json
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QmlElement
from PySide6.QtWidgets import QApplication, QPushButton
from PySide6.QtCore import QObject, Property, Slot, Signal

from stockmodel import StockModel

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QApplication.setApplicationName("Stockman")
    engine = QQmlApplicationEngine()

    engine.addImportPath(Path(__file__).parent)
    engine.loadFromModule("stockman_py", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)               
