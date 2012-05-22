{scenarios} = require '../lib/memcached-usage'

reports = {}

describe 'Filled up the server', ->

  describe 'with fixed size', ->

    it 'small objects, dynamic usage. (1)', (done) ->
      name = "small_fixed"
      scenarios[name] (report) ->
        reports[name] = report
        done()

    it 'small objects, dynamic usage. (2)', (done) ->
      name = "small_fixed_2"
      scenarios[name] (report) ->
        report["real_usage"].should.not.equal reports["small_fixed"]["real_usage"]
        reports[name] = report
        done()

    it 'big objects, low usage.', (done) ->
      name = "big_fixed"
      scenarios[name] (report) ->
        report["real_usage"].should.be.below reports["small_fixed"]["real_usage"]
        reports[name] = report
        done()

  describe 'with varying size', ->

    it 'objects less than 200KB, high usage.', (done) ->
      name = "small_varying_3"
      scenarios[name] (report) ->
        report["real_usage"].should.be.above 90
        report["server_usage"].should.be.above 90

        reports[name] = report
        done()

    it 'objects in range from 200KB to 800KB, low usage.', (done) ->
      name = "big_varying"
      scenarios[name] (report) ->
        report["real_usage"].should.be.below 90
        report["server_usage"].should.be.below 90

        reports[name] = report
        done()

    it 'the usage of storing bigger objects is relative lower than storing smaller ones.', (done) ->
      reports["big_varying"]["real_usage"].should.be.below reports["small_varying_3"]["real_usage"]
      done()


