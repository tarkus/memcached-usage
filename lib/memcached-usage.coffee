async = require 'async'
memcached = require 'memcached'
{execFile} = require 'child_process'

memcached_instance = ""

respawn = exports.respawn = (next) ->
  c = execFile __dirname + '/../bin/memcached.sh', (err, stdout, stderr) ->
    return console.log err if err
    memcached_instance = stdout.replace("\n", "")
    next() if next?

B = exports.B = (length) ->
  char = ""
  char += "B" for i in [0...length]
  char

KB = exports.KB = (length) ->
  char = kb = ""
  kb += "K" for i in [0...1024]
  char += kb for i in [0...length]
  char

run = exports.run = (values, next) ->
  next = (report) -> console.log report unless next?
  client = new memcached memcached_instance
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
        if require.main == module
          console.log counter + " keys added"
        else
          next counter + " keys added"
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
          console.log report

  client.connect memcached_instance, (err, result) ->
    throw err if err
    cb values, next


scenarios = exports.scenarios =

  "tiny_fixed": (reporter) ->
    respawn -> run [ B 5 ], reporter

  "tiny_fixed_2": (reporter) ->
    respawn -> run [ B 20 ], reporter

  "small_fixed": (reporter) ->
    respawn -> run [ KB 10 ], reporter

  "small_fixed_2": (reporter) ->
    respawn -> run [ KB 42 ], reporter

  "small_fixed_3": (reporter) ->
    respawn -> run [ KB 60 ], reporter

  "big_fixed": (reporter) ->
    respawn -> run [ KB 250 ], reporter

  "big_fixed_2": (reporter) ->
    respawn -> run [ KB 500 ], reporter

  "big_fixed_3": (reporter) ->
    respawn -> run [ KB 800 ], reporter

  "small_varying": (reporter) ->
    respawn ->
      run [
        KB 4
        KB 8
        KB 10
        KB 12
        KB 14
        KB 16
        KB 18
        KB 20
        KB 30
        KB 40
        KB 50
      ]
      , reporter

  "small_varying_2": () ->
    respawn ->
      run [
        KB 40
        KB 60
      ]
      , reporter

  "small_varying_3": (reporter) ->
    respawn ->
      run [
        KB 10
        KB 30
        KB 50
        KB 80
        KB 100
        KB 150
      ]
      , reporter

  "big_varying": (reporter) ->
    respawn ->
      run [
        KB 300
        KB 400
        KB 500
        KB 600
        KB 800
      ]
      , reporter

  "mixed_up": (reporter) ->
    respawn ->
      run [
        KB 5
        KB 10
        KB 30
        KB 50
        KB 80
        KB 100
        KB 200
        KB 300
        KB 400
        KB 500
        KB 600
        KB 800
      ]
      , reporter

  
if require.main == module
  #scenarios["small_fixed"]()
  #scenarios["mixed_up"]()
  scenarios["big_fixed"]( (report) -> console.log 'log:' + report )
