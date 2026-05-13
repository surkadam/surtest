/**
 * Intentionally Vulnerable Node.js Express App
 * For Qualys qscanner code + pipeline scan demo only.
 */

const express = require("express");
const mysql   = require("mysql");
const _       = require("lodash");
const path    = require("path");
const fs      = require("fs");

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CWE-798: Hardcoded credentials
const DB_PASS  = "password123";
const API_KEY  = "AKIAIOSFODNN7EXAMPLE";

// CWE-89: SQL Injection
app.get("/user", (req, res) => {
    const username = req.query.username;
    const query = `SELECT * FROM users WHERE username = '${username}'`;
    res.json({ query });
});

// CVE-2019-10744: Prototype Pollution via lodash merge
app.post("/merge", (req, res) => {
    const base = {};
    _.merge(base, req.body);
    res.json(base);
});

// CWE-95: Code injection via eval
app.get("/eval", (req, res) => {
    const result = eval(req.query.code); // noqa
    res.send(String(result));
});

// CWE-22: Path Traversal
app.get("/file", (req, res) => {
    const filename = req.query.name;
    const filePath = path.join(__dirname, "files", filename);
    const content  = fs.readFileSync(filePath, "utf8");
    res.send(content);
});

// CWE-532: Logging credentials
app.post("/login", (req, res) => {
    const { username, password } = req.body;
    console.log(`[LOGIN] user=${username} password=${password}`);
    if (username === "admin" && password === DB_PASS) {
        res.json({ token: API_KEY });
    } else {
        res.status(401).json({ error: "Unauthorized" });
    }
});

app.listen(3000, () => console.log("Server running on port 3000"));
