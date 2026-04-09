import bcrypt
import secrets
from ast import literal_eval

import os
import json

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

#tuplepass = passwdHasher("senha")
#print(tuplepass[0])
#print(tuplepass[1])



print(checkLogin("pão", "senha"))