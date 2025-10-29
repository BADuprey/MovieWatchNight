from flask import Flask, request
import database as db

app = Flask(__name__)

@app.route("/loginUser", methods=["POST"])
def loginUser():
    if request.method == "POST":
        username = request.form.get("username")
        passHash = request.form.get("passHash")
        return str(db.loginUser(username, passHash))

@app.route("/createUser", methods = ["POST"])
def createUser():
    if request.method == "POST":
        username = request.form.get("username")
        passHash = request.form.get("passHash")
        email = request.form.get("email")
        return str(db.createUser(username, passHash, email))

@app.route("/deleteUser", methods = ["POST"])
def deleteUser():
    if request.method == "POST":
        userID = int(request.form.get("userID"))
        return str(db.deleteUser(userID))

@app.route("/getGroups", methods = ["POST"])
def getGroups():
    if request.method == "POST":
        userID = int(request.form.get("userID"))
        groups = db.getGroups(userID)
        output = ""
        for group in groups:
            output += str(group)
        return output

@app.route("/getGroupMembers", methods = ["POST"])
def getGroupMembers():
    if request.method == "POST":
        groupID = int(request.form.get("groupID"))
        users = db.getGroupMembers(groupID)
        output = ""
        for user in users:
            output += str(user)
        return output

@app.route("/createGroup", methods = ["POST"])
def createGroup():
    if request.method == "POST":
        name = request.form.get("name")
        leaderID = int(request.form.get("leaderID"))
        return str(db.createGroup(name, leaderID))

@app.route("/addMember2Group", methods = ["POST"])
def addMember2Group():
    if request.method == "POST":
        groupID = int(request.form.get("groupID"))
        userID = int(request.form.get("userID"))
        return str(db.addMember2Group(groupID, userID))

@app.route("/deleteGroup", methods = ["POST"])
def deleteGroup():
    if request.method == "POST":
        groupID = int(request.form.get("groupID"))
        return str(db.deleteGroup(groupID))

@app.route("/test")
def test():
    return "hello world"


if __name__ == "__main__":
    app.run(debug = app.debug, host = "localhost", port=8097)
