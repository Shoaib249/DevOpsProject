from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
from werkzeug.security import generate_password_hash, check_password_hash
import config

app = Flask(__name__)
app.config.from_object('config.Config')  # config.py se Config load ho raha hai

mysql = MySQL(app)  # MySQL object

@app.route("/")
def home():
    return redirect(url_for("login"))

@app.route("/signup", methods=["GET", "POST"])
def signup():
    msg = ""
    if request.method == "POST":
        name = request.form.get("name")
        email = request.form.get("email")
        password = request.form.get("password")

        # Form validation
        if not name or not email or not password:
            msg = "Please fill out all fields!"
        elif not re.match(r"[^@]+@[^@]+\.[^@]+", email):
            msg = "Invalid email address!"
        else:
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
            account = cursor.fetchone()

            if account:
                msg = "Account already exists!"
            else:
                hashed_password = generate_password_hash(password)
                cursor.execute(
                    "INSERT INTO users (name, email, password) VALUES (%s, %s, %s)",
                    (name, email, hashed_password)
                )
                mysql.connection.commit()
                cursor.close()
                flash("You have successfully registered!", "success")
                return redirect(url_for("login"))

    return render_template("signup.html", msg=msg)

@app.route("/login", methods=["GET", "POST"])
def login():
    msg = ""
    if request.method == "POST":
        email = request.form.get("email")
        password = request.form.get("password")

        if not email or not password:
            msg = "Please fill out both fields!"
        else:
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
            account = cursor.fetchone()
            cursor.close()

            if account and check_password_hash(account["password"], password):
                session["loggedin"] = True
                session["name"] = account["name"]
                session["email"] = account["email"]
                return redirect(url_for("welcome"))
            else:
                msg = "Incorrect email or password!"

    return render_template("login.html", msg=msg)

@app.route("/welcome")
def welcome():
    if "loggedin" in session:
        return render_template("welcome.html", name=session["name"])
    return redirect(url_for("login"))

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)

