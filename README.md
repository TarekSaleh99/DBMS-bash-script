Perfect 😎 — here’s your **enhanced and GitHub-optimized README.md** version with **badges**, **emoji styling**, and **aesthetic Markdown formatting**. It’s clean, professional, and eye-catching for both **GitHub** and **LinkedIn posts** 👇

---

# 🗄️ Bash-Based DBMS Project

[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Linux Compatible](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-green.svg)](#)
[![Educational Project](https://img.shields.io/badge/Use-For%20Learning-blue)](#)

---

## 🧩 Overview

This project is a **mini Database Management System (DBMS)** built entirely with **pure Bash scripting** — no SQL engines, no databases, just shell logic.
It simulates **core DBMS functionality** like creating databases, tables, inserting, selecting, updating, and deleting rows — all stored as simple text files in your filesystem.

> 💡 Think of it as **SQL without SQL** — powered only by Linux commands.

---

## 🚀 Features

### 🧠 Database-Level Operations

* 📁 **Create Database** – Initialize a new database.
* 📚 **List Databases** – Display all existing databases.
* 🔗 **Connect To Database** – Access and manage tables interactively.
* 🗑️ **Drop Database** – Permanently remove a database.

### 📋 Table-Level Operations

* 🏗️ **Create Table** – Define columns, datatypes (`int` / `string`), and a primary key.
* 📄 **List Tables** – Show all tables inside a database.
* 🧨 **Drop Table** – Remove a specific table.

### 🧱 Data-Level Operations

* ➕ **Insert Row** – Add a new row with data-type and primary key validation.
* 🔍 **Select Rows** – View all rows in a formatted table output.
* ❌ **Delete Row** – Delete specific rows by their index number.
* ✏️ **Update Row** – Modify values in a specific column with type checking.

---

## ⚙️ How It Works

🗂️ Every **database** is a directory inside the `Databases/` folder.
📄 Each **table** is a text file containing its schema and rows.

Example table file:

```
Columns:id,name,age
Types:int,string,int
PK:id
1,John,25
2,Jane,30
```

Operations like **insert**, **update**, and **delete** are performed using `awk`, `sed`, and other core Bash tools to ensure proper schema enforcement and data integrity.

---

## 🧱 Project Structure

```
.
├── dbms.sh                # Main entry point (menu system)
├── lib/
│   ├── db_operations.sh   # Database operations (create, list, drop, connect)
│   └── table_operations.sh# Table operations (CRUD for data)
└── Databases/             # Auto-created folder for all user databases
```

---

## 🧰 Prerequisites

Before running, make sure you have:

* 🐧 Linux / macOS / WSL on Windows
* 💡 Bash v4+
* 🧱 Utilities: `awk`, `sed`, `wc`, `nl`, `mkdir`, `rm`

> 🧠 Run `bash --version` to check your version.

---

## ▶️ Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/yourusername/dbms-bash.git
cd dbms-bash
```

### 2️⃣ Give Execute Permission

```bash
chmod +x dbms.sh
```

### 3️⃣ Run the Program

```bash
./dbms.sh
```

### 4️⃣ Use the Interactive Menus

Example:

```
1) Create Database
2) List Database
3) Connect To Database
4) Drop Database
5) Exit
```

---

## 🧩 Example Usage

Creating and managing data inside your own DBMS:

```
Enter your choice:
1) Create Database
#? 1
Enter database name: mydb
Database 'mydb' created.

#? 3
Enter database name to connect: mydb
Connected to database 'mydb'.

# Inside table menu:
1) Create Table
2) Insert Row
3) Select Rows
```

✅ Example `Select Rows` Output:

```
Row  | id             | name           | age
------------------------------------------------
1    | 1              | John           | 25
2    | 2              | Jane           | 30
------------------------------------------------
```

---

## 💡 Key Bash Concepts Used

| Concept     | Description                          |
| ----------- | ------------------------------------ |
| 🧠 `awk`    | Print and format tabular data        |
| ✂️ `sed`    | Inline editing for update operations |
| 🔠 `IFS`    | Parse comma-separated schema         |
| 🧩 Arrays   | Store column names and datatypes     |
| 🧱 Regex    | Validate integer and string data     |
| 🔁 `select` | Interactive CLI menus                |
| 🧼 `mktemp` | Safe atomic updates using temp files |

---

## 🎯 Learning Outcomes

Through this project, you’ll learn:

* How **databases** work at the filesystem level.
* How to implement CRUD operations with **shell scripting**.
* Real-world use of **awk**, **sed**, **regex**, and **array manipulation**.
* The importance of **validation**, **schemas**, and **primary keys**.

> 🧠 A perfect learning project for students exploring DevOps, Linux, or backend fundamentals.

---

## 🪪 License

This project is licensed under the **MIT License**.
You’re free to use, modify, and distribute it for learning or demo purposes.

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🙌 Acknowledgments

Built with ❤️ using **pure Bash** to explore how DBMS concepts work under the hood —
from **schemas** and **records** to **data integrity** and **CRUD logic**.

> 🌟 “Understanding how data is stored and managed is the first step to mastering backend systems.”

