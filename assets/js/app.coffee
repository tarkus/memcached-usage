class AnalysisOutput extends Spine.Model
  @configure 'AnalysisOutput', 'scenario'
  @extend Spine.Model.Ajax

  fetch: ->
    $.getJSON "/run/" + @scenario, (data) =>


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
    @scrollToTop()

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
    return $('.spinner').remove() if data.output is 'DONE'
    if typeof data.output is 'string'
      line = data.output
      p.innerHTML = "<pre>" + line + "</pre>"
    else if typeof data.output is 'object'
      line = JSON.stringify(data.output, null, 2)
      p.innerHTML = "<pre class='prettyprint'>" + line + "</pre>"
    $('.spinner').before(p)
    $('body').animate scrollTop: $(p).offset().top - 100 + 'px', 400

  new MainApp(el: $('body'), socket: socket)
