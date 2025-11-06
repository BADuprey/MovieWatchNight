|Table| Columns|
|-----|--------|
|users|userID, username, passHash, emailAddress|
|movies|movieID, title, overview, rating, release|
|userWatchList|userID, movieID|
|userAntiWatchList|userID, movieID|
|groups|groupID, groupName, leaderID|
|groupMemberRelation|groupID, userID, vote|
|groupWatchList|groupID, movieID|
|groupAntiWatchList|groupID, movieID|
|genreMovieRelation|movieID, genre|
|events|eventID, title, date|
|groupEventRelation|groupID, eventID|
|userEventRelation|userID, eventID|
