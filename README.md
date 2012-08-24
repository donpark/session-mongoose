`session-mongoose` module is an implementation of `connect` session store using [Mongoose](http://mongoosejs.com).

## Implementation Note:

Uses its own instance of Mongoose object, leaving default instance for use by the app.

## Install

    npm install session-mongoose

## Usage

Create session store:

    var SessionMongoose = require("session-mongoose");
    var mongooseSessionStore = new SessionMongoose({
        url: "mongodb://localhost/session",
        interval: 120000 // expiration check worker run interval in millisec (default: 60000)
    });

Configure Express

    var express = require("express");
    ...
    // configure session provider
    app.use(express.session({
        store: mongooseSessionStore,
        ...
    });
    ...

That's it.

## Version 0.0.3 Migration Note

Version 0.0.3 changes Mongoose schema data type for session data from JSON string to `Mixed`.

If you notice any migration issues, please file an issue.