from dataclasses import dataclass
from enum import IntEnum
from collections import defaultdict

import sys
sys.path.append(r'C:\Users\alexandregalvao\AppData\Roaming\msys2\mingw64\include')
sys.path.append(r'C:\Users\alexandregalvao\AppData\Roaming\msys2\mingw64\lib')

import os
import json
import re
import bcrypt
import secrets
import base64
import random
import operator

from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

def passwdHasher(plainPass: str):
    salt = bcrypt.gensalt()
    hashPass = bcrypt.hashpw(plainPass.encode('utf-8'), salt).decode('utf-8').replace("'", '"')
    return hashPass

def checkHash(jsonPass: str, plainPass: str):
    passwd = jsonPass.replace('"', "'").encode('utf-8')
    return bcrypt.checkpw(plainPass.encode('utf-8'), passwd)

accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a", "ç": "c"})

def usernameCreator(displayName: str):
    symbols = ["!", "@", "#", "&", "*", "-", "_"]
    username = re.sub(r'\W', "_", displayName.lower().translate(accentTranslateTable)) + symbols[random.randint(0,6)] + str(random.randint(100,999))
    return username

QML_IMPORT_NAME = "Authenticator"
QML_IMPORT_MAJOR_VERSION = 1

class StockUser(object):
    def __init__(self, displayName, username, level):
        self.displayName = displayName
        self.username = username
        self.level = level

@QmlElement
class UserModel(QAbstractListModel):

    @QEnum
    class UserRole(IntEnum):
        DisplayNameRole = Qt.ItemDataRole.DisplayRole
        UsernameRole = Qt.ItemDataRole.UserRole
        LevelRole = Qt.ItemDataRole.UserRole + 1

    @dataclass
    class StockUser:
        displayName: str
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
            fullData.append(self.StockUser(item['displayName'], item['username'], item['level']))
        return fullData

    def rowCount(self, parent=QModelIndex()):
        return len(self.m_users)

    def data(self, index: QModelIndex, role: int):
        row = index.row()
        if row < self.rowCount():
            indUser = self.m_users[row]
            if role == UserModel.UserRole.DisplayNameRole:
                return indUser.displayName
            if role == UserModel.UserRole.NameRole:
                return indUser.username
            if role == UserModel.UserRole.LevelRole:
                return indUser.level
        return None

    def roleNames(self):
        roles = super().roleNames()
        roles[UserModel.UserRole.DisplayNameRole] = QByteArray(b"displayName")
        roles[UserModel.UserRole.UsernameRole] = QByteArray(b"username")
        roles[UserModel.UserRole.LevelRole] = QByteArray(b"level")
        return roles

    @Slot(str, str, result=int)
    def getEffectiveCount(self, search: str, level: str):
        users = self.m_users
        matches = 0
        fSearch = re.sub(r'\W', "_", search.lower().translate(accentTranslateTable))
        levelnum = -1

        if (level == "Estoque"):
            levelnum = 2
        elif (level == "Financeiro"):
            levelnum = 1
        elif (level == "Supervisão"):
            levelnum = 0
        else:
            levelnum = -1

        if (search == "" and (levelnum == -1 or level == "Cargo" or level == "")):
            return len(users)
        else:
            for item in users:
                if (level == "Cargo" or levelnum == -1 or level == ""):
                    if (search == ""):
                        return len(users)
                    fUserName = re.sub(r'\W', "_", item.username.lower().translate(accentTranslateTable))
                    if fSearch in fUserName:
                        matches += 1
                elif (search == "" and (levelnum != -1 or level != "Cargo")):
                    if (int(item.level) == levelnum):
                        matches += 1
                else:
                    fUserName = re.sub(r'\W', "_", item.username.lower().translate(accentTranslateTable))
                    if (fSearch in fUserName and int(item.level) == levelnum):
                        matches += 1

            return matches
       
    @Slot(str, int, result='QVariantMap')
    def findUsers(self, search: str, index: int):
        users = sorted(self.m_users, key=lambda item: item.username)
        matches = 0
        fSearch = re.sub(r'\W', "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return {"displayName": users[index].displayName, "username": users[index].username}
        else:
            filteredUsers = list(filter(lambda item: fSearch in item, users))
            for item in filteredUsers:
                fDisplayName = re.sub(r'\W', "_", item.displayName.lower().translate(accentTranslateTable))
                if (fSearch in fDisplayName):
                    return {"displayName": filteredUsers[index].displayName, "username": filteredUsers[index].username}
               
    @Slot(int, str, str, result='QVariantMap')
    def get(self, index: int, search: str, level:str):
        allusers = self.m_users
        users = sorted(allusers, key=lambda item: item.username)
        matches = 0
        fSearch = re.sub(r'\W', "_", search.lower().translate(accentTranslateTable))
        levelnum = -1

        if (level == "Estoque"):
            levelnum = 2
        elif (level == "Financeiro"):
            levelnum = 1
        elif (level == "Supervisão"):
            levelnum = 0
        else:
            levelnum = -1

        if (levelnum != -1 and search == ""):
            filteredUsers = list(filter(lambda item: item.level == levelnum, users))
        elif (search != "" and levelnum == -1):
            filteredUsers = list(filter(lambda item: fSearch in item.username, users))
        else: 
            tempArray = list(filter(lambda item: fSearch in item.username, users))
            filteredUsers = list(filter(lambda item: item.level == levelnum, tempArray))

        if (search == "" and (levelnum == -1 or level == "Cargo")):
            return {"displayName": users[index].displayName, "username": users[index].username, "level": users[index].level}
        else:
            for item in filteredUsers:
                return {"displayName": filteredUsers[index].displayName, "username": filteredUsers[index].username, "level": filteredUsers[index].level} 

    @Slot(str, result=int)
    def getUserLevel(self, username: str):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                return int(usersData[n]["level"])
            n += 1

    @Slot(str, str)
    def newUserPasswd(self, username: str, plainPasswd: str):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                hashedPass = passwdHasher(plainPasswd)
                usersData[n]["isTempPasswd"] = "false"
                usersData[n]["hashPasswd"] = hashedPass

                with open(userDatabase, "w", encoding="utf-8") as userFileW:
                    json.dump(usersData, userFileW, indent=4, ensure_ascii=False)
            n += 1

    @Slot(str, str)
    def setFirstUser(self, displayName: str, plainPasswd: str):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        hashedPass = passwdHasher(plainPasswd)

        newUser = {
            "displayName": displayName,
            "username": usernameCreator(displayName),
            "hashPasswd": hashedPass,
            "level": 0,
            "isTempPasswd": "false",
        }

        usersData.append(newUser)

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)
   
    @Slot(str, result='QVariantMap')
    def genNewUser(self, displayName: str):

        username = usernameCreator(displayName)

        passgen = username + " " + str(random.randint(1000,9999))
        passgenstrfull = base64.b32encode(passgen.encode('utf-8')).decode('utf-8').replace("'", '"')
        randnum = random.randint(0, len(passgenstrfull) - 13)
        passgenstr = passgenstrfull[randnum:(randnum + 12)]
        passgenhash = passwdHasher(passgenstr)

        return {"displayName": displayName, "username": username, "hashedPasswd": passgenhash, "plainPasswd": passgenstr}
   
        #remember to use javascript << delete $object$.plainPasswd >> in qml after using this
        ''' assing this entire map to an object in qml (to only use the function once), then, grab the plainPasswd property to show the password in plain in the step after creating the user, then, call the appendNewUser python func with this $object$ displayname, username, hashedPasswd and the level inputfield text'''

    @Slot(str, str, str, int)
    def appendNewUser(self, displayName: str, username: str, hashedPasswd: str, level: int):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        newUser = {
            "displayName": displayName,
            "username": username,
            "hashPasswd": hashedPasswd,
            "level": level,
            "isTempPasswd": "true",
        }

        usersData.append(newUser)

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(int, bool, int)
    def editUser(self, index: int, doCHPasswd: bool, newLevel: int):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
                usersData = json.load(userFile)

        if doCHPasswd == True:
            usersData[index]["isTempPasswd"] = "true"
        usersData[index]["level"] = newLevel

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
                json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(int)
    def rmUser(self, rmIndex):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        del usersData[rmIndex]

        with open(userDatabase, "w", encoding="utf-8") as userFileW:
            json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

    @Slot(str, str, result=str)
    def checkLogin(self, loginUsername: str, loginPasswd: str):
        userDatabase = os.path.join(".", "data", "users.json")

        usersData = []

        matchvar = False

        with open(userDatabase, "r", encoding="utf-8") as userFile:
            usersData = json.load(userFile)

        for item in usersData:
            if (loginUsername == item["username"]):
                matchvar = True

                if (item["isTempPasswd"] == "true"):
                    if (checkHash(item["hashPasswd"], loginPasswd)):
                        return "senha temp correta"
                    else:
                        return "senha incorreta"
             
                else:
                    if (checkHash(item["hashPasswd"], loginPasswd)):
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