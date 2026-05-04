from dataclasses import dataclass
from enum import IntEnum
from collections import defaultdict

import os
import json
import re
import bcrypt
import secrets
import base64

from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

def passwdHasher(plainPass: str):
    salt = bcrypt.gensalt()
    hashPass = bcrypt.hashpw(plainPass.encode('utf-8'), salt).decode('utf-8').replace("'", '"')
    passSalt = salt.decode('utf-8').replace("'", '"')
    return passSalt, hashPass

def checkHash(jsonPass: str, jsonSalt: str, plainPass: str):
    salt = jsonSalt.replace('"', "'").encode('utf-8')
    passwd = jsonPass.replace('"', "'").encode('utf-8')

    dbPass = bcrypt.hashpw(plainPass.encode('utf-8'), salt)

    return (passwd == dbPass)

QML_IMPORT_NAME = "Authenticator"
QML_IMPORT_MAJOR_VERSION = 1

class StockUser(object):
    def __init__(self, username, level):
        self.username = username
        self.level = level

@QmlElement
class UserModel(QAbstractListModel):

    @QEnum
    class UserRole(IntEnum):
        UsernameRole = Qt.ItemDataRole.DisplayRole
        LevelRole = Qt.ItemDataRole.UserRole

    @dataclass
    class StockUser:
        username: str
        level: int

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.m_users = self.load_users()

    def load_users(self):
        fullData = []
        userDatabase = os.path.join(".", "data", "users.json")
        currData = []
        num = -1
        with open(userDatabase, "r", encoding="utf-8") as userFile:
            currData = json.load(userFile)
        for item in currData:
            num += 1
            fullData.append(self.StockUser(item['username'], item['level']))
        return fullData

    def rowCount(self, parent=QModelIndex()):
        return len(self.m_users)

    def data(self, index: QModelIndex, role: int):
        row = index.row()
        if row < self.rowCount():
            indUser = self.m_users[row]
            if role == UserModel.UserRole.NameRole:
                return indUser.username
            if role == UserModel.UserRole.LevelRole:
                return indUser.level
        return None

    def roleNames(self):
        roles = super().roleNames()
        roles[UserModel.UserRole.UsernameRole] = QByteArray(b"username")
        roles[UserModel.UserRole.LevelRole] = QByteArray(b"level")
        return roles

    @Slot(str, result='int')
    def getEffectiveCount(self, search: str):
        users = self.m_users
        matches = 0
        accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a"})
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return len(users)
        else:
            for item in users:
                fUserName = re.sub(r"\W", "_", item.username.lower().translate(accentTranslateTable))
                if fSearch in fUserName:
                    matches += 1
            return matches

    @Slot(int, str, result='QVariantMap')
    def get(self, row: int, search: str):
        allusers = self.m_users
        try:
            indUser = self.m_users[row]
        except:
            return {"username": "fail"}
        accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a"})
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return {"username": indUser.username, "level": indUser.level}
        else:
            for item in allusers: 
                fUserName = re.sub(r"\W", "_", item.username.lower().translate(accentTranslateTable))
                if (fSearch in fUserName):
                    return {"username": indUser.username, "level": indUser.level}

    @Slot(str, result=int)
    def getUserLevel(self, username: str):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                return int(usersData[n]["level"])
            n += 1

    @Slot(str, result=str)
    def getTempPassForUser(self, username: str):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                return usersData[n]["tempPasswd"]
            n += 1

    @Slot(str, str)
    def newUserPasswd(self, username: str, plainPasswd: str):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                passTuple = passwdHasher(plainPasswd)
                passSalt = passTuple[0]
                hashedPass = passTuple[1]
                usersData[n]["isTempPasswd"] = "false"
                usersData[n]["tempPasswd"] = ""
                usersData[n]["passSalt"] = passSalt
                usersData[n]["hashPasswd"] = hashedPass

                with open(userDatabase, "w", encoding="utf-8") as userFileW:
                    json.dump(usersData, userFileW, indent=4, ensure_ascii=False)
            n += 1

    @Slot(str, str)
    def setFirstUser(self, username: str, plainPasswd: str):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        passTuple = passwdHasher(plainPasswd)
        passSalt = passTuple[0]
        hashedPass = passTuple[1]

        newUser = {
            "username": username,
            "passSalt": passSalt,
            "hashPasswd": hashedPass,
            "level": 0,
            "isTempPasswd": "false",
            "tempPasswd": ""
        }

        usersData.append(newUser)

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)    

    @Slot(str, int)
    def newUser(self, username: str, level: int):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        newUser = {
            "username": username,
            "passSalt": "",
            "hashPasswd": "",
            "level": level,
            "isTempPasswd": "true",
            "tempPasswd": base64.b32encode(username.encode('utf-8')).decode('utf-8').replace("'", '"')
        }

        usersData.append(newUser)

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(int, str, str, int)
    def editUser(self, index, newName, newPlainPasswd, newLevel):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        hashedPass = passwdHasher(newPlainPasswd)

        usersData[index]["username"] = newName
        usersData[index]["hashPasswd"] = hashedPass
        usersData[index]["level"] = newLevel

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(int)
    def rmUser(self, rmIndex):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        del usersData[rmIndex]

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(str, str, result=str)
    def checkLogin(self, loginUsername: str, loginPasswd: str):
        userDatabase =  os.path.join(".", "data", "users.json")

        usersData = []

        matchvar = False

        username = loginUsername

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        for item in usersData:
            if (username in item["username"]):
                matchvar = True

                if (item["isTempPasswd"] == "true"):
                    if (base64.b32decode((loginPasswd.replace('"', "'").encode('utf-8'))).decode('utf-8') == item["username"]):
                        return "senha temp correta"
                    else:
                        return "senha incorreta"
                
                else:
                    if (checkHash(item["hashPasswd"], item["passSalt"], loginPasswd)):
                        return "senha correta"
                    else:
                        return "senha incorreta"

        if (matchvar == False):
            return "usuario invalido"
        else:
            matchvar = False

    @Slot()
    def reloadDB(self):
        self.m_users = self.load_users()