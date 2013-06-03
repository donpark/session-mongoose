describe "session-mongoose sweeper off", ->
  assert = require('assert')
  should = require('should')
  SessionStore = require('..')(require('connect'))
  store = undefined

  store = new SessionStore
    url: "mongodb://localhost/session-mongoose-test-no-sweeper"
    sweeper: false
    interval: 1000 # ms

  reset = ->
    store.clear()

  it "should NOT remove expired session within sweeper interval", (done) ->
    reset()
    store.set '123',
      cookie:
        expires: new Date(Date.now() - 1000)
      name: 'don'
      value: '456'
    , (err, ok) ->
      assert.ifError err
      assert.equal ok, 1, "SessionStore.set should return 1"
      setTimeout ->
        store.length (err, length) ->
          console.log 'LENGTH' + length
          assert.equal length, 1, "Session should not have been swept"
          reset()
          done()
      , 1200
