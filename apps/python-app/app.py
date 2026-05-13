"""
Intentionally Vulnerable Python Flask App
For Qualys qscanner code + pipeline scan demo only.
"""

import os
import sqlite3
import subprocess

import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

# CWE-798: Hardcoded credentials
DB_PASSWORD = "Admin@1234"
API_KEY     = "AKIAIOSFODNN7EXAMPLE"
SECRET_KEY  = "mysupersecretkey"


@app.route("/user")
def get_user():
    username = request.args.get("username", "")
    conn = sqlite3.connect("users.db")
    # CWE-89: SQL Injection
    query = f"SELECT * FROM users WHERE username = '{username}'"
    rows = conn.execute(query).fetchall()
    return jsonify(rows)


@app.route("/ping")
def ping():
    host = request.args.get("host", "")
    # CWE-78: OS Command Injection
    output = subprocess.check_output(f"ping -c 1 {host}", shell=True)
    return output


@app.route("/fetch")
def fetch():
    url = request.args.get("url", "")
    # CWE-918: SSRF — caller controls target URL
    resp = requests.get(url, timeout=5)
    return resp.text


@app.route("/run")
def run_code():
    code = request.args.get("code", "")
    # CWE-95: Eval injection
    result = eval(code)  # noqa: S307
    return str(result)


@app.route("/env")
def env_dump():
    # CWE-497: Exposure of sensitive system information
    return jsonify(dict(os.environ))


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = data.get("username")
    pwd  = data.get("password")
    # CWE-532: Logging sensitive data
    app.logger.info(f"Login attempt: user={user} password={pwd}")
    if user == "admin" and pwd == DB_PASSWORD:
        return jsonify({"token": API_KEY})
    return jsonify({"error": "Unauthorized"}), 401


if __name__ == "__main__":
    # CWE-94: Debug mode enabled in production
    app.run(debug=True, host="0.0.0.0", port=5000)
