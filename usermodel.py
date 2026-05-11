from dataclasses import dataclass
from enum import IntEnum

import os
import json
import re
import bcrypt
import base64
import random

from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Authenticator"
QML_IMPORT_MAJOR_VERSION = 1

# Main User Class
class StockUser(object):
    def __init__(self, displayName, username, level):
        self.displayName = displayName
        self.username = username
        self.level = level

# Global variables
accentTranslateTable = str.maketrans({"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "â": "a", "ê": "e", "ô": "o", "ã": "a", "õ": "o", "à": "a", "ç": "c"})
filePath = os.path.join(".", "data", "users.json")

# Full scope functions 
def passwdHasher(plainPass: str):
    salt = bcrypt.gensalt()
    hashPass = bcrypt.hashpw(plainPass.encode('utf-8'), salt).decode('utf-8').replace("'", '"')
    return hashPass

def checkHash(jsonPass: str, plainPass: str):
    passwd = jsonPass.replace('"', "'").encode('utf-8')
    return bcrypt.checkpw(plainPass.encode('utf-8'), passwd)

def usernameCreator(displayName: str):
    symbols = ["!", "@", "#", "&", "*", "-", "_"]
    usersData = getDB()
    while True:
        username = re.sub(r'\W', "_", displayName.lower().translate(accentTranslateTable)) + symbols[random.randint(0,6)] + str(random.randint(100,999))
        check = list(filter(lambda item: item["username"] == username, usersData))
        if (len(check) != 0):
            continue
        else:
            break
    return username

def getDB():
    userDatabase = filePath

    usersData = []

    with open(userDatabase, "r", encoding="utf-8") as userFileR:
        usersData = json.load(userFileR)

    return usersData
    
def saveDB(usersData: list):
    userDatabase = filePath
    with open(userDatabase, "w", encoding="utf-8") as userFileW:
        json.dump(usersData, userFileW, indent=4, ensure_ascii=False)

# Main QML Bridge
@QmlElement
class UserModel(QAbstractListModel):

    # Bridge python object to QML-Usable QObject
    @QEnum
    class UserRole(IntEnum):
        DisplayNameRole = Qt.ItemDataRole.DisplayRole
        UsernameRole = Qt.ItemDataRole.UserRole
        LevelRole = Qt.ItemDataRole.UserRole + 1

    # Expose main class datatypes
    @dataclass
    class StockUser:
        displayName: str
        username: str
        level: int

    # Initialize user DB
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.objUsers = self.loadUsers()

    # Load users from DB on initialization
    def loadUsers(self):
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
    
    # Get total number of users
    def rowCount(self, parent=QModelIndex):
        usersData = getDB()
        return len(usersData)
    
    # Expose object properties to QML models
    def data(self, index: QModelIndex, role: int):
        row = index.row()
        if row < self.rowCount():
            indUser = self.objUsers[row]
            if role == UserModel.UserRole.DisplayNameRole:
                return indUser.displayName
            if role == UserModel.UserRole.NameRole:
                return indUser.username
            if role == UserModel.UserRole.LevelRole:
                return indUser.level
        return None

    # Denominate the objects for models
    def roleNames(self):
        roles = super().roleNames()
        roles[UserModel.UserRole.DisplayNameRole] = QByteArray(b"displayName")
        roles[UserModel.UserRole.UsernameRole] = QByteArray(b"username")
        roles[UserModel.UserRole.LevelRole] = QByteArray(b"level")
        return roles

    # Get number of results ('matches') for a search term and/or filter by user role
    @Slot(str, str, result=int)
    def getEffectiveCount(self, search: str, level: str):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])
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
                    if (fSearch in item["username"] or fSearch in item["displayName"]):
                        matches += 1
                elif (search == "" and (levelnum != -1 or level != "Cargo")):
                    if (int(item["level"]) == levelnum):
                        matches += 1
                else:
                    if ((fSearch in item["username"] or fSearch in item["displayName"]) and int(item["level"]) == levelnum):
                        matches += 1

            return matches
        
    # Get user objects matching a search and/or user role filter
    @Slot(int, str, str, result='QVariantMap')
    def get(self, index: int, search: str, level:str):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])
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
            filteredUsers = list(filter(lambda item: item["level"] == levelnum, users))
        elif (search != "" and levelnum == -1):
            filteredUsers = list(filter(lambda item: fSearch in item["username"], users))
        else: 
            tempArray = list(filter(lambda item: fSearch in item["username"], users))
            filteredUsers = list(filter(lambda item: item["level"] == levelnum, tempArray))

        if (search == "" and (levelnum == -1 or level == "Cargo")):
            return {"displayName": users[index]["displayName"], "username": users[index]["username"], "level": users[index]["level"]}
        else:
            for item in filteredUsers:
                return {"displayName": filteredUsers[index]["displayName"], "username": filteredUsers[index]["username"], "level": filteredUsers[index]["level"]}
        
    # Given a display ('full') name, return the users that may match (used for 'forgotten your username?' function)
    @Slot(str, int, result='QVariantMap')
    def findUserByName(self, search: str, index: int):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])
        fSearch = re.sub(r'\W', "_", search.lower().translate(accentTranslateTable))

        if (search == ""):
            return {"displayName": users[index]["displayName"], "username": users[index]["username"]}
        else:
            filteredUsers = list(filter(lambda item: (fSearch in re.sub(r'\W', "_", item["displayName"].lower().translate(accentTranslateTable)) or fSearch in item["username"]), users))
            for item in filteredUsers:
                fDisplayName = re.sub(r'\W', "_", item["displayName"].lower().translate(accentTranslateTable))
                if (fSearch in fDisplayName):
                    return {"displayName": filteredUsers[index]["displayName"], "username": filteredUsers[index]["username"]}
                
    # Given a username, return its level ('role') property (used to assign permissions for UI elements)
    @Slot(str, result=int)
    def getUserLevel(self, username: str):
        usersData = getDB()

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                return int(usersData[n]["level"])
            n += 1

    # After a user has completed their first login, with the temporary password, reset it to a user-defined password
    @Slot(str, str)
    def newUserPasswd(self, username: str, plainPasswd: str):
        usersData = getDB()

        n = 0
        while n < len(usersData):
            if usersData[n]["username"] == username:
                hashedPass = passwdHasher(plainPasswd)
                usersData[n]["isTempPasswd"] = "false"
                usersData[n]["hashPasswd"] = hashedPass
            n += 1

        saveDB(usersData)

    # Create the first user, who is a supervisor/admin by default
    @Slot(str, str)
    def setFirstUser(self, displayName: str, plainPasswd: str):
        usersData = getDB()

        hashedPass = passwdHasher(plainPasswd)

        newUser = {
            "displayName": displayName,
            "username": usernameCreator(displayName),
            "hashPasswd": hashedPass,
            "level": 0,
            "isTempPasswd": "false",
        }

        usersData.append(newUser)

        saveDB(usersData)
   
    # Set the properties for a new user
    @Slot(str, result='QVariantMap')
    def genNewUser(self, displayName: str):

        username = usernameCreator(displayName)

        passgen = username + " " + str(random.randint(1000,9999))
        passgenstrfull = base64.b32encode(passgen.encode('utf-8')).decode('utf-8').replace("'", '"')
        randnum = random.randint(0, len(passgenstrfull) - 13)
        passgenstr = passgenstrfull[randnum:(randnum + 12)]
        passgenhash = passwdHasher(passgenstr)

        return {"displayName": displayName, "username": username, "hashedPasswd": passgenhash, "plainPasswd": passgenstr}

    # These two functions need to be separate for UI display purposes

    # Append that new user to the database
    @Slot(str, str, str, int)
    def appendNewUser(self, displayName: str, username: str, hashedPasswd: str, level: int):
        usersData = getDB()

        newUser = {
            "displayName": displayName,
            "username": username,
            "hashPasswd": hashedPasswd,
            "level": level,
            "isTempPasswd": "true",
        }

        usersData.append(newUser)

        saveDB(usersData)
    
    # Allow a supervisor to edit a user's role and, if necessary, their password
    @Slot(str, bool, bool, int)
    def editUser(self, username: str, doCHPasswd: bool, doCHLevel: bool, newLevel: int):
        usersData = getDB()

        if len(usersData) == 1:
            print("Cannot change level of only existing user")
            return "oneUserExc"

        filteredUsers = list(filter(lambda item: username in item["username"]), usersData)

        try:
            len(filteredUsers) == 1
        except:
            print("Could not filter users")
        else:
            target = filteredUsers[0]

            if (doCHPasswd == True):
                target["isTempPasswd"] = "true"

            if (doCHLevel == True):
                target["level"] = newLevel

            saveDB(usersData)

    # Allow a supervisor to remove a user
    @Slot(int)
    def rmUser(self, rmIndex):
        usersData = getDB()

        try:
            usersData[rmIndex].username != "" or usersData[rmIndex].displayName != ""
        except:
            print("Could not find target user")
        else:
            del usersData[rmIndex]
            saveDB(usersData)

    # Handle the login process
    @Slot(str, str, result=str)
    def checkLogin(self, loginUsername: str, loginPasswd: str):
        usersData = getDB()

        matchvar = False

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

    # Reload main users object
    @Slot()
    def reloadDB(self):
        self.objUsers = self.loadUsers()