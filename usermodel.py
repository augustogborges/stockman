import base64
import json
import os
import platform
import random
import re
import secrets
from dataclasses import dataclass
from enum import IntEnum
from pathlib import Path

import bcrypt
from cryptography.fernet import Fernet
from PySide6.QtCore import (
    QAbstractListModel,
    QByteArray,
    QEnum,
    QModelIndex,
    Qt,
    Slot,
)
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
        "ç": "c",
    }
)

userPath = ""
keyPath = ""
dbPath = ""

match platform.system():
    case "Windows":
        keyPath = Path(os.getenv("APPDATA")) / "stockman" / "kdf.bin"
        dbPath = Path(os.getenv("APPDATA")) / "stockman" / "db.json"
        userPath = Path(os.getenv("APPDATA")) / "stockman" / "users.json"

    case "Darwin":
        keyPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "kdf.bin"
        )
        dbPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "db.json"
        )
        userPath = (
            Path.home() / "Library" / "Application Support" / "stockman" / "users.json"
        )

    case _:
        keyPath = Path.home() / ".local" / "share" / "stockman" / "kdf.bin"
        dbPath = Path.home() / ".local" / "share" / "stockman" / "db.json"
        userPath = Path.home() / ".local" / "share" / "stockman" / "users.json"


# Full scope functions
def passwdHasher(plainPass: str):
    salt = bcrypt.gensalt()
    hashPass = (
        bcrypt.hashpw(plainPass.encode("utf-8"), salt).decode("utf-8").replace("'", '"')
    )
    return hashPass


def checkHash(jsonPass: str, plainPass: str):
    passwd = jsonPass.replace('"', "'").encode("utf-8")
    return bcrypt.checkpw(plainPass.encode("utf-8"), passwd)


def usernameCreator(displayName: str):
    symbols = ["!", "@", "#", "&", "*", "-", "_"]
    usersData = getDB()
    formattedDName = ""
    if len(displayName) > 12:
        formattedDName = re.sub(
            r"\W", "_", displayName[0:11].lower().translate(accentTranslateTable)
        )
    else:
        formattedDName = re.sub(
            r"\W", "_", displayName.lower().translate(accentTranslateTable)
        )

    while True:
        username = (
            formattedDName
            + symbols[random.randint(0, 6)]
            + str(random.randint(100, 999))
        )
        check = list(filter(lambda item: item["username"] == username, usersData))
        if len(check) != 0:
            continue
        else:
            break
    return username


def getDB():
    userDatabase = userPath

    usersData = []

    with open(userDatabase, "r", encoding="utf-8") as userFileR:
        usersData = json.load(userFileR)

    return usersData


def saveDB(usersData: list):
    userDatabase = userPath
    with open(userDatabase, "w", encoding="utf-8") as userFileW:
        json.dump(usersData, userFileW, indent=4, ensure_ascii=False)


# Generate safe, random and human-unreadable key for database encryption and decryption
def createKey():
    keyFull = secrets.token_urlsafe(128)

    s1 = random.randint(0, 74)
    e1 = s1 + 96

    s2 = random.randint(0, 63)
    e2 = s2 + 32

    keyB = base64.b85encode(keyFull.encode("utf-8"))
    s1B = base64.b32encode((str(s1)).encode("utf-8"))
    e1B = base64.b32encode((str(e1)).encode("utf-8"))
    s2B = base64.b64encode((str(s2)).encode("utf-8"))
    e2B = base64.b64encode((str(e2)).encode("utf-8"))

    keyT = [
        keyB.decode("utf-8"),
        s1B.decode("utf-8"),
        e1B.decode("utf-8"),
        s2B.decode("utf-8"),
        e2B.decode("utf-8"),
    ]

    with open(keyPath, "w", encoding="utf-8") as kFW:
        kFW.write(keyT[0] + "\n")
        kFW.write(keyT[1] + "\n")
        kFW.write(keyT[2] + "\n")
        kFW.write(keyT[3] + "\n")
        kFW.write(keyT[4])


# 'Translate' the key into usable form
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


# Encrypt the database, making it unreadable and unusable
def encryptDB():
    crypter = Fernet(readKey())

    with open(dbPath, "rb") as userFileRbin:
        rawUData = userFileRbin.read()

    crypt = crypter.encrypt(rawUData)

    with open(dbPath, "wb") as userFileWbin:
        userFileWbin.write(crypt)


# Decrypt the database, rendering it readable and usable
def decryptDB():

    decrypter = ""

    while decrypter == "":
        if not readKey():
            continue
        else:
            decrypter = Fernet(readKey())

    with open(dbPath, "rb") as userFileRbin:
        rawUData = userFileRbin.read()

    decrypt = decrypter.decrypt(rawUData)

    with open(dbPath, "wb") as userFileWbin:
        userFileWbin.write(decrypt)


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
        userDatabase = userPath
        currData = []
        num = -1
        with open(userDatabase, "r", encoding="utf-8") as userFile:
            currData = json.load(userFile)
        for item in currData:
            num += 1
            fullData.append(
                self.StockUser(item["displayName"], item["username"], item["level"])
            )
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
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))
        levelnum = -1

        if level == "Estoque":
            levelnum = 2
        elif level == "Financeiro":
            levelnum = 1
        elif level == "Supervisão":
            levelnum = 0
        else:
            levelnum = -1

        if search == "" and (levelnum == -1 or level == "Cargo" or level == ""):
            return len(users)
        else:
            for item in users:
                if level == "Cargo" or levelnum == -1 or level == "":
                    if search == "":
                        return len(users)
                    if fSearch in item["username"] or fSearch in item["displayName"]:
                        matches += 1
                elif search == "" and (levelnum != -1 or level != "Cargo"):
                    if int(item["level"]) == levelnum:
                        matches += 1
                else:
                    if (
                        fSearch in item["username"] or fSearch in item["displayName"]
                    ) and int(item["level"]) == levelnum:
                        matches += 1

            return matches

    # Get user objects matching a search and/or user role filter
    @Slot(int, str, str, result="QVariantMap")
    def get(self, index: int, search: str, level: str):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))
        levelnum = -1

        if level == "Estoque":
            levelnum = 2
        elif level == "Financeiro":
            levelnum = 1
        elif level == "Supervisão":
            levelnum = 0
        else:
            levelnum = -1

        if levelnum != -1 and search == "":
            filteredUsers = list(filter(lambda item: item["level"] == levelnum, users))
        elif search != "" and levelnum == -1:
            filteredUsers = list(
                filter(lambda item: fSearch in item["username"], users)
            )
        else:
            tempArray = list(filter(lambda item: fSearch in item["username"], users))
            filteredUsers = list(
                filter(lambda item: item["level"] == levelnum, tempArray)
            )

        if search == "" and (levelnum == -1 or level == "Cargo"):
            return {
                "displayName": users[index]["displayName"],
                "username": users[index]["username"],
                "level": users[index]["level"],
            }
        else:
            for item in filteredUsers:
                return {
                    "displayName": filteredUsers[index]["displayName"],
                    "username": filteredUsers[index]["username"],
                    "level": filteredUsers[index]["level"],
                }

    # Given a display ('full') name, return the users that may match (used for 'forgotten your username?' function)
    @Slot(str, int, result="QVariantMap")
    def findUserByName(self, search: str, index: int):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])
        fSearch = re.sub(r"\W", "_", search.lower().translate(accentTranslateTable))

        if search == "":
            return {
                "displayName": users[index]["displayName"],
                "username": users[index]["username"],
            }
        else:
            filteredUsers = list(
                filter(
                    lambda item: (
                        fSearch
                        in re.sub(
                            r"\W",
                            "_",
                            item["displayName"].lower().translate(accentTranslateTable),
                        )
                        or fSearch in item["username"]
                    ),
                    users,
                )
            )
            for item in filteredUsers:
                fDisplayName = re.sub(
                    r"\W",
                    "_",
                    item["displayName"].lower().translate(accentTranslateTable),
                )
                if fSearch in fDisplayName:
                    return {
                        "displayName": filteredUsers[index]["displayName"],
                        "username": filteredUsers[index]["username"],
                    }

    # Given a username, return the full name of the user
    @Slot(str, result=str)
    def getDisplayByUsername(self, username: str):
        usersData = getDB()
        if username:
            filteredUsers = list(
                filter(
                    lambda item: username == item["username"],
                    usersData,
                )
            )

            return filteredUsers[0]["displayName"]

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

        decryptDB()

    # Create the first user, who is a supervisor/admin by default
    @Slot(str, str)
    def setFirstUser(self, displayName: str, plainPasswd: str):
        usersData = getDB()

        hashedPass = passwdHasher(plainPasswd)
        username = usernameCreator(displayName)

        newUser = {
            "displayName": displayName,
            "username": username,
            "hashPasswd": hashedPass,
            "level": 0,
            "isTempPasswd": "false",
        }

        usersData.append(newUser)

        createKey()

        saveDB(usersData)

    # Set the properties for a new user
    @Slot(str, result="QVariantMap")
    def genNewUser(self, displayName: str):

        username = usernameCreator(displayName)

        passgen = username + " " + str(random.randint(1000, 9999))
        passgenstrfull = (
            base64.b32encode(passgen.encode("utf-8")).decode("utf-8").replace("'", '"')
        )
        randnum = random.randint(0, len(passgenstrfull) - 13)
        passgenstr = passgenstrfull[randnum : (randnum + 12)]
        passgenhash = passwdHasher(passgenstr)

        return {
            "displayName": displayName,
            "username": username,
            "hashedPasswd": passgenhash,
            "plainPasswd": passgenstr,
        }

    # These two functions need to be separate for UI display purposes

    # Append that new user to the database
    @Slot(str, str, str, int)
    def appendNewUser(
        self, displayName: str, username: str, hashedPasswd: str, level: int
    ):
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
    @Slot(str, bool, bool, int, result=str)
    def editUser(self, username: str, doCHPasswd: bool, doCHLevel: bool, newLevel: int):
        usersData = getDB()

        levelFilter = list(filter(lambda item: item["level"] == 0, usersData))
        if (
            len(levelFilter) == 1
            and levelFilter[0]["username"] == username
            and newLevel != 0
        ):
            return "oneSudoExc"

        def getTarget(tlist: list, name: str):
            n = 0
            while n < len(tlist):
                if tlist[n]["username"] == name:
                    return n
                n += 1

        target = getTarget(usersData, username)

        if doCHLevel:
            usersData[target]["level"] = newLevel

        if doCHPasswd:
            usersData[target]["isTempPasswd"] = "true"
            passgenedit = username + " " + str(random.randint(1000, 9999))
            passgeneditstrfull = (
                base64.b32encode(passgenedit.encode("utf-8"))
                .decode("utf-8")
                .replace("'", '"')
            )
            randnumedit = random.randint(0, len(passgeneditstrfull) - 13)
            passgeneditstr = passgeneditstrfull[randnumedit : (randnumedit + 12)]
            passgenedithash = passwdHasher(passgeneditstr)
            usersData[target]["hashedPasswd"] = passgenedithash
            return passgeneditstr

        saveDB(usersData)
        return "changed"

    # Allow a supervisor to remove a user
    @Slot(int)
    def rmUser(self, rmIndex):
        usersData = getDB()
        users = sorted(usersData, key=lambda item: item["username"])

        if (users[rmIndex]):
            del users[rmIndex]
            saveDB(users)

    # Handle the login process
    @Slot(str, str, result=str)
    def checkLogin(self, loginUsername: str, loginPasswd: str):
        usersData = getDB()

        matchvar = False

        for item in usersData:
            if loginUsername == item["username"]:
                matchvar = True

                if item["isTempPasswd"] == "true":
                    if checkHash(item["hashPasswd"], loginPasswd):
                        return "senha temp correta"
                    else:
                        return "senha incorreta"

                else:
                    if checkHash(item["hashPasswd"], loginPasswd):
                        try:
                            decryptDB()
                            return "senha correta"
                        except:
                            return "senha correta"
                    else:
                        return "senha incorreta"

        if matchvar == False:
            return "usuario invalido"
        else:
            matchvar = False

    # Reload main users object
    @Slot()
    def reloadDB(self):
        self.objUsers = self.loadUsers()
