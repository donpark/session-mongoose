`session-mongoose` module is an implementation of `connect` session store using [Mongoose](http://mongoosejs.com).

## Status ##

**IMPORTANT**: This module currently supports legacy versions of `connect` (2.x) and
`express` (2.x and 3.x) due to extensive changes made to those modules.

Until support for latest modules are added, this module should not be used with latest
versions of `connect` and `express`.

--

I believe every open source project should clearly indicate its status and intended applications
of the project. In that spirit, here is the status of `session-mongoose`.

This project is IMO not production-ready for following reasons:

1. insufficient testing
2. zero optimization
3. there are better options than MongoDB for session storage.

I use `session-mongoose` primarily in prototype webapps where above factors don't matter.

Accordingly, I am ready to commit just enough time to fix things when things break.
I can't guarantee all reported issues will be fixed in reasonable amount of time but
I do try to address them promptly mainly because I can't sleep at night when someone
in need is out there.

## Implementation Note:

Uses its own instance of Mongoose object, leaving default instance for use by the app.

## Install

    npm install session-mongoose

## Usage

Create session store:

    var connect = require('connect');
    var SessionStore = require("session-mongoose")(connect);
    var store = new SessionStore({
        url: "mongodb://localhost/session",
        interval: 120000 // expiration check worker run interval in millisec (default: 60000)
    });

Configure Express

    var express = require("express");
    var SessionStore = require("session-mongoose")(express);
    var store = new SessionStore({
        url: "mongodb://localhost/session",
        interval: 120000 // expiration check worker run interval in millisec (default: 60000)
    });
    ...
    // configure session provider
    app.use(express.session({
        store: store,
        cookie: { maxAge: 900000 } // expire session in 15 min or 900 seconds
    }));
    ...

Using custom connection

    var mongoose = require("mongoose");
    mongoose.connect("mongodb://localhost/mysessionstore");
    
    var SessionStore = require("session-mongoose")(express);
    var store = new SessionStore({
        interval: 120000, // expiration check worker run interval in millisec (default: 60000)
        connection: mongoose.connection // <== custom connection
    });

That's it.

## Turning off the sweeper that expires sessions

You can also turn of the sweeper that runs every 'interval' seconds by
setting the sweeper option to false. It is true by default.

    var SessionStore = require("session-mongoose")(express);
    var store = new SessionStore({
        sweeper: false,
        connection: mongoose.connection // <== custom connection
    });

## Custom Session Model Name

Setting `modelName` option will override default session model name (`Session`).

    var store = new SessionStore({
        modelName: "Foobar" // collection name will be "foobars"
    });

## Experimental TTL support

MongoDB version 2.2+ has built-in TTL (time-to-live) support.

To enable TTL-support, set `ttl` option to session TTL in **seconds**.

    var store = new SessionStore({
        connection: mongoose.connection, // <== custom connection
        ttl: 3600 // session expires in 60 minutes
    });

As expected, the sweeper will be disabled when TTL support is used.

* **WARNING 1**: This feature hasn't been tested yet.
* **WARNING 2**: TTL-support uses a slightly different schema so you may run into migration issues.

## Also See

### Similar Projects

* [connect-mongostore](https://github.com/diversario/connect-mongostore/) - replica set support

### Related Projects

TBD

## Migration Notes

### Version 0.5 Migration Note

Version 0.5 uses connection-specific `Schema` object if connection was passed in via `options`
to protect against Mongoose version conflicts as suggested by [@bra1n](https://github.com/donpark/session-mongoose/issues/24).

### Version 0.2 Migration Note

* an instance of `connect` module (or equivalent like `express`) is now **required** to get
  SessionStore implementation (see examples above).

* moved Mongoose model for session data to session store instance (SessionStore.model).

        var connect = require('connect');
        var SessionStore = require("session-mongoose")(connect);
        var store = new SessionStore({
            url: "mongodb://localhost/session",
            interval: 120000 // expiration check worker run interval in millisec (default: 60000)
        });
        var model = store.model; // Mongoose model for session

        // this wipes all sessions
        model.collection.drop(function (err) { console.log(err); });

### Version 0.1 Migration Note

* `connect` moved from `dependencies` to `devDependencies`.

### Version 0.0.3 Migration Note

Version 0.0.3 changes Mongoose schema data type for session data from JSON string to `Mixed`.

If you notice any migration issues, please file an issue.
