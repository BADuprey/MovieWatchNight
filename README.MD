# Movie Watch Night!

## Functionality
* Users can create and log in with their accounts.
    * For email, it has to be an @gmail.com (using fake emails)
    * Password has to be 8 characters long, contain at least one special character, and at least 1 number. Passwords are hashed and stored in the database. 
    * Users can reset their password if they forget it. 

* The hub contains:
    * A card greeting the user to the app. 
    * An upcoming movie reminder card
        * If no movies are scheduled, then there will be no reminders. 
        * If at least one or more movies are scheduled, then the card will remind the user for the nearest upcoming event. 
    * Link to groups view through the "groups" button.
    * Link to the information page through the "info page" button
    * A random movie generator card: if the user is interested in the movie that is displayed, they can click on the card and it will take them to the information page for that movie. 

* Information page: users can scroll through an array of movie genres and check the summary, rating, and release date of each movie. If they want to add a movie to their lists, there is a `+` icon at the top right for users to do that. 
    * *Note: a very small portion of our database for movies did not contain the summary for them, and thus the overview is empty. Rating and release date are still there if available.*

* Recommendation page: in a similar fashion as the random movie generator card at the hub, the recommendation page (accessed through nav) shows a small set of randomly picked movies, organized by rating. If the user is interested in the movie that is displayed, they can click on the card and it will take them to the movie information page, where they can choose to add them to their lists. The user gets to refresh the recommendation page using the `⟳` icon at the top right to get a new subset of movies. 

* Personal lists: through the nav, users can access their "ignore list" and their "watch/favorite lists". They can either type the name of a movie and add it, or they can add movies through the information page and recommendations page. 

* Personal schedule page
    * Users can add a movie and a time to their schedules. 
    * Users can remove the movie by clicking on the trash can icon
    * Users can modify the time of the movie by clicking on the movie card. 
    * User's personal schedule view also shows events scheduled through groups, so that they do not have to go back through each group to see when a plan has been scheduled. They are able to see the group it belongs to, the name of the movie, and the date.
    
* Users can create groups
    * Leaders are the only ones allowed to delete groups and/or members from a group. Thus, their view looks slightly different than non-leaders. Non-leaders are not allowed to see the remove option (a trash can icon) to delete groups and members. 
    * In each individual group view, we have:
        * A shared schedule for the group 
        * An option to suggest a movie and vote for a time. 
            * When a user suggests a movie, it is an automatic vote for that movie from the user. Thus, the user that suggested a movie cannot add an extra vote to it. 
            * Once a movie is suggested, a voting round begins. Every member can see the suggested movies in a poll and choose to either add a vote for that movie or suggest a new movie. Everybody in the group needs to vote in order for the voting round to end. Once every member has voted, a new step appears in the group view: vote for date. Now, every user needs to vote for a date and time before the voting round ends. When a user votes for a date and time, other users will be able to see the current suggestions. 
            * If all users vote for the same date and time, then the movie will be automatically scheduled for the specified date and time and will appear in the group schedule view (as well as in each user's individual schedule view)
        * If a leader removes a member from the group, then that member's personal schedule will no longer show events related to the group. 
        * If a leader deletes the group, then all events related to the group are removed for every user involved.
    * Every group has their own shared watch lists and ignore lists, independent of each user's personal lists. 
    * There is a card showing the list of the current members in the group.
    * To invite members to the group, users can tap on "Link to add members" and it will automatically copy the link. Then, the user can either send the link through text or another medium (separate from the app). 
        * When a user opens the link, they are asked to fill a form with their username and password used in the app. If the user does not have an account in our app, then nothing happens. If the user **has** an account, then once their credentials are filled in correctly, they will be taken to another screen that will let them know that they have been successfully added to the group. Users can now refresh the group view to see the new member added. 
            * *Note: In a real world scenario, we would make the link much safer so that people would not be able to change it through the search bar* 

## Instructions / requirements / how to run
The submission zip file contains 2 folders:
* `Sprint_2` -> run on XCODE
* `Database` -> run on another code editor / IDE that runs python

`Sprint_2` contains the actual app.`Database` contains the files corresponding to the flask server (app.py, database.py, and the movie database)

### How to run/test
1. Step 1: run `app.py` to start the server (runs locally)
2. Step 2: run `sprint_2` files on XCODE
3. Sign up and log in with your account to start your movie watch night experience!
    * There are 4 default users if you'd like to log in with their credentials: 
        * User 1:  
            * Username: maria
            * Password: maria12*
        
        * User 2:  
            * Username: alex
            * Password: alex123*
        
        * User 3:  
            * Username: antonella
            * Password: antonella1*
        
        * User 4:  
            * Username: chris
            * Password: chris12*

    *Please notice the comment in `ServiceConfig.swift` file:*
    ![1763831763524](image/README/1763831763524.png)
        *This is important for the social component of the app so that users can connect through different computers and interact through the group view*
        
# Movie Watch Night – Local Client + Flask Backend Explanation

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
* https://docs.python.org/3/library/sqlite3.html

### For schedule view:
* https://sarunw.com/posts/swiftui-multidatepicker/
* https://developer.apple.com/documentation/uikit/uicalendarview
* https://www.youtube.com/watch?v=X_boPC1tg_Y
* https://blog.logrocket.com/working-calendars-swift/

### For animation & custom font (popcorn intro)
* https://www.youtube.com/watch?v=p2b8GSCDl-Y
* https://www.youtube.com/watch?v=cF640EUNr4I
* https://www.youtube.com/watch?v=ZSQh_Zl6V_c
* https://developer.apple.com/documentation/dispatch/dispatchqueue
* https://developer.apple.com/videos/play/wwdc2024/10151/
* https://www.sitepoint.com/using-uikit-dynamics-swift-animate-apps/
* https://forums.swift.org/t/an-alternative-take-on-animating-asynchronous-effects/45000
* https://www.youtube.com/watch?v=ou0nuEf7TNs
* https://www.youtube.com/watch?v=SRZKAUPIv50
* https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text
* https://ix76y.medium.com/level-up-your-swiftui-app-with-custom-fonts-d40e01349351

### For voting system in groups
* https://github.com/Oritsema-Lawson/PythonVotingSystem

### MISCELLANEOUS 
* https://developer.apple.com/documentation/swiftui/vstack
* https://developer.apple.com/documentation/Symbols
* https://developer.apple.com/design/human-interface-guidelines/sf-symbols
* https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app
* https://martinfowler.com/articles/patterns-of-distributed-systems/
* https://developer.mozilla.org/en-US/docs/Web/CSS






