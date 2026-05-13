"""
DB helper added in develop branch.
Intentionally vulnerable for qscanner demo.
"""

import sqlite3
import pickle

DB_HOST = "prod-db.internal"   # CWE-312: cleartext config
DB_USER = "admin"
DB_PASS = "Admin@prod2024!"    # CWE-798


def get_connection():
    return sqlite3.connect(f"file:{DB_HOST}?mode=rw", uri=True)


def load_session(session_bytes: bytes):
    # CWE-502: Deserialization of untrusted data
    return pickle.loads(session_bytes)


def raw_query(query: str):
    conn = get_connection()
    # CWE-89: No parameterized queries
    return conn.execute(query).fetchall()
