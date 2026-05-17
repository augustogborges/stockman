import base64
import json
import os
import platform
import sys
from pathlib import Path

from cryptography.fernet import Fernet
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from stockmodel import StockModel
from usermodel import UserModel

folderPath = ""
keyPath = ""
dbPath = ""
userPath = ""
configPath = ""

match platform.system():
    case "Windows":
        folderPath = Path(os.getenv("APPDATA")) / "stockman"
        keyPath = Path(os.getenv("APPDATA")) / "stockman" / "kdf.bin"
        dbPath = Path(os.getenv("APPDATA")) / "stockman" / "db.json"
        userPath = Path(os.getenv("APPDATA")) / "stockman" / "users.json"
        configPath = Path(os.getenv("APPDATA")) / "stockman" / "config.json"

    case "Darwin":
        folderPath = Path.home() / "Library" / "Application Support" / "stockman"
        keyPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "kdf.bin"
        )
        dbPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "db.json"
        )
        userPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "users.json"
        )
        configPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "config.json"
        )

    case _:
        folderPath = Path.home() / ".local" / "share" / "stockman"
        keyPath = Path.home() / ".local" / "share" / "stockman" / "kdf.bin"
        dbPath = Path.home() / ".local" / "share" / "stockman" / "db.json"
        userPath = Path.home() / ".local" / "share" / "stockman" / "users.json"
        configPath = Path.home() / ".local" / "share" / "stockman" / "config.json"

if not folderPath.exists():
    folderPath.mkdir(parents=True, exist_ok=True)

for path in [keyPath, dbPath, userPath, configPath]:
    temp = []
    if not path.exists():
        with open(path, "w", encoding="utf-8") as fileW:
            json.dump(temp, fileW, indent=4, ensure_ascii=False)


def readKey():
    keyData = []

    with open(keyPath, "r", encoding="utf-8") as kFR:
        dat = kFR.read()
        keyData = dat.split("\n")

    keyData[0] = base64.b85decode(keyData[0].encode("utf-8")).decode("utf-8")
    keyData[1] = int(base64.b32decode(keyData[1].encode("utf-8")).decode("utf-8"))
    keyData[2] = int(base64.b32decode(keyData[2].encode("utf-8")).decode("utf-8"))
    keyData[3] = int(base64.b64decode(keyData[3].encode("utf-8")).decode("utf-8"))
    keyData[4] = int(base64.b64decode(keyData[4].encode("utf-8")).decode("utf-8"))

    tKey = (
        base64.b64encode(keyData[0][int(keyData[1]) : int(keyData[2])].encode("utf-8"))
        .decode("utf-8")[keyData[3] : keyData[4]]
        .encode("utf-8")
    )

    fKey = base64.b64encode(tKey)

    return fKey


def encryptDB():
    crypter = Fernet(readKey())

    with open(dbPath, "rb") as userFileRbin:
        rawUData = userFileRbin.read()

    crypt = crypter.encrypt(rawUData)

    with open(dbPath, "wb") as userFileWbin:
        userFileWbin.write(crypt)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    QApplication.setApplicationName("Stockman")
    QApplication.setWindowIcon(QIcon("./assets/icons/stockman.ico"))
    engine = QQmlApplicationEngine()

    engine.addImportPath(Path(__file__).parent)
    engine.loadFromModule("stockman_py", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    encryptDB()
    del engine
    sys.exit(exit_code)
