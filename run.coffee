async = require 'async'
memcached = require 'memcached'
{exec} = require 'child_process'

memcached_host = "127.0.0.1"
memcached_port = 22422
memcached_cmd = "/usr/bin/memcached -m 64 -p " + memcached_port + " -u memcache -l " + memcached_host

respawn = exports.respawn = ->
  #exec "ps aux | grep memcached | grep -v grep | grep 22422 | awk '{print $2}' | xargs kill -9", (err, stdout, stderr) ->
  exec memcached_cmd, (err, stdout, stderr) ->
    #console.log err if err

fixture = exports.fixture = (length) ->
  char = ""
  char += "c" for i in [0...length]
  char

run = exports.run = (values, next) ->
  client = new memcached memcached_host + ":" + memcached_port
  counters = {}
  report =
    total_items: 0
    real_usage: 0
    real_bytes: 0
    server_usage: 0
    count: {}
    slabs: {}

  cb = (values, next) ->
    if typeof values is "object"
      value = values[Math.floor(Math.random() * values.length)]
    else if typeof values is "string"
      value = values
    counters[value.length] = 0 unless counters[value.length]?
    counter = counters[value.length]

    key = "Test:" + value.length + ":" + (counter + 1)
    client.set key, value, 10000, (err, result) ->
      return setTimeout (-> cb values, next), 10 unless result
      counter += 1
      counters[value.length] = counter
      if counter % 1000 == 0
        console.log counter + " keys added"
      client.stats (err, result) ->
        stats = result[0]
        return cb values, next if stats.evictions < 1
        for length, count of counters
          report.count[length] =
            items: count
          report.real_bytes += length * count


        report.total_items = stats["total_items"]
        report.server_bytes = stats["bytes"]
        report.server_usage = Math.round(stats["bytes"] / stats["limit_maxbytes"] * 10000) / 100
        report.real_usage = Math.round(report.real_bytes / stats["limit_maxbytes"] * 10000) / 100

        client.slabs (err, result) ->
          slab = result[0]
          for k, v of slab
            if typeof v is "object" and v.chunk_size?
              report.slabs[k] =
                chunk_size: v.chunk_size
                chunks_per_page: v.chunks_per_page
                total_chunks: v.total_chunks
                mem_requested: v.mem_requested
          report.active_slabs = v for k, v of slab.active_slabs
          next(report)

  client.connect memcached_host + ":" + memcached_port, (err, result) ->
    cb values, (report) ->
      console.log report

if require.main == module
  async.series
    start_server: (next) ->
      respawn()
      next(null, "Server started")
    insert: (next) ->
      #report = run fixture(1024 * 800)

      report = run [
        fixture(1024 * 800)
        fixture(1024 * 801)
      ]

      ###
      report = run [
        fixture(1024 * 10)
        fixture(1024 * 30)
        fixture(1024 * 100)
        fixture(1024 * 80)
        fixture(1024 * 5)
        fixture(1024 * 50)
        fixture(1024 * 200)
        fixture(1024 * 400)
        fixture(1024 * 500)
        fixture(1024 * 600)
        fixture(1024 * 800)
      ]
      ###
      next()
