{respawn, run, fixture} = require '../run'

reports = {}

describe 'Filled up the server', ->

  describe 'with fix size objects.', ->

    it 'small object, dynamic usage.', (done) ->
      respawn () ->
        run fixture(1024 * 42), (report) ->
          reports["fixed_small"] = report
          done()

    it 'big object, low usage.', (done) ->
      respawn () ->
        run fixture(1024 * 800), (report) ->
          reports["fixed_big"] = report
          done()

  describe 'with varying size objects.', ->

    it 'varying size less than 200KB, high usage.', (done) ->
      respawn () ->
        run [
          fixture(1024 * 10)
          fixture(1024 * 30)
          fixture(1024 * 100)
          fixture(1024 * 80)
          fixture(1024 * 5)
          fixture(1024 * 50)
          fixture(1024 * 180)
        ], (report) ->
          reports["varying_small"] = report
          done()

    it 'varying size in range from 200KB to 800KB, low usage.', (done) ->
      respawn () ->
        run [
          fixture(1024 * 200)
          fixture(1024 * 400)
          fixture(1024 * 500)
          fixture(1024 * 800)
          fixture(1024 * 900)
        ], (report) ->
          reports["varying_big"] = report
          done()


