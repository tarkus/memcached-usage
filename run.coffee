async = require 'async'
memcached = require 'memcached'
{exec} = require 'child_process'


memcache_cmd = "/usr/bin/memcached -m 1 -p 22422 -u memcache -l 127.0.0.1 "

respawn = exports.respawn = ->
  exec memcache_cmd, (err, stdout, stderr) ->
    console.log err if err

fixture = exports.fixture = (length) ->
  char = ""
  char += "c" for i in [0...length]
  char

run = exports.run = (value) ->
  counter = 0
  client = new memcached '127.0.0.1:22422'

  cb = (value) ->
    key = "Test:" + value.length + ":" + counter
    client.set key, value, 10000, (err, result) ->
      console.log err if err?
      counter += 1
      if counter % 1000 == 0
        console.log counter + " keys added"
      client.stats (err, result) ->
        console.log err if err
        stats = result[0]
        
        if stats.evictions < 1
          return cb(value)

        report =
          items: counter
          item_length: value.length
          real_usage: Math.round(value.length * counter / stats["limit_maxbytes"] * 10000) / 100
          server_usage: Math.round(stats["bytes"] / stats["limit_maxbytes"] * 10000) / 100
          slabs: {}

        console.log counter + " keys added"
        client.slabs (err, slabs) ->
          console.log err if err
          console.log slabs
          for slab in slabs
            for cls of slab
              report.slabs[cls] = slab
          console.dir report
          return report
  cb(value)

if require.main == module
  async.series {
    start_server: (next) ->
      respawn()
      next()
    insert: (next) ->
      report = run(fixture 120)
      next null, report
  }, (err, results) ->
    console.log results
