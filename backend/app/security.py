import base64
import datetime
import hashlib
import os

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .config import JWT_ALGORITHM, JWT_EXPIRES_MINUTES, JWT_SECRET

bearer = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    salt = os.urandom(16)
    dk = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 100_000)
    return base64.b64encode(salt + dk).decode("ascii")


def verify_password(password: str, hashed: str) -> bool:
    try:
        raw = base64.b64decode(hashed)
        salt, dk = raw[:16], raw[16:]
    except Exception:
        return False
    return hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 100_000) == dk


def create_token(payload: dict) -> str:
    to_encode = payload.copy()
    to_encode["exp"] = datetime.datetime.utcnow() + datetime.timedelta(minutes=JWT_EXPIRES_MINUTES)
    return jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> dict:
    return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])


def _current(credentials: HTTPAuthorizationCredentials) -> dict:
    if credentials is None:
        raise HTTPException(status_code=401, detail="Missing authorization token")
    try:
        return decode_token(credentials.credentials)
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def current_admin(credentials: HTTPAuthorizationCredentials = Depends(bearer)) -> dict:
    payload = _current(credentials)
    if payload.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return payload


def current_user(credentials: HTTPAuthorizationCredentials = Depends(bearer)) -> dict:
    return _current(credentials)
