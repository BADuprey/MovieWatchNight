import sqlite3
import json
import csv
import re

ENCODING = "utf8"
DATABASE_NAME = "movieWatchNight.db"
MOVIES_FILENAME = "movies_metadata.json"
CLEANED_MOVIES = "cleanedMovies.json"

def openConnection():
    connection = sqlite3.connect(DATABASE_NAME)
    cursor = connection.cursor()
    return connection, cursor

def closeConnection(cursor, connection):
    if cursor is not None:
        cursor.close()
    if connection is not None:
        connection.close()

# creates table in database
def createTables():
    conn, c = openConnection()
    commands = []
    commandString = """CREATE TABLE users (
        userID int AUTO_INCREMENT PRIMARY KEY,
        username text UNIQUE,
        passHash text,
        emailAddress text
    );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE movies (
        movieID int PRIMARY KEY,
        title text,
        overview text,
        rating float,
        release date
        );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE groups (
        groupID int AUTO_INCREMENT PRIMARY KEY,
        groupName text,
        leaderID int,
        FOREIGN KEY (leaderID) REFERENCES users(userID)
    );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE groupMemberRelation (
        groupID int,
        userID int,
        FOREIGN KEY (groupID) REFERENCES groups(groupID),
        FOREIGN KEY (userID) REFERENCES users(userID)
        );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE genreMovieRelation (
        movieID int,
        genre text,
        FOREIGN KEY (movieID) REFERENCES movies(movieID)
        );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE events (
        eventID int AUTO INCREMENT PRIMARY KEY,
        title text,
        date date
        );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE groupEventRelation (
        groupID int,
        eventID int,
        FOREIGN KEY (eventID) REFERENCES events(eventID),
        FOREIGN KEY (groupID) REFERENCES groups(groupID)
        );
    """
    commands.append(commandString)

    commandString = """CREATE TABLE userEventRelation (
        userID int,
        eventID int,
        FOREIGN KEY (userID) REFERENCES users(userID),
        FOREIGN KEY (eventID) REFERENCES events(eventID)
        );
    """

    for command in commands:
        c.execute(command)
    conn.commit()
    closeConnection(c, conn)

# DESTROYS ALL TABLES - DONT USE UNLESS ITS LAST RESORT
def dropTables():
    conn, c = openConnection()
    tableNames = ["groupMemberRelation", "genreMovieRelation", "groupEventRelation", "userEventRelation", "users", "movies", "groups", "events"]

    for table in tableNames:
        commandString = "DROP TABLE IF EXISTS " + table + ";"
        c.execute(commandString)
    
    conn.commit()
    closeConnection(c, conn)
    
def resetDB():
    dropTables()
    createTables()

def loginUser(username: str, passwordHash: str) -> bool:
    conn, c = openConnection()

    commandString = f"SELECT COUNT(*) FROM users \
                      WHERE username = '{username}' AND passHash = '{passwordHash}'"
    c.execute(commandString)
    result = c.fetchone()
    closeConnection(c, conn)
    if result[0] == 1:
        return True
    else:
        return False

def createUser(username: str, passwordHash: str, emailAddress: str) -> bool:
    conn, c = openConnection()
    try:
        commandString = f"INSERT INTO users (username, passHash, emailAddress) \
                        VALUES ('{username}', '{passwordHash}', '{emailAddress}');"
        c.execute(commandString)
        conn.commit()
        closeConnection(c, conn)
    except sqlite3.IntegrityError:
        closeConnection(c, conn)
        return False
    return True
    
def deleteUser(userID: int) -> bool:
    conn, c = openConnection()

    try:
        commandString = f"DELETE FROM groupMemberRelation \
                          WHERE userID = {userID}"
        c.execute(commandString)

        commandString = f"DELETE FROM groups \
                          WHERE leaderID = {userID}"
        c.execute(commandString)

        commandString = f"DELETE FROM users \
                          WHERE userID = {userID}"
        c.execute(commandString)

        conn.commit()
        closeConnection(c, conn)
        return True
    except sqlite3.IntegrityError:
        closeConnection(c, conn)
        return False

def getGroups(userID: int) -> list:
    conn, c = openConnection()

    commandString = f"SELECT groupID FROM groupMemberRelation \
                      WHERE userID = {userID};"
    c.execute(commandString)
    output = c.fetchall()
    closeConnection(c, conn)
    return output

def getGroupMembers(groupID: int) -> list:
    conn, c = openConnection()

    commandString = f"SELECT groupID FROM groupMemberRelation \
                      WHERE groupID = {groupID};"
    c.execute(commandString)
    output = c.fetchall()
    closeConnection(c, conn)
    return output

def createGroup(name: str, leaderID: int) -> bool:
    conn, c = openConnection()
    
    try:
        commandString = f"INSERT INTO groups (groupName, leaderID) \
                        VALUES ('{name}', {leaderID})"
        c.execute(commandString)
        conn.commit()
        closeConnection(c, conn)
        return True
    except sqlite3.IntegrityError:
        closeConnection(c, conn)
        return False

def addMember2Group(groupID: int, userID: int) -> bool:
    conn, c = openConnection()
    try:
        commandString = f"INSERT INTO groupMemberRelation (groupID, userID) \
                        VALUES ({groupID}, {userID});"
        c.execute(commandString)
        conn.commit()
        closeConnection(c, conn)
        return True
    except sqlite3.IntegrityError:
        closeConnection(c, conn)
        return False

def deleteGroup(groupID: int) -> bool:
    conn, c = openConnection()
    try:
        commandString = f"DELETE FROM groupMemberRelation \
                        WHERE groupID = {groupID};"
        c.execute(commandString)
        
        commandString = f"DELETE FROM groups \
                        WHERE groupID = {groupID};"
        c.execute(commandString)
        conn.commit()
        closeConnection(c, conn)
        return True
    except sqlite3.IntegrityError:
        closeConnection(c, conn)
        return False

# util for converting csv files to json files
def csv2Json(inputFile, outputFile):
    with open(inputFile, "r", encoding=ENCODING) as inFile:
        with open(outputFile, "w", encoding=ENCODING) as outFile:
            reader = csv.DictReader(inFile)
            data = list(reader)
            json.dump(data, outFile, indent = 4)

def cleanMovieFile():
    with open(MOVIES_FILENAME, "r", encoding=ENCODING) as file:
        content = json.load(file)
    
    foundIDs = []
    output = []

    for movie in content:
        try:
            id = int(movie["id"])
            if id not in foundIDs and movie["title"] != None:
                movie["title"] = movie["title"].replace("\"", "'")
                
                foundIDs.append(id)
                output.append(movie)
        except ValueError:
            continue
    
    with open(CLEANED_MOVIES, "w", encoding=ENCODING) as file:
        json.dump(output, file, indent = 4)

def addMovies():
    with open(CLEANED_MOVIES, "r", encoding=ENCODING) as file:
        content = json.load(file)
    
    conn, c = openConnection()
    for movie in content:
        id = int(movie["id"])
        title = movie["title"]
        rating = float(movie["vote_average"])
        release = movie["release_date"]
        overview = movie["overview"].replace("\"", "'")
        commandString = f'INSERT INTO movies (movieID, title, overview, rating, release) \
                          VALUES ({id}, "{title}", "{overview}", {rating}, "{release}");'
        c.execute(commandString)
    
    conn.commit()
    
def addGenres():
    genreMatch = r"'name': '(.+?)'}"
    conn, c = openConnection()
    with open(CLEANED_MOVIES, "r", encoding=ENCODING) as file:
        content = json.load(file)
    for movie in content:
        genres = movie["genres"]
        movieID = int(movie["id"])
        hits = re.findall(genreMatch, genres)
        for hit in hits:
            commandString = f"INSERT INTO genreMovieRelation (movieID, genre) VALUES \
                             ({movieID}, '{hit}');"
            c.execute(commandString)
    conn.commit()
    closeConnection(c, conn)
            
        

# RESETS DATABASE
def test():
    resetDB()
    if not createUser("test", "test", "test@test.com"):
        print("Create Test Failed")
    createUser("test2", "test2", "test2@test.com")


    if not loginUser("test", "test"):
        print("Login Test Failed")
    
    if not createGroup("testGroup", 0):
        print("Create Group Failed")
    
    if not addMember2Group(0, 1):
        print("Add member2Group Failed")
    
    if not getGroups(1):
        print("GetGroups failed")
    
    if not deleteGroup(0):
        print("Delete Group failed")
    
    if not deleteUser(1):
        print("Delete User failed")

if __name__ == "__main__":
    resetDB()
    addMovies()
    addGenres()