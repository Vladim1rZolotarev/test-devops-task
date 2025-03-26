from flask import Flask

name = ''
app = Flask(name)


@app.route("/")
def home():
    return "Hello, DevOps!"


if name == "main":
    app.run(host="0.0.0.0", port=5000, debug = False)
