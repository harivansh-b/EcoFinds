from db.connection import db
import random
from passlib.context import CryptContext
from jose import JWTError, jwt
from dotenv import load_dotenv
import os
from datetime import datetime,timezone,timedelta
from fastapi import HTTPException
import typing

load_dotenv()

bcrypt_context=CryptContext(schemes=["bcrypt"],deprecated="auto")

import random

async def generate_userid(username: str, db):
    base = username.lower().replace(" ", "_")

    while True:
        random_number = str(random.randint(10000, 99999))
        tempname = base + random_number
        existing = await db.user.find_one({"_id": tempname})
        if not existing:
            return tempname

def verify_password(plain_pwd, hashed_pwd):
    return bcrypt_context.verify(plain_pwd, hashed_pwd)

def get_password_hash(password):
    return bcrypt_context.hash(password)


def generate_otp():
    return str(random.randint(100000, 999999))