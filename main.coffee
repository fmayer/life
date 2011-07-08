require(['life', 'utils/underscore', 'utils/jquery'],
(li) ->
  leftTop = (elem) ->
    x = 0
    y = 0
    while elem != null
      x += parseInt(elem.offsetLeft)
      y += parseInt(elem.offsetTop)
      elem = elem.offsetParent
    return [x, y]

  class Game
    constructor: (@canvas, @life, @brush, @gap) ->
      if not life?
        @life = new li.Life(new li.Field(30, 30))
      if not brush?
        @brush = [[0, 0]]
      if not gap?
        @gap = 0.5
      @ctx = canvas.getContext('2d')

      $(canvas).mousemove((evt) =>
        d = leftTop(@canvas)
        x = evt.clientX - d[0]
        y = evt.clientY - d[1]
        sq = _.min([@canvas.height, @canvas.width]) / _.max([@life.field.ysize, @life.field.xsize])
        x = Math.floor(x / sq)
        y = Math.floor(y / sq)

        @clearCanvas()
        @drawLife()

        @ctx.fillStroke = '#6D7B8D'
        for v in @brush
          @ctx.fillRect((v[0] + x) * sq, (v[1] + y) * sq, sq, sq)
        @ctx.fillStroke = '#000'

        @drawGrid()
      )

      $(canvas).click((evt) =>
        d = leftTop(@canvas)
        x = evt.clientX - d[0]
        y = evt.clientY - d[1]
        sq = _.min([@canvas.height, @canvas.width]) / _.max([@life.field.ysize, @life.field.xsize])
        x = Math.floor(x / sq)
        y = Math.floor(y / sq)
        @life.field.set(x, y, not @life.field.get(x, y))
        @redrawAll()
      )

      $(canvas).mouseleave((evt) =>
        @redrawAll()
      )

    drawGrid: () ->
      @ctx.lineWidth = 0.2
      sq = _.min([@canvas.height, @canvas.width]) / _.max([@life.field.ysize, @life.field.xsize])
      for i in [0..@life.field.xsize]
        @ctx.beginPath()
        @ctx.moveTo(i * sq, 0)
        @ctx.lineTo(i * sq, @life.field.xsize * sq)
        @ctx.stroke()

      for i in [0..@life.field.ysize]
        @ctx.beginPath()
        @ctx.moveTo(0, i * sq)
        @ctx.lineTo(@life.field.ysize * sq, i * sq)
        @ctx.stroke()

    drawLife: () ->
      sq = _.min([@canvas.height, @canvas.width]) / _.max([@life.field.ysize, @life.field.xsize])
      for x in [0...@life.field.xsize]
        for y in [0...@life.field.ysize]
          if @life.field.get(x, y)
            @ctx.fillRect(x * sq + @gap, y * sq + @gap, sq - @gap, sq - @gap)

    drawAll: () ->
      @drawGrid()
      @drawLife()

    redrawAll: () ->
      @clearCanvas()
      @drawAll()

    clearCanvas: () ->
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      w = @canvas.width
      @canvas.width = 1
      @canvas.width = w


  class Scheduler
    constructor: (@interval, @tick) -> @intervalno = null
    start: -> @intervalno = window.setInterval(
      => @doTick(),
      @interval)
    doTick: -> if @intervalno != null then @tick()
    stop: ->
      window.clearInterval(@intervalno)
      @intervalno = null
    toggle: ->
      if @intervalno != null then @stop() else @start()
    running: -> @intervalno != null
    setInterval: (i) ->
      @interval = i
      if @intervalno != null
        @stop()
        @start()


  $(document).ready(->
    game = new Game(document.getElementById('gol'))
    sched = new Scheduler(500, =>
      game.life.tick()
      game.redrawAll()
    )

    game.drawAll()

    $("#toggle").click(->
      $("#toggle").attr('value', if sched.running() then 'Play' else 'Pause')
      sched.toggle()
    )
    $("#freq").change(->
      sched.setInterval(1000 / parseFloat($(@).val()))
    )
  )
)
