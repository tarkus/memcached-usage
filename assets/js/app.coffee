class AnalysisOutput extends Spine.Model
  @configure 'AnalysisOutput', 'scenario'
  @extend Spine.Model.Ajax

  fetch: ->
    $.getJSON "/run/" + @scenario, (data) =>


class MainApp extends Spine.Controller
  events:
    'click .scenario': 'run'

  elements:
    '.scenario': 'scenarios'

  run: (e) =>
    e.preventDefault()
    @socket.emit 'run', e.srcElement.innerHTML
    $(s).removeClass('active') for s in @scenarios
    $(e.srcElement.parentNode).addClass('active')

$ ->
  socket = io.connect host

  socket.on 'output', (data) ->
    p = document.createElement('p')
    p.innerHTML = data.output
    $('#output').append(p)


  new MainApp(el: $('body'), socket: socket)
