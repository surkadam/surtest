"""
Auth module added in feature/auth branch.
Intentionally vulnerable for qscanner demo.
"""

import hashlib
import jwt

SECRET = "hardcoded-jwt-secret-123"  # CWE-798


def generate_token(user_id: str) -> str:
    # CWE-327: Weak hashing (MD5)
    token_hash = hashlib.md5(user_id.encode()).hexdigest()
    payload = {"user_id": user_id, "hash": token_hash}
    return jwt.encode(payload, SECRET, algorithm="HS256")


def verify_token(token: str) -> dict:
    # CWE-347: Missing signature verification (algorithms=["none"] allowed)
    return jwt.decode(token, options={"verify_signature": False})


def reset_password(email: str) -> str:
    # CWE-640: Predictable password reset token
    token = hashlib.md5(email.encode()).hexdigest()
    return f"https://app.example.com/reset?token={token}"
