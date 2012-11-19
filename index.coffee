Mongoose = require('mongoose')
mongoose = new Mongoose.Mongoose()
mongoose[key] = value for key, value of Mongoose when not mongoose[key]? and Mongoose.hasOwnProperty(key)

Schema = mongoose.Schema

SessionSchema = new Schema({
  sid: { type: String, required: true, unique: true }
  data: { type: Schema.Types.Mixed, required: true }
  expires: { type: Date, index: true }
})

Session = mongoose.model('Session', SessionSchema)

defaultCallback = (err) ->

class SessionStore extends require('connect').session.Store
  constructor: (@options = {}) ->
    @options.url ?= "mongodb://localhost/sessions"
    @options.interval ?= 60000
    if mongoose.connection.readyState is 0
      mongoose.connect @options.url
      setInterval ->
        Session.remove
          expires:
            '$lte': new Date()
        , defaultCallback
      , @options.interval

  get: (sid, cb = defaultCallback) ->
    Session.findOne { sid: sid }, (err, session) ->
      if err or not session
        cb err
      else
        data = session.data
        try
          data = JSON.parse data if typeof data is 'string'
          cb null, data
        catch err
          cb err

  set: (sid, data, cb = defaultCallback) ->
    if not data
      @destroy sid, cb
    else
      try
        expires = data.cookie.expires if data.cookie
        expires ?= null # undefined is not equivalent to null in Mongoose 3.x
        session =
          sid: sid
          data: data
          expires: expires
        Session.update { sid: sid }, session, { upsert: true }, cb
      catch err
        cb err

  destroy: (sid, cb = defaultCallback) ->
    Session.remove { sid: sid }, cb

  all: (cb = defaultCallback) ->
    Session.find {}, 'sid expires', (err, sessions) ->
      if err or not sessions
        cb err
      else
        now = Date.now()
        sessions = sessions.filter (session) ->
          true if not session.expires or session.expires.getTime() > now
        cb null, (session.sid for session in sessions)

  clear: (cb = defaultCallback) ->
    Session.collection.drop cb

  length: (cb = defaultCallback) ->
    Session.count {}, cb

module.exports = SessionStore
module.exports.Session = Session
