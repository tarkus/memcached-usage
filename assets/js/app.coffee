class MainApp extends Spine.Controller
  events:
    'click .scenario': 'run'
    'click .back-to-top': 'scrollToTop'

  elements:
    '.scenario': 'scenarios'

  run: (e) =>
    e.preventDefault()
    return false if not @socket.connected
    @socket.emit 'run', e.srcElement.innerHTML
    $('#info').html("").addClass("hidden")
    $('#output').html("")
    spinner = new Spinner({
      length: 2
      width: 3
      radius: 5
      hwaccel: true
    }).spin()
    $('#output').append(spinner.el)
    $(s).removeClass('active') for s in @scenarios
    $(e.srcElement.parentNode).addClass('active')
    $.fx.off = true
    $('.progress .bar').remove()
    $('.progress').addClass("progress-info progress-striped").removeClass("progress-success progress-warning progress-danger")
    $('.progress').append('<div class="bar"></div>')
    $('.progress').removeClass('hidden')
    $('body').animate scrollTop: $('.output-header').offset().top + 'px', 400

  scrollToTop: ->
    offset = $("#top").offset().top
    @el.animate scrollTop: offset + 'px', 400

$ ->
  socket = io.connect host
  socket.connected = false

  socket.on 'connected', (data) ->
    socket.connected = true

  socket.on 'output', (data) ->
    p = document.createElement('p')
    if typeof data is 'string'
      $('#info').removeClass("hidden")
      $("#info").html("<pre>" + data + "</pre>")
    else if typeof data is 'object'
      setTimeout ->
        if data.real_usage > 90
          $('.progress').addClass("progress-success").removeClass("progress-info")
        if data.real_usage < 85
          $('.progress').addClass("progress-warning").removeClass("progress-info")
        if data.real_usage < 80
          $('.progress').addClass("progress-danger").removeClass("progress-warning progress-info")
      , 800
      line = "<pre class='prettyprint'>" + JSON.stringify(data, null, 2) + "</pre>"
      $('.spinner').before(line)

  socket.on 'progress', (data) ->
    $('.progress .bar').css('width', data + "%")
    if data is 100
      setTimeout ->
        $('.spinner').remove()
        $('.progress').removeClass("progress-striped")
      , 800



  new MainApp(el: $('body'), socket: socket)
