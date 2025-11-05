# MovieWatch – Local Client + Flask Backend Explanation

We have three big components: 

- **SwiftUI app (Xcode)** = the client
- **Flask app (`app.py`)** = the local HTTP API
- **SQLite (`movieWatchNight.db`)** + **`database.py`** = the data layer

The client never talks directly to SQLite. Everything goes through Flask (our server)!

## High-Level Idea

**General flow:**

1. A SwiftUI view appears (`InfoView`, `SchedulesView`, etc.)
2. The view calls a method on `APIService.shared` (Swift)
3. `APIService` builds an HTTP request to the Flask server (e.g. `http://127.0.0.1:8097/genres`)
4. Flask receives the request in a route (`@app.route(...)`)
5. That route calls a helper in `database.py` to read/write SQLite
6. SQLite returns rows → `database.py` → Flask → JSON
7. Swift decodes the JSON back into Swift structs
8. View updates its `@State` and redraws

So the flow goes like:

**SwiftUI → APIService → Flask → database.py → SQLite → back to Flask → back to APIService → back to SwiftUI**

## Important Files to know of

- `ContentView.swift` – main tab UI + decides whether user is logged in

- `APIService.swift` – all HTTP calls live here

- `app.py` – Flask routes, one per endpoint (`/loginUser`, `/genres`, `/getEvents`, …)

- `database.py` – actual SQL and DB setup

- `movieWatchNight.db` – SQLite database file 


## Example of how the files connect for Info Page → Genres

### 1. SwiftUI View
```swift
struct InfoView: View {
    @State private var genres: [String] = []
    @State private var isLoading = true

    var body: some View {
        List {
            if isLoading {
                Text("Loading genres...")
            } else if genres.isEmpty {
                Text("No genres returned from server.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                }
            }
        }
        .navigationTitle("Genres")
        .onAppear {
            APIService.shared.fetchGenres { result in
                DispatchQueue.main.async {
                    self.genres = result
                    self.isLoading = false
                }
            }
        }
    }
}

```
## 2. `APIService.swift` builds the HTTP request

After the SwiftUI view asks for data, the networking layer (`APIService.swift`) creates the actual HTTP call to the Flask server. It us at this point where we are "leaving" IOS and going to python.

```swift
struct GenreList: Decodable {
    let genres: [String]
}

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchGenres(completion: @escaping ([String]) -> Void) {
        // Base URL has to match the Flask server. 
        // In our case it is http://127.0.0.1:8097
        guard let base = ServerConfig.shared.baseURL else {
            completion([])
            return
        }

        // 1. Build the URL: http://127.0.0.1:8097/genres
        let url = base.appendingPathComponent("genres")

        // 2. Send GET request
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            // 3. Decode JSON: { "genres": [...] }
            let decoded = try? JSONDecoder().decode(GenreList.self, from: data)
            completion(decoded?.genres ?? [])
        }.resume()
    }
}

```
## 3. `app.py` (Flask) receives the request
Once the Swift app sends `GET http://127.0.0.1:8097/genres`, the Flask server has a route that matches that path. This route’s job is to **(a)** talk to the database layer and **(b)** return JSON back to the app.

```python
from flask import Flask, jsonify, request
import database as db

app = Flask(__name__)

@app.route("/genres", methods=["GET"])
def list_genres():
    # 1. open the database
    conn, c = db.openConnection()

    # 2. run SQL to get all distinct genres
    c.execute("SELECT DISTINCT genre FROM genreMovieRelation ORDER BY genre;")
    rows = c.fetchall()

    # 3. close the database connection
    db.closeConnection(c, conn)

    # 4. turn the rows into a plain Python list
    genres = [r[0] for r in rows]

    # 5. send JSON back to Swift
    return jsonify({"genres": genres})

```

## 4. `database.py` talks to SQLite
The Flask route doesn’t query the `.db` file directly: It "sends" that job to `database.py`. 

```python
import sqlite3

# the SQLite file
DATABASE_NAME = "movieWatchNight.db"

def openConnection():
    # 1. connect to the SQLite file
    connection = sqlite3.connect(DATABASE_NAME)
    # 2. get a cursor to run SQL
    cursor = connection.cursor()
    return connection, cursor

def closeConnection(cursor, connection):
    # 3. cleanly close both
    if cursor is not None:
        cursor.close()
    if connection is not None:
        connection.close()

```
## 5. SwiftUI updates the UI

This is the final step: once the data has made it all the way back from SQLite → `database.py` → `app.py` → `APIService.swift`, the view actually shows it.

For the info page example we have the view: 

```swift
struct InfoView: View {
    @State private var genres: [String] = []
    @State private var isLoading = true

    var body: some View {
        List {
            if isLoading {
                Text("Loading genres...")
            } else if genres.isEmpty {
                Text("No genres returned from server.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                }
            }
        }
        .navigationTitle("Genres")
        .onAppear {
            APIService.shared.fetchGenres { result in
                // back on the main thread so UI can update
                DispatchQueue.main.async {
                    self.genres = result
                    self.isLoading = false
                }
            }
        }
    }
}
```
## Recap of the whole path for info page example
Summary for the whole "journey" for info view: 

1. **View** (`InfoView.swift`)
   - appears on screen
   - calls `APIService.shared.fetchGenres(...)`

2. **Networking** (`APIService.swift`)
   - builds `GET http://127.0.0.1:8097/genres`
   - sends it with `URLSession`
   - waits for JSON

3. **Server** (`app.py`)
   - has `@app.route("/genres")`
   - receives the HTTP request
   - calls into `database.py`

4. **Database layer** (`database.py`)
   - opens `movieWatchNight.db`
   - runs: `SELECT DISTINCT genre FROM genreMovieRelation ORDER BY genre;`
   - returns the rows to `app.py`

5. **Server → App**
   - `app.py` turns rows into JSON: `{ "genres": [...] }`
   - sends JSON back over HTTP
   - `APIService.swift` decodes JSON into Swift structs

6. **UI update**
   - `InfoView` gets the `[String]`
   - sets `@State var genres`
   - SwiftUI redraws and shows the genres to the user

## OTHER INFO: 
* Apply the same pattern to other screens.
* When adding stuff, we have to update these files (including the view we are working on):
    * **app.py** (for the routes)
    * **database.py** (to get and insert info into the db)
    * **APIService.Swift** 

---
---
# HOW TO SEE/VISUALIZE DB FILE ON VSCODE

1. Download extension `SQLite Viewer` by Florian Klamfer (you can trust)

2. Once downloaded do `command + shift + P (on mac)`. You will get a "pop up" and see `"SQLite: open database"` Click on it. 

3. You will see your db file (in this case "movieWatchNight.db) Click it. 

4. On the left column (like the explorer where you see all of your files), you will see a section `SQLITE EXPLORER`. 
    * If you expand it, you can see all of the tables. 
    * Expand the table you wanna see (like events, movies, etc) and click the triangle `▸` You will see the table info!

**important note:** as you make modifications to the code throguh swift and wanna see those changes in the table, **refresh it with the `⟳` arrow.** 

---
---
# SPRINT 2 FILE ORGANIZATION (WILL CHANGE AS WE ADD STUFF) 
<img width="245" height="719" alt="image" src="https://github.com/user-attachments/assets/6761651d-bca4-4958-a498-ac3a765a5d25" />

---
---
# DOCUMENTATION / CITATIONS / CREDITS

### For server-client aspect:
* https://nikhiladigaz.medium.com/running-an-http-server-inside-your-ios-app-c01cbfa5e615
* https://forums.swift.org/t/connect-to-localhost-in-swiftui/57857
* https://flask.palletsprojects.com/en/latest/api/#flask.Request
* https://developer.apple.com/documentation/foundation/url_loading_system
* https://stackoverflow.com/questions/25702354/ios-simulator-access-localhost-server
* https://www.quora.com/How-do-I-deploy-a-Flask-back-end-for-Swift-app-iOS-in-a-cloud-server
* https://forums.swift.org/t/issue-with-swiftnio-connect-proxy-in-ios-app/58353
* https://forums.swift.org/t/connect-to-localhost-in-swiftui/57857
* https://nikhiladigaz.medium.com/running-an-http-server-inside-your-ios-app-c01cbfa5e615
* STILL HAVE TO ADD SOME MORE

### For schedule view: (SASHA ADD LATER!)
* 

### For YYY (if u used a resource, cite it please and add a title!)
* 

### MISCELLANEOUS 
* https://developer.apple.com/documentation/swiftui/vstack
* https://developer.apple.com/documentation/Symbols
* https://developer.apple.com/documentation/swiftui/securefield




