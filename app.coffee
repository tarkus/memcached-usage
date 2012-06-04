express = require 'express'
runner = require './lib/memcached-usage'

connections = {}
app = express.createServer()

app.use require('connect-assets')(express)
app.use express.static __dirname + "/assets"
app.set 'view engine', 'jade'

app.helpers
  title: ''

app.dynamicHelpers
  host: (req, res) ->
    'http://' + req.header 'host'

app.get '/', (req, res) ->
  res.render 'index', runner: runner

app.listen process.env.PORT || 4000

io = require('socket.io').listen app

io.set 'log level', 1
io.sockets.on 'connection', (socket) ->

  socket.emit 'connected', true

  socket.on 'run', (scenario) ->
    reporter = (report) ->
      console.log report
      socket.emit 'output', output: report
    runner.scenarios[scenario](reporter)
