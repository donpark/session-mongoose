Mongoose = require('mongoose')
mongoose = new Mongoose.Mongoose()
mongoose[key] = value for key, value of Mongoose when not mongoose[key]? and Mongoose.hasOwnProperty(key)

Schema = mongoose.Schema

SessionSchema = new Schema({
    sid: { type: String, required: true, unique: true }
    data: {}
    expires: { type: Date, index: true }
})

Session = mongoose.model('Session', SessionSchema)

defaultCallback = (err) ->

class SessionStore extends require('connect').session.Store
    constructor: (options) ->
        options?.interval ?= 60000
        mongoose.connect options.url
        setInterval (-> Session.remove { expires: { '$lte': new Date() }}, defaultCallback), options.interval

    get: (sid, cb = defaultCallback) ->
        Session.findOne { sid: sid }, (err, session) ->
            if session?
                try
                    session.data = JSON.parse(session.data) if typeof session.data is 'string'
                    cb null, session.data
                catch err
                    cb err
            else
                cb err, session

    set: (sid, data, cb = defaultCallback) ->
        try
            Session.update { sid: sid }, {
                sid: sid
                data: data
                expires: if data?.cookie?.expires? then data.cookie.expires else null
            }, { upsert: true }, cb
        catch err
            cb err

    destroy: (sid, cb = defaultCallback) ->
        Session.remove { sid: sid }, cb

    all: (cb = defaultCallback) ->
        Session.find { expires: { '$gte': new Date() } }, [ 'sid' ], (err, sessions) ->
            if sessions?
                cb null, (session.sid for session in sessions)
            else
                cb err

    clear: (cb = defaultCallback) ->
        Session.drop cb

    length: (cb = defaultCallback) ->
        Session.count {}, cb

module.exports = SessionStore
module.exports.Session = Session
